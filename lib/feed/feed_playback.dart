part of 'feed_controller.dart';

extension FeedPlayback on FeedController {
  Future<Duration> _resumePosition(int id) async {
    if (!settings.rememberPosition) return Duration.zero;
    final state = await store?.db.stateDao.getState(id);
    return Duration(milliseconds: (state?.lastPosition ?? 0).clamp(0, 1 << 53));
  }

  Future<void> _writePosition(int id, Duration value) {
    _positionWrites = _positionWrites
        .then((_) async {
          // 移除目录会删除媒体记录，忽略已删除视频的迟到事件。
          if (_media.containsKey(id)) {
            await store?.db.stateDao.updatePosition(id, value.inMilliseconds);
          }
        })
        .catchError((Object e) {
          error = '保存进度失败：$e';
        });
    return _positionWrites;
  }

  Future<void> _savePosition([Duration? target]) async {
    final id = _openedMediaId;
    if (id == null || _path == null || store == null) return;
    final value = _completed
        ? Duration.zero
        : target ??
              (imageBytes != null ? position : player?.position ?? position);
    await _writePosition(id, value);
  }

  Future<void> _unbind() async {
    _imageClock?.cancel();
    _imageClock = null;
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
  }

  void _bind() {
    final active = player;
    final id = _openedMediaId;
    if (active == null || id == null) return;
    _subscriptions.addAll([
      active.positionStream.listen((value) {
        if (_disposed || busy || _isScrubbing || _openedMediaId != id) return;
        position = value;
        // 写入时捕获视频 ID 和位置，排队后也不会写到下一条视频。
        final bucket = value.inSeconds ~/ 5;
        if (bucket != _positionSaved) {
          _positionSaved = bucket;
          final saved = _completed ? Duration.zero : value;
          unawaited(_writePosition(id, saved));
        }
        final displayBucket = value.inMilliseconds ~/ 200;
        if (displayBucket != _positionNotified) {
          _positionNotified = displayBucket;
          _notify();
        }
      }),
      active.durationStream.listen((value) {
        if (busy) return;
        duration = value;
        _notify();
      }),
      active.playingStream.listen((value) {
        if (busy) return;
        _playing = value;
        _notify();
      }),
      active.completedStream.listen((done) {
        if (done && !busy && _openedMediaId == id) {
          _completed = true;
          next();
        }
      }),
    ]);
    if (active is MediaKitPlayerService) {
      _subscriptions.add(
        active.errors.listen((message) {
          if (busy || _openedMediaId != id) return;
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
    errorLog.add(message, currentFileName);
    final media = currentMedia;
    if (media != null && await sourceManager?.isAvailable(media) == true) {
      _failed.add(media.id);
      _reconcileQueue();
      if (queue.currentId != null) {
        await _open();
        return;
      }
    }
    error = message;
    _path = null;
    _openedMediaId = null;
    await _saveSession();
  }

  Future<void> _open() async {
    _isScrubbing = false;
    _pauseImage();
    imageBytes = null;
    _scrubTarget = null;
    await _scrubSeek;
    busy = true;
    error = null;
    _path = null;
    _openedMediaId = null;
    _playing = false;
    _completed = false;
    position = duration = Duration.zero;
    _positionSaved = _positionNotified = -1;
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
      if (player is MediaKitPlayerService) {
        await (player as MediaKitPlayerService).setDriveOptimization(
          settings.externalDriveOptimization,
        );
      }
      final start = await _resumePosition(media.id);
      if (isImage) {
        await _openImage(media, resolved, start);
      } else if (pool.hasPreloaded(resolved, start)) {
        await pool.swap();
      } else {
        await player?.open(resolved, start: start);
      }
      _path = resolved;
      _openedMediaId = media.id;
      if (imageBytes == null) {
        position = player?.position ?? start;
        duration = player?.duration ?? Duration.zero;
        _positionSaved = position.inSeconds ~/ 5;
        _bind();
        await player?.setVolume(muted ? 0 : settings.defaultVolume);
        if (settings.autoplay) await player?.play();
        _playing = player?.isPlaying ?? false;
      } else {
        _playing = settings.autoplay;
        _startImageClock();
      }
      await store?.db.stateDao.incrementPlayCount(media.id);
      await _saveSession();
    } catch (e) {
      await _recover('视频打开失败：$e');
    } finally {
      busy = false;
      _notify();
    }
    // 当前画面已交接再预加载；Android 只保留一个解码器。
    if (!pool.preloadEnabled ||
        !settings.preloadNext ||
        isImage ||
        error != null) {
      return;
    }
    final next = _media[queue.nextId];
    if (next == null ||
        SourceScanner.imageExtensions.contains(next.extension)) {
      return;
    }
    try {
      final nextPath = await sourceManager?.resolveMediaPath(next);
      if (nextPath != null) {
        if (pool.nextPlayer is MediaKitPlayerService) {
          await (pool.nextPlayer as MediaKitPlayerService).setDriveOptimization(
            settings.externalDriveOptimization,
          );
        }
        await pool.preloadNext(nextPath, start: await _resumePosition(next.id));
      }
    } catch (_) {
      // 预加载失败时，切换后走普通打开流程。
    }
  }
}
