import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/feed/feed_gestures.dart';
import 'package:reel_deck/feed/feed_screen.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/queue/queue_engine.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

import '../support/fake_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppDatabase db;
  late SourceManager sources;
  late FeedController feed;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('reeldeck-navigation');
    for (final name in ['a', 'b', 'c']) {
      await File('${directory.path}/$name.mp4').writeAsString('fixture');
    }
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final store = LibraryStore(db);
    sources = SourceManager(store: store);
    final source = Source(
      id: 1,
      name: '测试',
      locator: directory.path,
      lastKnownPath: directory.path,
      platform: 'test',
    );
    await store.saveSource(source);
    sources.addSource(source);
    await sources.scanSource(source);
    feed = FeedController(
      queue: QueueEngine(random: Random(42)),
      store: store,
      sourceManager: sources,
      pool: PlayerPool(playerFactory: FakePlayerService.new),
    );
    await feed.initialize();
    await feed.settled;
  });
  tearDown(() async {
    await feed.close();
    sources.dispose();
    feed.settings.dispose();
    await db.close();
    await directory.delete(recursive: true);
  });

  Future<void> showFeed(WidgetTester tester) => tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: feed),
        ChangeNotifierProvider.value(value: sources),
      ],
      child: const MaterialApp(home: FeedScreen()),
    ),
  );

  Future<void> wheel(WidgetTester tester, double delta) async {
    await tester.runAsync(
      () => tester.sendEventToBinding(
        PointerScrollEvent(
          position: const Offset(400, 300),
          scrollDelta: Offset(0, delta),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.runAsync(() => feed.settled);
    await tester.pumpAndSettle();
  }

  testWidgets('首次向下滚动切到随机队列下一条，向上回到原来一条', (tester) async {
    await showFeed(tester);
    final first = feed.currentMediaId;
    final next = feed.queue.nextId;
    expect(next, isNot(first));
    expect(feed.canGoPrevious, false);
    await wheel(tester, 80);
    expect(feed.currentMediaId, next);
    expect(feed.displayedMediaId, next);
    expect(feed.canGoPrevious, true);
    await wheel(tester, -80);
    expect(feed.currentMediaId, first);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('macOS 触控板拉出下方下一条，反向拉回上方上一条', (tester) async {
    await showFeed(tester);
    final first = feed.currentMediaId;
    final next = feed.queue.nextId;
    Future<void> pan(double delta) async {
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      const origin = Offset(400, 300);
      await tester.runAsync(() async {
        await gesture.panZoomStart(origin);
        await gesture.panZoomUpdate(origin, pan: Offset(0, delta / 2));
        await gesture.panZoomUpdate(origin, pan: Offset(0, delta));
        await gesture.panZoomEnd();
      });
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.runAsync(() => feed.settled);
      await tester.pumpAndSettle();
    }

    await pan(-180);
    expect(feed.currentMediaId, next);
    await pan(180);
    expect(feed.currentMediaId, first);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('没有上一条只轻拉回弹，不离场、不重开也不新增播放记录', (tester) async {
    await showFeed(tester);
    final first = feed.currentMediaId;
    final player = feed.player as FakePlayerService;
    final opens = player.opens;
    final plays = (await tester.runAsync(() => db.stateDao.getState(first!)))!
        .playCount;
    final handler = find.byType(FeedGestureHandler);
    final gesture = await tester.startGesture(const Offset(400, 300));
    await gesture.moveBy(const Offset(0, 400));
    await tester.pump();
    final transform = tester.widget<Transform>(
      find.descendant(of: handler, matching: find.byType(Transform)).first,
    );
    expect(transform.transform.storage[13], inInclusiveRange(0, 72));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(feed.currentMediaId, first);
    expect(player.opens, opens);
    expect(
      (await tester.runAsync(() => db.stateDao.getState(first!)))!.playCount,
      plays,
    );
    final settled = tester.widget<Transform>(
      find.descendant(of: handler, matching: find.byType(Transform)).first,
    );
    expect(settled.transform.storage[13], 0);
    // 边界上的滚轮也不会阻塞紧接着反向进入下一条。
    await wheel(tester, -80);
    await wheel(tester, 80);
    expect(feed.currentMediaId, isNot(first));
    await tester.pumpWidget(const SizedBox());
  });

  test('只有一条时上下均无切换目标，非循环末项也不能下滑重播自己', () async {
    await feed.toggleFavorite();
    await feed.setScope('favorites');
    expect(feed.canGoNext, false);
    expect(feed.canGoPrevious, false);
    await feed.setScope('all');
    feed.settings.update(loopQueue: false);
    await feed.next();
    await feed.next();
    expect(feed.canGoNext, false);
    expect(feed.canGoPrevious, true);
  });
}
