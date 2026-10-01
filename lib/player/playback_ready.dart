import 'dart:async';

/// 文件参数就绪后，等待 seek 和视频输出完成，避免展示旧帧。
Future<void> waitForPlaybackReady({
  required Future<String> Function(String) getProperty,
  required Duration position,
  Duration timeout = const Duration(seconds: 12),
}) async {
  final watch = Stopwatch()..start();
  while (watch.elapsed < timeout) {
    final seeking = await getProperty('seeking');
    final output = await getProperty('vo-configured');
    final seconds = double.tryParse(await getProperty('time-pos'));
    if (output == 'yes' &&
        seeking == 'no' &&
        (position == Duration.zero ||
            (seconds != null &&
                (seconds - position.inMilliseconds / 1000).abs() < 0.35))) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
  throw TimeoutException('视频画面未就绪', timeout);
}
