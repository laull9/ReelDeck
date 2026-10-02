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

  Future<void> _recover(String message, {bool skip = true}) async {
    lastPlaybackError = message;
    errorLog.add(message, currentFileName);
    final media = currentMedia;
    if (skip &&
        media != null &&
        await sourceManager?.isAvailable(media) == true) {
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
    // 滑到正在预加载的目标时接管同一任务，避免取消后再次解码。
    if (_preloadMediaId == currentMediaId) {
      await _preloadTask;
    }
    _preloadGeneration++;
    await pool.settled;
    _isScrubbing = false;
    _pauseImage();
    imageBytes = null;
    _scrubTarget = null;
    await _scrubSeek;
    error = null;

    final media = currentMedia;
    if (media == null) {
      busy = false;
      _path = null;
      _openedMediaId = null;
      _playing = false;
      _completed = false;
      position = duration = Duration.zero;
      _positionSaved = _positionNotified = -1;
      _notify();
      await _unbind();
      await player?.pause();
      await _saveSession();
      return;
    }

    final resolved = await sourceManager?.resolveMediaPath(media);
    if (resolved == null) {
      await _recover('视频或目录无法访问，请连接磁盘后重试，或重新授权目录。');
      return;
    }

    final start = await _resumePosition(media.id);
    final isPreloadedNext = !isImage && pool.hasPreloadedNext(resolved, start);
    final isPreloadedPrev =
        !isImage && pool.hasPreloadedPrevious(resolved, start);
    final isPreloaded = isPreloadedNext || isPreloadedPrev;

    if (!isPreloaded) {
      busy = true;
      _path = null;
      _openedMediaId = null;
      _playing = false;
      _completed = false;
      position = duration = Duration.zero;
      _positionSaved = _positionNotified = -1;
      _notify();
    }

    await _unbind();

    try {
      await player?.pause();
      if (player is MediaKitPlayerService) {
        await (player as MediaKitPlayerService).setDecoderMode(
          settings.decoderMode,
        );
        await (player as MediaKitPlayerService).setDriveOptimization(
          settings.externalDriveOptimization,
        );
      }
      if (isImage) {
        await _openImage(media, resolved, start);
      } else if (isPreloadedNext) {
        await pool.swapToNext();
      } else if (isPreloadedPrev) {
        await pool.swapToPrevious();
      } else {
        await player?.open(resolved, start: start);
      }
      _path = resolved;
      _openedMediaId = media.id;
      if (imageBytes == null) {
        if (!settings.rememberPosition &&
            (player?.position ?? Duration.zero) > Duration.zero) {
          await player?.seekTo(Duration.zero);
        }
        position = player?.position ?? start;
        duration = player?.duration ?? Duration.zero;
        _positionSaved = position.inSeconds ~/ 5;
        _bind();
        if (isPreloaded && player is MediaKitPlayerService) {
          // Android 后台软解先准备首帧，交接释放旧硬解后再启用前台硬解。
          await (player as MediaKitPlayerService).setDecoderMode(
            settings.decoderMode,
          );
        }
        await player?.setVolume(muted ? 0 : settings.defaultVolume);
        if (settings.autoplay) await player?.play();
        _playing = player?.isPlaying ?? false;
      } else {
        _playing = settings.autoplay;
        _startImageClock();
      }
      // 当前视频一开始播放就准备下一条，不等待会话写盘。
      _preloadNeighbors();
      await store?.db.stateDao.incrementPlayCount(media.id);
      await _saveSession();
    } catch (e) {
      await _recover('视频打开失败：$e', skip: e is! TimeoutException);
    } finally {
      busy = false;
      _notify();
    }
  }

  void _preloadNeighbors() {
    if (!pool.preloadEnabled ||
        !settings.preloadNext ||
        isImage ||
        error != null) {
      return;
    }
    final generation = _preloadGeneration;
    final nextId =
        queue.nextId ??
        (settings.loopQueue
            ? queue.prepareNextRound(reshuffle: _shuffleRound)
            : null);
    final next = _media[nextId];
    if (next != null &&
        !SourceScanner.imageExtensions.contains(next.extension)) {
      _preloadMediaId = next.id;
      _preloadTask = () async {
        try {
          final nextPath = await sourceManager?.resolveMediaPath(next);
          if (nextPath != null &&
              !_disposed &&
              generation == _preloadGeneration) {
            if (pool.nextPlayer is MediaKitPlayerService) {
              final spare = pool.nextPlayer as MediaKitPlayerService;
              await spare.setDecoderMode(
                pool.softwarePreload ? 'no' : settings.decoderMode,
              );
              await spare.setDriveOptimization(
                settings.externalDriveOptimization,
              );
            }
            final nextStart = await _resumePosition(next.id);
            if (!_disposed && generation == _preloadGeneration) {
              await pool.preloadNext(nextPath, start: nextStart);
            }
          }
        } catch (_) {}
      }();
    }
  }
}
