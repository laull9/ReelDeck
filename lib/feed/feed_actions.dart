part of 'feed_controller.dart';

extension FeedActions on FeedController {
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
      await _savePosition();
      _reconcileQueue();
      await _open();
    }
  });
  Future<void> hideCurrentVideo() => _run(() async {
    final id = currentMediaId;
    if (id == null) return;
    await _savePosition();
    await store?.db.stateDao.setHidden(id, true);
    _hidden.add(id);
    _reconcileQueue();
    await _open();
  });
  Future<void> hideCurrentFolder() => _run(() async {
    final media = currentMedia;
    if (media == null || store == null) return;
    await _savePosition();
    await store!.hideFolder(media.sourceId, p.dirname(media.relativePath));
    _rules = await store!.rules();
    _reconcileQueue();
    await _open();
  });
  Future<void> resetHidden() => _run(() async {
    await _savePosition();
    await store?.resetHidden();
    _hidden.clear();
    _rules.clear();
    _reconcileQueue();
    await _open();
  });
  void toggleInfo() {
    _showInfo = !_showInfo;
    _notify();
  }

  void toggleOverlay() => toggleInfo();
  void cycleVideoFit() {
    final next = switch (videoFit) {
      'fit' => 'fill',
      'fill' => 'original',
      _ => 'fit',
    };
    settings.update(videoFit: next);
  }

  Future<void> toggleFullscreen() => _run(() async {
    fullscreen
        ? await defaultExitNativeFullscreen()
        : await defaultEnterNativeFullscreen();
    fullscreen = !fullscreen;
  });
  void exitFullscreen() {
    if (fullscreen) toggleFullscreen();
  }

  void setSpeed(double rate) {
    final active = player;
    _imageRate = rate;
    if (active is MediaKitPlayerService) _run(() => active.setRate(rate));
  }

  Future<void> toggleMute() => _run(() async {
    muted = !muted;
    await player?.setVolume(muted ? 0 : settings.defaultVolume);
  });

  Future<void> revealCurrent() => _run(() async {
    final media = currentMedia;
    if (media != null) await sourceManager?.fileAction(media, 'reveal');
  });

  Future<void> trashCurrent(int expectedId) => _run(() async {
    final media = currentMedia;
    if (media == null || media.id != expectedId) return;
    await player?.pause();
    _pauseImage();
    await _savePosition();
    await _unbind();
    // Windows 上关闭文件句柄后，回收站才能移动媒体。
    if (player is MediaKitPlayerService) {
      await (player as MediaKitPlayerService).releaseMedia();
    }
    try {
      await sourceManager?.fileAction(media, 'trash');
    } catch (e) {
      await _open();
      rethrow;
    }
  });
}
