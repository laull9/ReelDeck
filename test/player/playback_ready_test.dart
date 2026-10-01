import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/player/playback_ready.dart';

void main() {
  test('旧帧位置和 seek 未结束时继续等待，输出就绪后才交接', () async {
    var poll = 0;
    await waitForPlaybackReady(
      position: const Duration(seconds: 20),
      getProperty: (property) async {
        if (property == 'seeking') {
          poll++;
          return poll == 2 ? 'yes' : 'no';
        }
        if (property == 'vo-configured') return 'yes';
        return poll < 3 ? '0' : '20.04';
      },
    );
    expect(poll, 3);
  });

  test('没有视频输出时超时退出，不永久卡住切换队列', () async {
    await expectLater(
      waitForPlaybackReady(
        position: Duration.zero,
        timeout: const Duration(milliseconds: 1),
        getProperty: (_) async => 'no',
      ),
      throwsA(isA<TimeoutException>()),
    );
  });
}
