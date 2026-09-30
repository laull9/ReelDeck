import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

import '../database/database.dart';
import '../database/library_store.dart';
import '../player/player_pool.dart';
import '../player/player_service.dart';
import '../player/media_kit_player.dart';
import '../queue/queue_engine.dart';
import '../settings/settings.dart';
import '../sources/source.dart';
import '../sources/source_manager.dart';

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
  List<HiddenRuleEntry> _rules = [];
  Future<void> _pending = Future.value();
  bool _disposed = false, _ready = false, _showInfo = true;
  int _revision = -1, _positionSaved = -1;
  String? _path;
  String? error;
  bool busy = false, muted = false, fullscreen = false;
  Duration position = Duration.zero, duration = Duration.zero;
  String scope = 'all';
  bool _playing = false;
  bool _isScrubbing = false;
  Duration? _scrubTarget;
  bool _seekInProgress = false;

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

  int? get currentMediaId => queue.currentId;
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
  Future<void> get settled => _pending;

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
    queue.reconcile(_eligible());
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
        if (_hidden.contains(m.id) || _failed.contains(m.id)) return false;
        final source = sourceManager?.getSourceForMedia(m);
        if (source != null && !source.enabled) return false;
        if (scope == 'favorites' && !_favorites.contains(m.id)) return false;
        if (scope.startsWith('source:') && scope != 'source:${m.sourceId}') {
          return false;
        }
        final path = m.relativePath.replaceAll('\\', '/');
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

  void _sourcesChanged() {
    if (!_ready || _revision == sourceManager?.revision) return;
    _run(() async {
      final previous = currentMediaId;
      _failed.clear();
      _refreshMedia();
      queue.reconcile(_eligible());
      if (previous != currentMediaId || _path == null) {
        await _open();
      } else {
        await _saveSession();
      }
    });
  }

  void _settingsChanged() {
    sourceManager?.recursive = settings.recursiveScan;
    player?.setVolume(muted ? 0 : settings.defaultVolume);
    _notify();
  }

  Future<void> _saveSession() async {
    if (store == null) return;
    await store!.db.transaction(() async {
      await store!.db.delete(store!.db.sessions).go();
      await store!.db.sessionDao.saveSession(SessionsCompanion.insert(
        scope: scope,
        queue: jsonEncode(queue.queue),
        currentIndex: queue.currentIndex,
        createdAt: DateTime.now(),
      ));
    });
  }

  Future<void> _savePosition() async {
    final id = currentMediaId;
    if (id != null && _path != null && store != null) {
      await store!.db.stateDao.updatePosition(id, position.inMilliseconds);
    }
  }

  Future<void> _unbind() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }

  void _bind() {
    final active = player;
    if (active == null) return;
    _subscriptions.addAll([
      active.positionStream.listen((value) {
        if (!_isScrubbing) {
          position = value;
          final second = value.inSeconds;
          if (second ~/ 5 != _positionSaved && !busy) {
            _positionSaved = second ~/ 5;
            _run(_savePosition);
          }
          _notify();
        }
      }),
      active.durationStream.listen((value) {
        duration = value;
        _notify();
      }),
      active.playingStream.listen((value) {
        _playing = value;
        _notify();
      }),
      active.completedStream.listen((done) {
        if (done && !busy) next();
      }),
    ]);
    if (active is MediaKitPlayerService) {
      _subscriptions.add(
        active.errors.listen((message) {
          if (busy) return;
          _run(() async {
            await active.pause();
            await _recover('无法播放 $currentFileName：$message');
          });
        }),
      );
    }
  }

  Future<void> _recover(String message) async {
    lastPlaybackError = message;
    final media = currentMedia;
    if (media != null && await sourceManager?.isAvailable(media) == true) {
      _failed.add(media.id);
      queue.reconcile(_eligible());
      if (queue.currentId != null) {
        await _open();
        return;
      }
    }
    error = message;
    _path = null;
    await _saveSession();
  }

  Future<void> _open() async {
    busy = true;
    error = null;
    _path = null;
    _playing = false;
    position = duration = Duration.zero;
    _positionSaved = -1;
    _notify();
    await _unbind();
    await player?.pause();
    try {
      final media = currentMedia;
      if (media == null) {
        await _saveSession();
        return;
      }
      final resolved = await sourceManager?.resolveMediaPath(media);
      if (resolved == null) {
        await _recover('视频或目录无法访问，请连接磁盘后重试，或重新授权目录。');
        return;
      }
      if (pool.nextPlayer?.currentPath == resolved) {
        await pool.swap();
      } else {
        await player?.open(resolved);
      }
      _path = resolved;
      _bind();
      position = player?.position ?? Duration.zero;
      duration = player?.duration ?? Duration.zero;
      await player?.setVolume(muted ? 0 : settings.defaultVolume);
      if (settings.rememberPosition) {
        final state = await store?.db.stateDao.getState(media.id);
        if ((state?.lastPosition ?? 0) > 0) {
          await player?.seekTo(Duration(milliseconds: state!.lastPosition!));
        }
      }
      if (settings.autoplay) await player?.play();
      await store?.db.stateDao.incrementPlayCount(media.id);
      await _saveSession();
      final next = _media[queue.nextId];
      if (next != null) {
        final nextPath = await sourceManager?.resolveMediaPath(next);
        if (nextPath != null) {
          try {
            await pool.preloadNext(nextPath);
          } catch (_) {
            /* 当前视频继续播放。 */
          }
        }
      }
    } catch (e) {
      await _recover('视频打开失败：$e');
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> next() => _run(() async {
    await _savePosition();
    if (!queue.advance()) {
      if (!settings.loopQueue || queue.queue.isEmpty) {
        await player?.pause();
        return;
      }
      queue.reshuffle();
    }
    await _open();
  });
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
    _failed.clear();
    queue.reconcile(_eligible());
    await _open();
  });
  Future<void> setScope(String value) => _run(() async {
    await _savePosition();
    scope = value;
    queue.buildQueue(_eligible());
    await _open();
  });
  Future<void> togglePlayPause() => _run(() async {
    if (_path == null) return;
    if (player!.isPlaying) {
      await player!.pause();
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
    await player?.seekTo(clamped);
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
    _dispatchThrottledSeek();
  }

  void _dispatchThrottledSeek() {
    if (_seekInProgress || _scrubTarget == null || _path == null) return;
    final target = _scrubTarget!;
    _scrubTarget = null;
    _seekInProgress = true;
    player?.seekTo(target).whenComplete(() {
      _seekInProgress = false;
      if (_scrubTarget != null) {
        _dispatchThrottledSeek();
      }
    });
  }

  Future<void> endScrub([Duration? finalTarget]) async {
    _isScrubbing = false;
    final target = finalTarget ?? _scrubTarget ?? position;
    _scrubTarget = null;
    if (_path != null) {
      final clamped = Duration(
        milliseconds: target.inMilliseconds.clamp(0, duration.inMilliseconds),
      );
      position = clamped;
      await player?.seekTo(clamped);
    }
    _notify();
  }

  void seekForward({Duration amount = const Duration(seconds: 5)}) =>
      seekTo(position + amount);
  void seekBackward({Duration amount = const Duration(seconds: 5)}) =>
      seekTo(position - amount);
  Future<void> toggleFavorite() => _run(() async {
    final id = currentMediaId;
    if (id == null) return;
    final favorite = !_favorites.contains(id);
    await store?.db.stateDao.setFavorite(id, favorite);
    if (favorite) {
      _favorites.add(id);
    } else {
      _favorites.remove(id);
    }
    if (scope == 'favorites' && !favorite) {
      queue.reconcile(_eligible());
      await _open();
    }
  });
  Future<void> hideCurrentVideo() => _run(() async {
    final id = currentMediaId;
    if (id == null) return;
    await store?.db.stateDao.setHidden(id, true);
    _hidden.add(id);
    queue.reconcile(_eligible());
    await _open();
  });
  Future<void> hideCurrentFolder() => _run(() async {
    final media = currentMedia;
    if (media == null || store == null) return;
    await store!.hideFolder(media.sourceId, p.dirname(media.relativePath));
    _rules = await store!.rules();
    queue.reconcile(_eligible());
    await _open();
  });
  Future<void> resetHidden() => _run(() async {
    await store?.resetHidden();
    _hidden.clear();
    _rules.clear();
    queue.reconcile(_eligible());
    await _open();
  });
  void toggleInfo() {
    _showInfo = !_showInfo;
    _notify();
  }

  void toggleOverlay() => toggleInfo();
  void cycleVideoFit() {
    final next = switch (videoFit) { 'fit' => 'fill', 'fill' => 'original', _ => 'fit' };
    settings.update(videoFit: next);
  }
  Future<void> toggleFullscreen() => _run(() async {
    fullscreen ? await defaultExitNativeFullscreen() : await defaultEnterNativeFullscreen();
    fullscreen = !fullscreen;
  });
  void exitFullscreen() {
    if (fullscreen) toggleFullscreen();
  }

  void setSpeed(double rate) {
    final active = player;
    if (active is MediaKitPlayerService) _run(() => active.setRate(rate));
  }

  Future<void> toggleMute() => _run(() async {
    muted = !muted;
    await player?.setVolume(muted ? 0 : settings.defaultVolume);
  });
  Future<void> suspend() => _run(() async {
    await _savePosition();
    await player?.pause();
  });
  Future<void> close() async {
    sourceManager?.removeListener(_sourcesChanged);
    settings.removeListener(_settingsChanged);
    await _pending;
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
