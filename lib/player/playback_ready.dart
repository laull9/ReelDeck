import 'dart:async';

/// 初始化、打开文件和画面交接共享同一份等待预算。
class PlaybackDeadline {
  PlaybackDeadline({this.timeout = const Duration(seconds: 12)});

  final Duration timeout;
  final Stopwatch _watch = Stopwatch()..start();

  Future<T> wait<T>(Future<T> operation) => operation.timeout(
    timeout - _watch.elapsed > Duration.zero
        ? timeout - _watch.elapsed
        : Duration.zero,
  );
}

/// 文件参数就绪后等待 seek 和视频输出；播放中的定位按倍速放宽自然前进距离。
Future<void> waitForPlaybackReady({
  required Future<String> Function(String) getProperty,
  required Duration position,
  double playbackRate = 0,
  Duration timeout = const Duration(seconds: 12),
}) async {
  final deadline = PlaybackDeadline(timeout: timeout);
  final watch = Stopwatch()..start();
  while (true) {
    final seeking = await deadline.wait(getProperty('seeking'));
    final output = await deadline.wait(getProperty('vo-configured'));
    final seconds = double.tryParse(
      await deadline.wait(getProperty('time-pos')),
    );
    if (output == 'yes' &&
        seeking == 'no' &&
        (position == Duration.zero ||
            (seconds != null &&
                seconds >= position.inMilliseconds / 1000 - 0.35 &&
                seconds <=
                    position.inMilliseconds / 1000 +
                        0.35 +
                        watch.elapsedMicroseconds / 1e6 * playbackRate))) {
      return;
    }
    await deadline.wait(Future<void>.delayed(const Duration(milliseconds: 50)));
  }
}
