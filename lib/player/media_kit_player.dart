import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Rect;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
// 2.0.1 的 Surface 重建与恢复定位共用此锁。
// ignore: implementation_imports
import 'package:media_kit_video/src/video_controller/android_video_controller/android_video_controller.dart';

import 'player_service.dart';
import 'playback_ready.dart';
import 'native_properties.dart';
import 'playback_errors.dart';

class MediaKitPlayerService implements PlayerService {
  late final Player _player;
  late final VideoController _controller;
  late final Future<void> _initialization;
  String _automaticHwdec = 'auto';
  String? _currentPath;
  NativeProperties? _properties;
  final presentationReady = ValueNotifier<bool>(false);

  VideoController get controller => _controller;

  MediaKitPlayerService({String decoderMode = 'auto'}) {
    _player = Player(
      configuration: PlayerConfiguration(
        bufferSize: Platform.isAndroid ? 8 * 1024 * 1024 : 32 * 1024 * 1024,
      ),
    );
    _controller = VideoController(
      _player,
      // 软解仍通过 GPU 显示。Android 默认配置保留模拟器检测和软解回退。
      configuration: const VideoControllerConfiguration(),
    );
    _initialization = _initialize(decoderMode);
    unawaited(_initialization.then<void>((_) {}, onError: (Object _) {}));
  }

  Future<void> _initialize(String decoderMode) async {
    final platform = await _controller.platform.future.timeout(
      const Duration(seconds: 12),
    );
    _automaticHwdec = platform.configuration.hwdec ?? 'auto';
    if (_player.platform case final NativePlayer native) {
      // 精确定位必须与画面交接的位置检查一致，不能退回前一个关键帧。
      final properties = _properties = NativeProperties(native);
      await properties.set('hr-seek', 'yes');
      await properties.set('hr-seek-framedrop', 'yes');
      await properties.set(
        'vd-lavc-threads',
        Platform.numberOfProcessors.clamp(2, 4).toString(),
      );
      // 本地文件使用内存缓存，避免播放器重复写磁盘缓存。
      await properties.set('cache-on-disk', 'no');
      await _applyDecoderMode(decoderMode);
    }
  }

  Future<void> _applyDecoderMode(String mode) => _properties!.set(
    'hwdec',
    mode == 'no'
        ? 'no'
        : mode == 'auto-safe' && !Platform.isAndroid
        ? 'auto-safe'
        : _automaticHwdec,
  );

  Future<void> setDecoderMode(String mode) async {
    await _initialization.timeout(const Duration(seconds: 12));
    if (_properties != null) await _applyDecoderMode(mode);
  }

  Future<void> setDriveOptimization(bool enabled) async {
    await _initialization.timeout(const Duration(seconds: 12));
    if (_properties case final properties?) {
      await properties.set(
        'demuxer-max-bytes',
        enabled ? '8388608' : '33554432',
      );
      await properties.set('demuxer-max-back-bytes', enabled ? '0' : '8388608');
    }
  }

  Future<void> releaseMedia() async {
    presentationReady.value = false;
    _currentPath = null;
    await _player.stop().timeout(const Duration(seconds: 12));
  }

  Future<void> setRate(double rate) =>
      _player.setRate(rate).timeout(const Duration(seconds: 12));
  bool get isBuffering => _player.state.buffering;
  Stream<String> get errors =>
      _player.stream.log.where(isFatalPlaybackLog).map((log) => log.text);

  @override
  Future<void> open(String path, {Duration start = Duration.zero}) async {
    presentationReady.value = false;
    _currentPath = null;
    final deadline = PlaybackDeadline();
    await deadline.wait(_initialization);
    final previousSurface = _controller.notifier.value;
    final previousWid = previousSurface is AndroidVideoController
        ? previousSurface.wid.value
        : null;
    final previousRect = previousSurface?.rect.value;
    final loaded = Completer<void>();
    final subscriptions = <StreamSubscription<dynamic>>[
      _player.stream.videoParams.listen((params) {
        if ((params.dw ?? 0) > 0 &&
            (params.dh ?? 0) > 0 &&
            !loaded.isCompleted) {
          loaded.complete();
        }
      }),
      errors.listen((message) {
        if (!loaded.isCompleted) loaded.completeError(StateError(message));
      }),
    ];
    unawaited(loaded.future.then<void>((_) {}, onError: (Object _) {}));
    try {
      await deadline.wait(_player.open(Media(path, start: start), play: false));
      await deadline.wait(loaded.future);
      final platform = await deadline.wait(_controller.platform.future);
      var resume = start;
      if (platform is AndroidVideoController) {
        await deadline.wait(
          _waitForSurface(platform, previousWid, previousRect),
        );
        await deadline.wait(
          platform.lock.synchronized(() async {
            final length = _player.state.duration;
            resume = length > Duration.zero && start >= length
                ? Duration.zero
                : start;
            await _player.seek(resume);
          }),
        );
      } else if (_player.state.duration > Duration.zero &&
          start >= _player.state.duration) {
        resume = Duration.zero;
        await deadline.wait(_player.seek(resume));
      }
      if (_properties case final properties?) {
        await deadline.wait(
          waitForPlaybackReady(getProperty: properties.get, position: resume),
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
  Future<void> play() => _player.play().timeout(const Duration(seconds: 12));
  @override
  Future<void> pause() => _player.pause().timeout(const Duration(seconds: 12));
  @override
  Future<void> seekTo(Duration position) async {
    final deadline = PlaybackDeadline();
    await deadline.wait(_player.seek(position));
    if (_properties case final properties?) {
      await deadline.wait(
        waitForPlaybackReady(
          getProperty: properties.get,
          position: position,
          playbackRate: isPlaying ? _player.state.rate : 0,
        ),
      );
    }
  }

  @override
  Future<void> setVolume(double volume) => _player
      .setVolume(volume.clamp(0, 1) * 100)
      .timeout(const Duration(seconds: 12));
  @override
  Future<void> dispose() async {
    _currentPath = null;
    await _properties?.close();
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
