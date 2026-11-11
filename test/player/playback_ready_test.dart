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
  test('原生属性查询不返回时仍按预算超时', () async {
    await expectLater(
      waitForPlaybackReady(
        position: Duration.zero,
        timeout: const Duration(milliseconds: 10),
        getProperty: (_) => Completer<String>().future,
      ),
      throwsA(isA<TimeoutException>()),
    );
  });

  for (final rate in [1.0, 2.0]) {
    test('播放中的 seek 按 $rate 倍速接受查询期间的自然前进', () async {
      final watch = Stopwatch()..start();
      await waitForPlaybackReady(
        position: const Duration(seconds: 20),
        playbackRate: rate,
        timeout: const Duration(seconds: 2),
        getProperty: (property) async {
          if (property == 'seeking') {
            await Future<void>.delayed(const Duration(milliseconds: 450));
            return 'no';
          }
          if (property == 'vo-configured') return 'yes';
          return '${20 + watch.elapsedMicroseconds / 1e6 * rate}';
        },
      );
    });
  }

  test('暂停定位仍拒绝离目标过远的旧画面', () async {
    await expectLater(
      waitForPlaybackReady(
        position: const Duration(seconds: 20),
        timeout: const Duration(milliseconds: 100),
        getProperty: (name) async => switch (name) {
          'seeking' => 'no',
          'vo-configured' => 'yes',
          _ => '22',
        },
      ),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('多个阶段共享预算，不为每个阶段重新计时', () async {
    final deadline = PlaybackDeadline(
      timeout: const Duration(milliseconds: 40),
    );
    await deadline.wait(Future<void>.delayed(const Duration(milliseconds: 25)));
    await expectLater(
      deadline.wait(Future<void>.delayed(const Duration(milliseconds: 25))),
      throwsA(isA<TimeoutException>()),
    );
  });
}
