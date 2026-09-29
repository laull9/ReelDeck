import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import 'source.dart';
import 'scanner.dart';
import 'source_resolver.dart';
import 'platform/default_resolver.dart';
import 'platform/macos_resolver.dart';

class SourceManager extends ChangeNotifier {
  final SourceScanner _scanner;
  final SourceResolver _resolver;

  final List<Source> _sources = [];
  final Map<int, List<Media>> _mediaBySource = {};
  bool _isScanning = false;

  int _nextSourceId = 1;
  int _nextMediaId = 1;

  SourceManager({SourceScanner? scanner, SourceResolver? resolver})
      : _scanner = scanner ?? SourceScanner(),
        _resolver = resolver ?? _getResolverForPlatform();

  static SourceResolver _getResolverForPlatform() {
    if (Platform.isMacOS) {
      return MacOSResolver();
    }
    return DefaultResolver();
  }

  // Getters
  List<Source> get sources => List.unmodifiable(_sources);

  List<Media> get allMedia {
    return _mediaBySource.values.expand((list) => list).toList();
  }

  bool get isScanning => _isScanning;
  bool get hasSources => _sources.isNotEmpty;

  // Actions
  void addSource(Source source) {
    if (!_sources.any((s) => s.id == source.id)) {
      _sources.add(source);
      _mediaBySource[source.id] = [];
      notifyListeners();
    }
  }

  Future<Source?> pickAndAddFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) {
      return null;
    }

    final name = p.basename(path);
    String platformStr = 'unknown';
    if (Platform.isMacOS) {
      platformStr = 'macos';
    } else if (Platform.isWindows) {
      platformStr = 'windows';
    } else if (Platform.isAndroid) {
      platformStr = 'android';
    }

    final source = Source(
      id: _nextSourceId++,
      name: name,
      locator: path,
      lastKnownPath: path,
      platform: platformStr,
      enabled: true,
      recursive: true,
    );

    _sources.add(source);
    _mediaBySource[source.id] = [];
    notifyListeners();

    await scanSource(source);

    return source;
  }

  Future<void> scanSource(Source source) async {
    _isScanning = true;
    notifyListeners();

    try {
      final isAvailable = await _resolver.checkAvailability(source);
      if (!isAvailable) {
        return;
      }

      final relativePaths = await _scanner.scan(source.lastKnownPath, recursive: source.recursive);
      final mediaList = <Media>[];

      for (final relPath in relativePaths) {
        final fullPath = p.join(source.lastKnownPath, relPath);
        final file = File(fullPath);
        
        int size = 0;
        DateTime modifiedAt = DateTime.now();
        if (await file.exists()) {
          final stat = await file.stat();
          size = stat.size;
          modifiedAt = stat.modified;
        }

        final fileName = p.basename(relPath);
        final ext = p.extension(relPath).replaceAll('.', '').toLowerCase();

        mediaList.add(Media(
          id: _nextMediaId++,
          sourceId: source.id,
          relativePath: relPath,
          fileName: fileName,
          extension: ext,
          size: size,
          modifiedAt: modifiedAt,
        ));
      }

      _mediaBySource[source.id] = mediaList;
      
      final index = _sources.indexWhere((s) => s.id == source.id);
      if (index != -1) {
        _sources[index] = source.copyWith(lastScanAt: DateTime.now());
      }
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> rescanAll() async {
    final enabledSources = _sources.where((s) => s.enabled).toList();
    for (final source in enabledSources) {
      await scanSource(source);
    }
  }

  Future<void> removeSource(int sourceId) async {
    _sources.removeWhere((s) => s.id == sourceId);
    _mediaBySource.remove(sourceId);
    notifyListeners();
  }

  Future<void> toggleSource(int sourceId) async {
    final index = _sources.indexWhere((s) => s.id == sourceId);
    if (index != -1) {
      final source = _sources[index];
      _sources[index] = source.copyWith(enabled: !source.enabled);
      notifyListeners();
    }
  }

  String? resolveMediaPath(Media media) {
    final source = getSourceForMedia(media);
    if (source == null) return null;
    return p.join(source.lastKnownPath, media.relativePath);
  }

  Source? getSourceForMedia(Media media) {
    try {
      return _sources.firstWhere((s) => s.id == media.sourceId);
    } catch (e) {
      return null;
    }
  }

  String getMediaDisplayPath(Media media) {
    final source = getSourceForMedia(media);
    final folderName = source?.name ?? 'Unknown';
    return p.join(folderName, media.relativePath);
  }
}
