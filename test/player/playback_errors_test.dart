import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:reel_deck/player/playback_errors.dart';

void main() {
  test('音视频单帧解码错误与硬解回退不触发立即跳过', () {
    for (final prefix in ['ad', 'vd', 'ffmpeg/video']) {
      expect(
        isFatalPlaybackLog(
          PlayerLog(
            prefix: prefix,
            level: 'error',
            text: 'Error decoding frame.',
          ),
        ),
        false,
      );
    }
  });

  test('打不开文件、无法识别容器和 fatal 仍立即失败', () {
    for (final prefix in ['file', 'stream', 'cplayer']) {
      expect(
        isFatalPlaybackLog(
          PlayerLog(
            prefix: prefix,
            level: 'error',
            text: 'Failed to recognize file format.',
          ),
        ),
        true,
      );
    }
    expect(
      isFatalPlaybackLog(
        const PlayerLog(
          prefix: 'vd',
          level: 'fatal',
          text: 'Decoder initialization failed.',
        ),
      ),
      true,
    );
  });
}
