import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_gestures.dart';
import 'package:reel_deck/feed/widgets/progress_bar.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';
import '../support/fake_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedProgressBar 进度条丝滑拖动与快进测试', () {
    testWidgets('水平拖拽平滑触发 scrubStart、scrubUpdate 与 scrubEnd，点击直接触发 onSeek',
        (tester) async {
      Duration? started;
      Duration? scrubbed;
      Duration? ended;
      Duration? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                child: FeedProgressBar(
                  position: const Duration(seconds: 10),
                  duration: const Duration(seconds: 100),
                  onScrubStart: () => started = const Duration(seconds: 10),
                  onScrub: (pos) => scrubbed = pos,
                  onScrubEnd: (pos) => ended = pos,
                  onSeek: (pos) => tapped = pos,
                ),
              ),
            ),
          ),
        ),
      );

      // 单击 50% 处，应定位至 50 秒
      await tester.tapAt(tester.getCenter(find.byType(FeedProgressBar)));
      await tester.pumpAndSettle();
      expect(tapped, isNotNull);
      expect((tapped!.inSeconds - 50).abs() <= 2, isTrue);

      // 拖拽手势：从左向右平滑拖拽
      final origin = tester.getTopLeft(find.byType(FeedProgressBar)) +
          const Offset(10, 10);
      final gesture = await tester.startGesture(origin);
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      expect(started, isNotNull);

      // 移动到 80% 宽度处
      await gesture.moveTo(origin + const Offset(140, 0));
      await tester.pump();
      expect(scrubbed, isNotNull);
      expect(scrubbed!.inSeconds > 50, isTrue);

      // 抬起手指，触发 scrubEnd
      await gesture.up();
      await tester.pumpAndSettle();
      expect(ended, isNotNull);
      expect(ended!.inSeconds > 50, isTrue);
    });
  });

  group('FeedController 拖动流控优化测试', () {
    test('拖拽中 positionStream 不覆盖拖拽位置，多次连续 scrub 只保留最新位置并节流', () async {
      final folder = await Directory.systemTemp.createTemp('reeldeck-scrub-test');
      final file = File('${folder.path}/test.mp4');
      await file.writeAsString('mock');

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final store = LibraryStore(db);
      final sources = SourceManager(store: store);
      final source = Source(
        id: 1,
        name: '测试',
        locator: folder.path,
        lastKnownPath: folder.path,
        platform: 'test',
      );
      await store.saveSource(source);
      sources.addSource(source);
      await sources.scanSource(source);

      final fakePlayer = FakePlayerService();
      final pool = PlayerPool(playerFactory: () => fakePlayer);
      final feed = FeedController(
        sourceManager: sources,
        store: store,
        pool: pool,
      );
      await feed.initialize();
      addTearDown(() async {
        await feed.close();
        sources.dispose();
        await db.close();
        await folder.delete(recursive: true);
      });

      expect(feed.currentPath, isNotNull);
      feed.startScrub();
      expect(feed.isScrubbing, isTrue);

      // 连续高频调用 scrubTo
      feed.scrubTo(const Duration(seconds: 15));
      expect(feed.position.inSeconds, 15);

      feed.scrubTo(const Duration(seconds: 35));
      expect(feed.position.inSeconds, 35);

      // 模拟底层播放器发来旧位置更新流，但由于正在 scrubbing，不会被旧进度覆盖
      fakePlayer.seekTo(const Duration(seconds: 5));
      expect(feed.position.inSeconds, 35);

      await feed.endScrub();
      expect(feed.isScrubbing, isFalse);
    });
  });

  group('FeedGestureHandler TikTok 式滑动动画', () {
    testWidgets('上下轻微滑动不触发翻页并弹性复位，大幅滑动触发丝滑过渡与切页', (tester) async {
      int nextCount = 0;
      int prevCount = 0;
      void noop() {}

      final gestureKey = GlobalKey<FeedGestureHandlerState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: FeedGestureHandler(
                key: gestureKey,
                onNext: () => nextCount++,
                onPrevious: () => prevCount++,
                onTogglePlayPause: noop,
                onToggleFavorite: noop,
                onSeekForward: noop,
                onSeekBackward: noop,
                onSeekForwardLarge: noop,
                onSeekBackwardLarge: noop,
                onHideVideo: noop,
                onHideFolder: noop,
                onReshuffle: noop,
                onToggleInfo: noop,
                child: const Center(child: Text('当前视频内容')),
              ),
            ),
          ),
        ),
      );

      // 1. 微小拖动：上滑 15 像素（小于阈值），松手后弹性复位，不触发翻页
      await tester.drag(find.text('当前视频内容'), const Offset(0, -15));
      await tester.pumpAndSettle();
      expect(nextCount, 0);
      expect(prevCount, 0);

      // 2. 较大幅度上滑（-180 像素）：触发向上过渡动画，动画完成后触发 onNext
      await tester.drag(find.text('当前视频内容'), const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(nextCount, 1);
      expect(prevCount, 0);

      // 3. 较大幅度下滑（180 像素）：触发向下过渡动画，动画完成后触发 onPrevious
      await tester.drag(find.text('当前视频内容'), const Offset(0, 180));
      await tester.pumpAndSettle();
      expect(nextCount, 1);
      expect(prevCount, 1);

      // 4. 程序化调用 animateNext 与 animatePrevious（如键盘/滚轮/点击下一条）
      gestureKey.currentState?.animateNext(600);
      await tester.pumpAndSettle();
      expect(nextCount, 2);

      gestureKey.currentState?.animatePrevious(600);
      await tester.pumpAndSettle();
      expect(prevCount, 2);
    });
  });
}
