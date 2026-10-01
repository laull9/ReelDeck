import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Rect;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
// 按 2.0.1 的 Surface 锁排序恢复操作，避免 seek 与输出重建交错。
// ignore: implementation_imports
import 'package:media_kit_video/src/video_controller/android_video_controller/android_video_controller.dart';

import 'player_service.dart';
import 'playback_ready.dart';

class MediaKitPlayerService implements PlayerService {
  late final Player _player;
  late final VideoController _controller;
  String? _currentPath;
  final presentationReady = ValueNotifier<bool>(false);

  VideoController get controller => _controller;

  MediaKitPlayerService() {
    _player = Player(
      configuration: PlayerConfiguration(
        bufferSize: Platform.isAndroid ? 8 * 1024 * 1024 : 32 * 1024 * 1024,
      ),
    );
    _controller = VideoController(
      _player,
      // 使用库的安全硬解选择，保留模拟器和不支持编码的回退路径。
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );
  }

  Future<void> setDriveOptimization(bool enabled) async {
    if (_player.platform case final NativePlayer native) {
      await native.setProperty(
        'demuxer-max-bytes',
        enabled ? '8388608' : '33554432',
      );
      await native.setProperty(
        'demuxer-max-back-bytes',
        enabled ? '0' : '8388608',
      );
    }
  }

  Future<void> releaseMedia() async {
    presentationReady.value = false;
    _currentPath = null;
    await _player.stop();
  }

  Future<void> setRate(double rate) => _player.setRate(rate);
  Stream<String> get errors => _player.stream.error;

  @override
  Future<void> open(String path, {Duration start = Duration.zero}) async {
    presentationReady.value = false;
    _currentPath = null;
    final previousSurface = _controller.notifier.value;
    final previousWid = previousSurface is AndroidVideoController
        ? previousSurface.wid.value
        : null;
    final previousRect = previousSurface?.rect.value;
    final loaded = Completer<void>();
    final subscriptions = <StreamSubscription<dynamic>>[];
    subscriptions.add(
      _player.stream.videoParams.listen((params) {
        if ((params.dw ?? 0) > 0 &&
            (params.dh ?? 0) > 0 &&
            !loaded.isCompleted) {
          loaded.complete();
        }
      }),
    );
    subscriptions.add(
      errors.listen((message) {
        if (!loaded.isCompleted) loaded.completeError(StateError(message));
      }),
    );
    // 立即挂接错误处理，避免 open 返回前的错误变成未处理异常。
    final loadResult = loaded.future.timeout(const Duration(seconds: 12));
    unawaited(loadResult.then<void>((_) {}, onError: (Object _) {}));
    try {
      await _player.open(Media(path, start: start), play: false);
      await loadResult;
      final platform = await _controller.platform.future;
      var resume = start;
      if (platform is AndroidVideoController) {
        await _waitForSurface(platform, previousWid, previousRect);
        // videoParams 和 wid 共用锁，恢复操作等 Surface 重建结束后执行。
        await platform.lock.synchronized(() async {
          final length = _player.state.duration;
          resume = length > Duration.zero && start >= length
              ? Duration.zero
              : start;
          await _player.seek(resume);
        });
      } else if (_player.state.duration > Duration.zero &&
          start >= _player.state.duration) {
        resume = Duration.zero;
        await _player.seek(resume);
      }
      if (_player.platform case final NativePlayer native) {
        await waitForPlaybackReady(
          getProperty: native.getProperty,
          position: resume,
        );
      }
      _currentPath = path;
      presentationReady.value = true;
    } finally {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    }
  }

  Future<void> _waitForSurface(
    AndroidVideoController platform,
    int? previousWid,
    Rect? previousRect,
  ) async {
    final params = _player.state.videoParams;
    final rotated = params.rotate == 90 || params.rotate == 270;
    final width = rotated ? params.dh : params.dw;
    final height = rotated ? params.dw : params.dh;
    final resized =
        previousRect?.width != width || previousRect?.height != height;
    bool ready() =>
        platform.wid.value != null &&
        platform.wid.value != 0 &&
        platform.rect.value?.width == width &&
        platform.rect.value?.height == height &&
        (!resized || platform.wid.value != previousWid);
    if (ready()) return;
    final result = Completer<void>();
    void check() {
      if (ready() && !result.isCompleted) result.complete();
    }

    platform.wid.addListener(check);
    platform.rect.addListener(check);
    try {
      check();
      await result.future.timeout(const Duration(seconds: 12));
    } finally {
      platform.wid.removeListener(check);
      platform.rect.removeListener(check);
    }
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
    if (_player.platform case final NativePlayer native) {
      await waitForPlaybackReady(
        getProperty: native.getProperty,
        position: position,
      );
    }
  }

  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 1) * 100);
  @override
  Future<void> dispose() async {
    _currentPath = null;
    await _player.dispose();
    presentationReady.dispose();
  }

  @override
  bool get isPlaying => _player.state.playing;
  @override
  Duration get position => _player.state.position;
  @override
  Duration get duration => _player.state.duration;
  @override
  String? get currentPath => _currentPath;
  @override
  Stream<Duration> get positionStream => _player.stream.position;
  @override
  Stream<bool> get playingStream => _player.stream.playing;
  @override
  Stream<Duration> get durationStream => _player.stream.duration;
  @override
  Stream<bool> get completedStream => _player.stream.completed;
}
