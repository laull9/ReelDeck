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

/// 文件参数就绪后，等待 seek 和视频输出完成，避免展示旧帧。
Future<void> waitForPlaybackReady({
  required Future<String> Function(String) getProperty,
  required Duration position,
  Duration timeout = const Duration(seconds: 12),
}) async {
  final deadline = PlaybackDeadline(timeout: timeout);
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
                (seconds - position.inMilliseconds / 1000).abs() < 0.35))) {
      return;
    }
    await deadline.wait(Future<void>.delayed(const Duration(milliseconds: 50)));
  }
}
