import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../database/library_store.dart';
import 'source.dart';
import 'scanner.dart';
import 'source_resolver.dart';
import 'platform/default_resolver.dart';
import 'platform/storage_bridge.dart';

class SourceManager extends ChangeNotifier {
  final SourceScanner _scanner;
  final SourceResolver _resolver;
  final LibraryStore? store;
  final List<Source> _sources = [];
  final Map<int, List<Media>> _mediaBySource = {};
  bool _isScanning = false;
  bool _disposed = false;
  String? error;
  int revision = 0;
  int _nextSourceId = 1;
  int _nextMediaId = 1;
  bool recursive = true;

  SourceManager({SourceScanner? scanner, SourceResolver? resolver, this.store})
    : _scanner = scanner ?? SourceScanner(),
      _resolver = resolver ?? DefaultResolver();

  List<Source> get sources => List.unmodifiable(_sources);
  List<Media> get allMedia =>
      _mediaBySource.values.expand((list) => list).toList();
  bool get isScanning => _isScanning;
  bool get hasSources => _sources.isNotEmpty;
  void _notify({bool changed = false}) {
    if (changed) revision++;
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() async {
    if (store == null) return;
    _sources.addAll(await store!.sources());
    for (final s in _sources) {
      _nextSourceId = max(_nextSourceId, s.id + 1);
      _mediaBySource[s.id] = [];
    }
    for (final m in await store!.media()) {
      _nextMediaId = max(_nextMediaId, m.id + 1);
      _mediaBySource[m.sourceId]?.add(m);
    }
    _notify(changed: true);
  }

  void addSource(Source source) {
    if (_sources.any((s) => s.id == source.id)) return;
    _sources.add(source);
    _nextSourceId = max(_nextSourceId, source.id + 1);
    _mediaBySource[source.id] = [];
    _notify(changed: true);
  }

  Future<Source?> pickAndAddFolder({int? replaceId}) async {
    if (_isScanning) return null;
    try {
      error = null;
      final picked = await StorageBridge.pick();
      if (picked == null) return null;
      final locator = picked['locator'] as String;
      final path = picked['path'] as String;
      for (final s in _sources) {
        if (s.id != replaceId &&
            (s.locator == locator || s.lastKnownPath == path)) {
          await scanSource(s);
          return s;
        }
      }
      final old = _sources.where((s) => s.id == replaceId).firstOrNull;
      final source = Source(
        id: old?.id ?? _nextSourceId++,
        name: picked['name'] as String? ?? p.basename(path),
        locator: locator,
        lastKnownPath: path,
        platform: Platform.operatingSystem,
        enabled: old?.enabled ?? true,
        recursive: old?.recursive ?? recursive,
      );
      await store?.saveSource(source);
      if (old != null) _sources.remove(old);
      _sources.add(source);
      _mediaBySource.putIfAbsent(source.id, () => []);
      _notify(changed: true);
      await scanSource(source);
      return source;
    } catch (e) {
      error = '无法添加目录：$e';
      _notify();
      return null;
    }
  }

  Future<Source?> _resolve(Source source) async {
    if (source.platform == 'test') return source;
    final result = await StorageBridge.resolve(source.locator);
    if (result == null) return null;
    final updated = source.copyWith(
      lastKnownPath: result['path'] as String,
      locator: result['locator'] as String? ?? source.locator,
    );
    final index = _sources.indexWhere((s) => s.id == source.id);
    if (index < 0) return null;
    _sources[index] = updated;
    await store?.saveSource(updated);
    return updated;
  }

  Future<void> scanSource(Source source) async {
    if (_isScanning) return;
    _isScanning = true;
    error = null;
    _notify();
    try {
      final resolved = await _resolve(source);
      if (resolved == null) throw const FileSystemException('目录未连接或授权失效');
      source = resolved;
      final old = {
        for (final m in _mediaBySource[source.id] ?? <Media>[])
          m.relativePath: m,
      };
      final items = <Media>[];
      if (Platform.isAndroid && source.platform != 'test') {
        for (final row in await StorageBridge.scan(
          source.locator,
          source.recursive,
        )) {
          final rel = row['path'] as String;
          items.add(
            Media(
              id: old[rel]?.id ?? _nextMediaId++,
              sourceId: source.id,
              relativePath: rel,
              fileName: p.posix.basename(rel),
              extension: p.posix.extension(rel).substring(1).toLowerCase(),
              size: row['size'] as int? ?? 0,
              modifiedAt: DateTime.fromMillisecondsSinceEpoch(
                row['modified'] as int? ?? 0,
              ),
            ),
          );
        }
      } else {
        if (!await _resolver.checkAvailability(source)) {
          throw const FileSystemException('目录未连接或无法访问');
        }
        final paths = await _scanner.scan(
          source.lastKnownPath,
          recursive: source.recursive,
        );
        for (final rel in paths) {
          final stat = await File(p.join(source.lastKnownPath, rel)).stat();
          if (stat.type != FileSystemEntityType.file) continue;
          items.add(
            Media(
              id: old[rel]?.id ?? _nextMediaId++,
              sourceId: source.id,
              relativePath: rel,
              fileName: p.basename(rel),
              extension: p.extension(rel).substring(1).toLowerCase(),
              size: stat.size,
              modifiedAt: stat.modified,
            ),
          );
        }
      }
      if (!_sources.any((s) => s.id == source.id)) return;
      await store?.replaceMedia(source.id, items);
      _mediaBySource[source.id] = items;
      final updated = source.copyWith(lastScanAt: DateTime.now());
      _sources[_sources.indexWhere((s) => s.id == source.id)] = updated;
      await store?.saveSource(updated);
      revision++;
    } catch (e) {
      error = '扫描 ${source.name} 失败：$e';
    } finally {
      _isScanning = false;
      _notify();
    }
  }

  Future<void> rescanAll() async {
    for (final source in _sources.where((s) => s.enabled).toList()) {
      await scanSource(source);
    }
  }

  Future<void> removeSource(int sourceId) async {
    if (_isScanning) return;
    _sources.removeWhere((s) => s.id == sourceId);
    _mediaBySource.remove(sourceId);
    await store?.removeSource(sourceId);
    _notify(changed: true);
  }

  Future<void> toggleSource(int sourceId) async {
    final index = _sources.indexWhere((s) => s.id == sourceId);
    if (index < 0 || _isScanning) return;
    final source = _sources[index].copyWith(enabled: !_sources[index].enabled);
    _sources[index] = source;
    await store?.saveSource(source);
    _notify(changed: true);
  }

  Future<bool> isAvailable(Media media) async {
    try {
      final original = getSourceForMedia(media);
      if (original == null) return false;
      final source = await _resolve(original);
      if (source == null) return false;
      return Platform.isAndroid && source.platform != 'test' ||
          await _resolver.checkAvailability(source);
    } catch (_) {
      return false;
    }
  }

  Future<String?> resolveMediaPath(Media media) async {
    final original = getSourceForMedia(media);
    if (original == null || !original.enabled) return null;
    final source = await _resolve(original);
    if (source == null) return null;
    if (Platform.isAndroid && source.platform != 'test') {
      return StorageBridge.media(source.locator, media.relativePath);
    }
    final path = await _resolver.resolveFullPath(source, media.relativePath);
    return path != null && await File(path).exists() ? path : null;
  }

  Source? getSourceForMedia(Media media) =>
      _sources.where((s) => s.id == media.sourceId).firstOrNull;
  String getMediaDisplayPath(Media media) =>
      p.join(getSourceForMedia(media)?.name ?? '', media.relativePath);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
