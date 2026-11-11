// flutter test --no-pub scripts/native_decode_test.dart
// REELDECK_LIBMPV 可指定库路径；macOS 使用 run_native_decode_test.py 准备依赖。
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart';
import 'package:reel_deck/player/native_properties.dart';
import 'package:reel_deck/player/playback_errors.dart';
import 'package:reel_deck/player/playback_ready.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(libmpv: Platform.environment['REELDECK_LIBMPV']);
  final folder = Directory('build/decode-stress').absolute;

  test('真实 libmpv：4K60 双播放器软解、定位与界面 isolate 心跳', () async {
    final players = [Player(), Player()];
    final properties = [
      for (final player in players)
        NativeProperties(player.platform as NativePlayer),
    ];
    final watch = Stopwatch()..start();
    var lastTick = Duration.zero;
    var longestGap = Duration.zero;
    var ticks = 0;
    final heartbeat = Timer.periodic(const Duration(milliseconds: 20), (_) {
      final now = watch.elapsed;
      final gap = now - lastTick;
      if (gap > longestGap) longestGap = gap;
      lastTick = now;
      ticks++;
    });
    try {
      for (final props in properties) {
        await props.set('vid', 'auto');
        await props.set('hwdec', 'no');
        await props.set('ao', 'null');
        await props.set('hr-seek', 'yes');
        await props.set('hr-seek-framedrop', 'yes');
        await props.set('vd-lavc-threads', '4');
        expect(await props.get('hwdec'), 'no');
      }
      for (var round = 0; round < 3; round++) {
        await Future.wait([
          for (var i = 0; i < players.length; i++)
            () async {
              final name = i == 0 ? 'h264-4k60' : 'hevc-4k60-10bit';
              await players[i].open(
                Media(
                  '${folder.path}/$name.mp4',
                  start: const Duration(seconds: 2),
                ),
                play: false,
              );
              try {
                await waitForPlaybackReady(
                  getProperty: properties[i].get,
                  position: const Duration(seconds: 2),
                );
              } catch (_) {
                for (final name in [
                  'seeking',
                  'vo-configured',
                  'time-pos',
                  'vid',
                ]) {
                  // ignore: avoid_print
                  print('NATIVE $i $name=${await properties[i].get(name)}');
                }
                rethrow;
              }
              await players[i].play();
            }(),
        ]).timeout(const Duration(seconds: 25));
        await Future<void>.delayed(const Duration(seconds: 2));
        for (var i = 0; i < players.length; i++) {
          expect(
            players[i].state.position,
            greaterThan(const Duration(seconds: 2)),
          );
          const target = Duration(milliseconds: 3123);
          await players[i].seek(target);
          await waitForPlaybackReady(
            getProperty: properties[i].get,
            position: target,
            playbackRate: 1,
          );
          await players[i].pause();
          expect(players[i].state.playing, false);
        }
      }
      expect(ticks, greaterThan(100));
      expect(longestGap, lessThan(const Duration(seconds: 1)));
      // ignore: avoid_print
      print(
        'NATIVE 4K60 PASS ticks=$ticks maxGap=${longestGap.inMilliseconds}ms',
      );
    } finally {
      heartbeat.cancel();
      for (var i = 0; i < players.length; i++) {
        await properties[i].close();
        await players[i].dispose();
      }
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('真实 libmpv：正常起播后穿过第 3 秒坏点，恢复视频并切换下一条', () async {
    final frames = await Directory.systemTemp.createTemp('reeldeck-frames');
    final player = Player(
      configuration: const PlayerConfiguration(vo: 'image'),
    );
    final props = NativeProperties(player.platform as NativePlayer);
    final errors = <PlayerLog>[];
    Duration? firstFaultAt;
    final subscription = player.stream.log.listen((log) {
      final decoder =
          log.prefix == 'vd' ||
          log.prefix == 'ad' ||
          log.prefix.startsWith('ffmpeg/video');
      if (isFatalPlaybackLog(log) || (log.level == 'error' && decoder)) {
        errors.add(log);
        firstFaultAt ??= player.state.position;
      }
    });
    try {
      await props.set('vid', 'auto');
      await props.set('hwdec', 'no');
      await props.set('ao', 'null');
      await props.set('cache-on-disk', 'no');
      await props.set('vo-image-outdir', frames.path);
      await props.set('vo-image-format', 'png');
      await player.open(Media('${folder.path}/midstream-corrupt.mp4'));
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(player.state.position, greaterThan(Duration.zero));
      expect(errors, isEmpty, reason: '开头必须可以正常播放');
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(errors, isNotEmpty, reason: '必须实际解码到中途损坏的视频包');
      expect(firstFaultAt, greaterThan(const Duration(seconds: 2)));
      expect(
        errors.where(isFatalPlaybackLog),
        isEmpty,
        reason: '坏帧后的有效视频仍可播放，不能直接当作致命错误',
      );
      expect(player.state.position, greaterThan(const Duration(seconds: 5)));
      final before = await frames.list().length;
      await Future<void>.delayed(const Duration(seconds: 1));
      final after = await frames.list().length;
      expect(before, greaterThan(0));
      expect(after, greaterThan(before), reason: '第 6–7 秒必须继续输出实际视频帧');
      await player.pause().timeout(const Duration(seconds: 3));
      expect(player.state.playing, false);
      await player.open(Media('${folder.path}/midstream-clean.mp4'));
      await Future<void>.delayed(const Duration(seconds: 1));
      expect(player.state.position, greaterThan(Duration.zero));
      expect(player.state.position, lessThan(const Duration(seconds: 2)));
      // ignore: avoid_print
      print(
        'MIDSTREAM PASS firstFault=$firstFaultAt '
        'errors=${errors.length} recoveredFrames=$before->$after',
      );
    } finally {
      await subscription.cancel();
      await props.close();
      await player.dispose();
      await frames.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('真实 libmpv：损坏文件后仍可打开正常文件并推进进度', () async {
    final player = Player();
    final props = NativeProperties(player.platform as NativePlayer);
    final fatal = <PlayerLog>[];
    final subscription = player.stream.log
        .where(isFatalPlaybackLog)
        .listen(fatal.add);
    try {
      await props.set('vid', 'auto');
      await props.set('hwdec', 'no');
      await props.set('ao', 'null');
      await props.set('vd-lavc-threads', '4');
      for (final name in ['invalid', 'truncated', 'damaged-frames']) {
        await player.open(Media('${folder.path}/$name.mp4'));
        await Future<void>.delayed(const Duration(seconds: 2));
        await player.pause().timeout(const Duration(seconds: 12));
        await player.open(Media('${folder.path}/h264-4k60.mp4'));
        await Future<void>.delayed(const Duration(seconds: 1));
        expect(player.state.position, greaterThan(Duration.zero));
      }
      expect(fatal, isNotEmpty, reason: '无效容器必须产生致命错误');
    } finally {
      await subscription.cancel();
      await props.close();
      await player.dispose();
    }
  }, timeout: const Timeout(Duration(minutes: 1)));
}
