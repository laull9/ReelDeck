import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

import '../database/database.dart';
import '../database/library_store.dart';
import '../player/player_pool.dart';
import '../player/player_service.dart';
import '../player/media_kit_player.dart';
import '../queue/queue_engine.dart';
import '../queue/queue_order.dart';
import '../sources/scanner.dart';
import '../sources/platform/storage_bridge.dart';
import 'playback_error_log.dart';
import '../settings/settings.dart';
import '../sources/source.dart';
import '../sources/source_manager.dart';

part 'feed_playback.dart';
part 'feed_images.dart';
part 'feed_actions.dart';

class FeedController extends ChangeNotifier {
  final QueueEngine queue;
  final SourceManager? sourceManager;
  final LibraryStore? store;
  final PlayerPool pool;
  final AppSettings settings;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Map<int, Media> _media = {};
  Set<int> _hidden = {}, _favorites = {};
  final Set<int> _failed = {};
  String? lastPlaybackError;
  final errorLog = PlaybackErrorLog();
  Uint8List? imageBytes;
  Timer? _imageClock;
  double _imageRate = 1;
  String _order = 'shuffle';
  bool _includeImages = false;
  bool _preloadSetting = true;
  int _preloadGeneration = 0;
  int? _preloadMediaId;
  bool _preloading = false;
  final Map<int, Object> _preloadErrors = {};
  Timer? _stallClock;

  /// 播放中进度持续不变超过此时间视为解码停滞。
  Duration stallTimeout = const Duration(seconds: 10);
  String _decoderSetting = 'auto';
  double _volumeSetting = 1;
  bool _driveSetting = true;
  bool get isImage =>
      currentMedia != null &&
      SourceScanner.imageExtensions.contains(currentMedia!.extension);
  List<HiddenRuleEntry> _rules = [];
  Future<void> _pending = Future.value();
  Future<void> _positionWrites = Future.value();
  Future<void> _preloadTask = Future.value();
  bool _disposed = false, _ready = false, _showInfo = true;
  int _revision = -1, _positionSaved = -1, _positionNotified = -1;
  int? _openedMediaId;
  bool _completed = false;
  bool _opening = false;
  Future<void>? _closing;
  String? _path;
  String? error;
  bool busy = false, muted = false, fullscreen = false;
  Duration position = Duration.zero, duration = Duration.zero;
  String scope = 'all';
  bool _playing = false;
  bool _isScrubbing = false;
  Duration? _scrubTarget;
  bool _seekInProgress = false;
  Future<void> _scrubSeek = Future.value();

  bool get isScrubbing => _isScrubbing;

  FeedController({
    QueueEngine? queue,
    this.sourceManager,
    this.store,
    PlayerPool? pool,
    AppSettings? settings,
  }) : queue = queue ?? QueueEngine(),
       pool = pool ?? PlayerPool(),
       settings = settings ?? AppSettings();

  String folderScope(Media media) =>
      'folder:${media.sourceId}:${p.posix.dirname(media.relativePath.replaceAll('\\', '/'))}';

  int? get currentMediaId => queue.currentId;
  int? get displayedMediaId => _openedMediaId;
  bool get canGoPrevious =>
      queue.previousId != null && queue.previousId != currentMediaId;
  bool get canGoNext =>
      queue.nextId != null || (settings.loopQueue && queue.queue.length > 1);
  Media? get currentMedia => _media[currentMediaId];
  String? get currentPath => _path;
  String get currentFileName => currentMedia?.fileName ?? '';
  String get currentFolder => currentMedia == null
      ? ''
      : sourceManager?.getMediaDisplayPath(currentMedia!) ??
            p.dirname(currentMedia!.relativePath);
  int get queueLength => queue.queue.length;
  int get queueIndex => queue.currentIndex;
  int? get currentFileSize => currentMedia?.size;
  String get currentFileExtension => currentMedia?.extension ?? '';
  bool get isPlaying => _playing;
  bool get isFavorite => _favorites.contains(currentMediaId);
  bool get showOverlay => true;
  bool get showInfo => _showInfo;
  String get videoFit => settings.videoFit;
  PlayerService? get player => pool.currentPlayer;
  Future<void> get settled async {
    await _pending;
    await _positionWrites;
    await _preloadTask;
    await pool.settled;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) {
    _pending = _pending.then((_) async {
      if (_disposed) return;
      try {
        await action();
      } catch (e) {
        error = '操作失败：$e';
      }
      _notify();
    });
    return _pending;
  }

  Future<void> initialize() => _run(() async {
    await pool.initialize();
    _order = settings.queueOrder;
    _includeImages = settings.includeImages;
    _preloadSetting = settings.preloadNext;
    _decoderSetting = settings.decoderMode;
    _volumeSetting = settings.defaultVolume;
    _driveSetting = settings.externalDriveOptimization;
    await errorLog.load(
      settings.file == null
          ? null
          : File('${settings.file!.parent.path}/playback-errors.json'),
    );
    queue.orderer = (ids, random) =>
        orderMedia(ids, _media, settings.queueOrder, random);
    if (store != null) {
      _favorites = await store!.db.stateDao.getFavoriteIds();
      _hidden = await store!.db.stateDao.getHiddenMediaIds();
      _rules = await store!.rules();
    }
    _refreshMedia();
    final session = await store?.db.sessionDao.getLatestSession();
    if (session != null) {
      try {
        scope = session.scope;
        final ids = (jsonDecode(session.queue) as List).cast<int>();
        queue.restore(ids, session.currentIndex);
      } catch (_) {
        queue.buildQueue([]);
      }
    }
    _reconcileQueue();
    _ready = true;
    sourceManager?.addListener(_sourcesChanged);
    settings.addListener(_settingsChanged);
    await _open();
  });

  void _refreshMedia() {
    _media.clear();
    for (final m in sourceManager?.allMedia ?? <Media>[]) {
      _media[m.id] = m;
    }
    _revision = sourceManager?.revision ?? 0;
  }

  List<int> _eligible() => _media.values
      .where((m) {
        if (!settings.includeImages &&
            SourceScanner.imageExtensions.contains(m.extension)) {
          return false;
        }
        if (_hidden.contains(m.id) || _failed.contains(m.id)) return false;
        final source = sourceManager?.getSourceForMedia(m);
        if (source != null && !source.enabled) return false;
        if (scope == 'favorites' && !_favorites.contains(m.id)) return false;
        if (scope.startsWith('source:') && scope != 'source:${m.sourceId}') {
          return false;
        }
        final path = m.relativePath.replaceAll('\\', '/');
        if (scope.startsWith('folder:')) {
          final boundary = scope.indexOf(':', 7);
          if (boundary < 0 ||
              int.tryParse(scope.substring(7, boundary)) != m.sourceId) {
            return false;
          }
          final folder = scope.substring(boundary + 1);
          if (folder != '.' && !path.startsWith('$folder/')) return false;
        }
        return !_rules.any((r) {
          if (r.sourceId != m.sourceId) return false;
          final folder = r.relativePath.replaceAll('\\', '/');
          return folder == '.' ||
              (r.recursive
                  ? path.startsWith('$folder/')
                  : p.posix.dirname(path) == folder);
        });
      })
      .map((m) => m.id)
      .toList();

  void _reconcileQueue({bool sortPending = false}) {
    queue.reconcile(_eligible(), reorderPending: sortPending);
    if (queue.currentId == null &&
        queue.queue.isNotEmpty &&
        settings.loopQueue) {
      queue.buildQueue(_eligible());
    }
  }

  void _sourcesChanged() {
    if (!_ready || _revision == sourceManager?.revision) return;
    _run(() async {
      final previous = currentMediaId;
      _failed.clear();
      _preloadErrors.clear();
      _refreshMedia();
      _reconcileQueue(
        sortPending: ['newest', 'oldest'].contains(settings.queueOrder),
      );
      if (previous != currentMediaId || _path == null) {
        await _savePosition();
        await _open();
      } else {
        await _saveSession();
      }
    });
  }

  void _settingsChanged() {
    if (_order != settings.queueOrder ||
        _includeImages != settings.includeImages) {
      _order = settings.queueOrder;
      _includeImages = settings.includeImages;
      _run(() async {
        await _savePosition();
        queue.buildQueue(_eligible());
        await _open();
      });
    }
    sourceManager?.recursive = settings.recursiveScan;
    sourceManager?.autoRefresh = settings.autoRefreshFolders;
    final decoderChanged = _decoderSetting != settings.decoderMode;
    final preloadChanged = _preloadSetting != settings.preloadNext;
    final releaseNext = _preloadSetting && !settings.preloadNext;
    final changedPlayback =
        _volumeSetting != settings.defaultVolume ||
        _driveSetting != settings.externalDriveOptimization ||
        preloadChanged ||
        decoderChanged;
    _preloadSetting = settings.preloadNext;
    _volumeSetting = settings.defaultVolume;
    _driveSetting = settings.externalDriveOptimization;
    _decoderSetting = settings.decoderMode;
    if (releaseNext || decoderChanged) _preloadGeneration++;
    if (changedPlayback) {
      _run(() async {
        await pool.settled;
        await player?.setVolume(muted ? 0 : settings.defaultVolume);
        if (player is MediaKitPlayerService) {
          await (player as MediaKitPlayerService).setDriveOptimization(
            settings.externalDriveOptimization,
          );
        }
        if (releaseNext || decoderChanged) await pool.releasePreloads();
        if (decoderChanged) {
          final resumePlaying = isPlaying;
          await _savePosition();
          await _open();
          if (!resumePlaying) {
            await player?.pause();
            _pauseImage();
            _playing = false;
          }
        } else if (settings.preloadNext) {
          _preloadNeighbors();
        }
      });
    }
    _notify();
  }

  Future<void> _saveSession() async {
    if (store == null) return;
    await store!.db.transaction(() async {
      await store!.db.delete(store!.db.sessions).go();
      await store!.db.sessionDao.saveSession(
        SessionsCompanion.insert(
          scope: scope,
          queue: jsonEncode(queue.queue),
          currentIndex: queue.currentIndex,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  bool get _shuffleRound =>
      settings.reshuffleAfterRound &&
      ['shuffle', 'smart'].contains(settings.queueOrder);

  Future<void> next() => _run(_advance);

  Future<void> _advance() async {
    await _savePosition();
    if (!queue.advance()) {
      if (!settings.loopQueue || queue.queue.isEmpty) {
        await player?.pause();
        _pauseImage();
        return;
      }
      queue.startNextRound(reshuffle: _shuffleRound);
    }
    await _open();
  }

  Future<void> previous() => _run(() async {
    if (queue.previousId == null) return;
    await _savePosition();
    queue.goBack();
    await _open();
  });
  Future<void> reshuffle() => _run(() async {
    await _savePosition();
    queue.reshuffle();
    await _open();
  });
  Future<void> retry() => _run(() async {
    await _savePosition();
    _failed.clear();
    _preloadErrors.clear();
    _reconcileQueue();
    await _open();
  });
  Future<void> setScope(String value) => _run(() async {
    await _savePosition();
    scope = value;
    queue.buildQueue(_eligible());
    // 新范围首项仍是当前视频时继续播放，只更新会话和预加载，避免黑屏重开。
    if (_path != null && currentMediaId == _openedMediaId) {
      _preloadGeneration++;
      _preloadNeighbors();
      await _saveSession();
      return;
    }
    await _open();
  });
  Future<void> togglePlayPause() => _run(() async {
    if (_path == null) return;
    if (imageBytes != null) {
      _playing = !_playing;
      _startImageClock();
      await _savePosition();
      return;
    }
    if (player!.isPlaying) {
      await player!.pause();
      await _savePosition();
    } else {
      await player!.play();
    }
  });
  Future<void> seekTo(Duration value) => _run(() async {
    if (_path == null) return;
    final clamped = Duration(
      milliseconds: value.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    position = clamped;
    _notify();
    if (imageBytes == null) await player?.seekTo(clamped);
    _completed = false;
    await _savePosition(clamped);
  });

  void startScrub() {
    _isScrubbing = true;
  }

  void scrubTo(Duration target) {
    if (_path == null) return;
    final clamped = Duration(
      milliseconds: target.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    _scrubTarget = clamped;
    position = clamped;
    _notify();
    if (imageBytes == null) _dispatchThrottledSeek();
  }

  void _dispatchThrottledSeek() {
    if (_seekInProgress || _scrubTarget == null || _path == null) return;
    final target = _scrubTarget!;
    _scrubTarget = null;
    _seekInProgress = true;
    final active = player!;
    _scrubSeek = active
        .seekTo(target)
        .catchError((Object e) {
          error = '跳转失败：$e';
        })
        .whenComplete(() {
          _seekInProgress = false;
          if (_isScrubbing &&
              identical(player, active) &&
              _scrubTarget != null) {
            _dispatchThrottledSeek();
          }
        });
  }

  Future<void> endScrub([Duration? finalTarget]) {
    _isScrubbing = false;
    final target = finalTarget ?? _scrubTarget ?? position;
    _scrubTarget = null;
    return _run(() async {
      await _scrubSeek;
      if (_path != null) {
        final clamped = Duration(
          milliseconds: target.inMilliseconds.clamp(0, duration.inMilliseconds),
        );
        position = clamped;
        if (imageBytes == null) await player?.seekTo(clamped);
        _completed = false;
        await _savePosition(clamped);
      }
    });
  }

  void seekForward({Duration amount = const Duration(seconds: 5)}) =>
      seekTo(position + amount);
  void seekBackward({Duration amount = const Duration(seconds: 5)}) =>
      seekTo(position - amount);
  Future<void> suspend() => _run(() async {
    await player?.pause();
    _pauseImage();
    await _savePosition();
  });
  Future<void> close() => _closing ??= _close();

  Future<void> _close() async {
    sourceManager?.removeListener(_sourcesChanged);
    settings.removeListener(_settingsChanged);
    _preloadGeneration++;
    await _pending;
    _pauseImage();
    await _preloadTask;
    await errorLog.flushed;
    _disposed = true;
    await player?.pause();
    await _savePosition();
    await _unbind();
    await pool.dispose();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(close());
    super.dispose();
  }
}
