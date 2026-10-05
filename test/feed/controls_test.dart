import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/feed/feed_screen.dart';
import 'package:reel_deck/feed/widgets/progress_bar.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

import '../support/fake_player.dart';

void main() {
  testWidgets('窄屏播放控制、无浮层唤醒和回收站取消', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late Directory directory;
    late AppDatabase db;
    late SourceManager sources;
    late FeedController feed;
    final settings = AppSettings();
    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('reeldeck-controls');
      await File('${directory.path}/clip.mp4').create();
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
        sourceManager: sources,
        store: store,
        settings: settings,
        pool: PlayerPool(playerFactory: FakePlayerService.new),
      );
      await feed.initialize();
    });
    addTearDown(() async {
      await tester.runAsync(() async {
        await feed.close();
        sources.dispose();
        settings.dispose();
        await db.close();
        await directory.delete(recursive: true);
      });
    });
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sources),
          ChangeNotifierProvider.value(value: feed),
          ChangeNotifierProvider.value(value: settings),
        ],
        child: const MaterialApp(home: FeedScreen()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('clip.mp4'), findsOneWidget);
    // 窄屏控制栏保持单行，音量不被挤到下一行。
    final play = tester.getCenter(find.byTooltip('暂停'));
    final volume = tester.getCenter(find.byTooltip('静音'));
    expect((volume.dy - play.dy).abs(), lessThan(1));
    // 控制栏按钮水平居中。
    final prevLeft = tester.getTopLeft(find.byTooltip('上一条')).dx;
    final volRight = tester.getTopRight(find.byTooltip('静音')).dx;
    expect(((prevLeft + volRight) / 2 - 160).abs(), lessThan(1));
    await tester.tap(find.byTooltip('更多操作'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('移入回收站'));
    await tester.pumpAndSettle();
    expect(find.text('移入系统回收站？'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(sources.allMedia, hasLength(1));
    expect(feed.currentPath, isNotNull);
    settings.update(overlayMode: 'none');
    await tester.pump();
    expect(find.byType(FeedProgressBar), findsNothing);
    await tester.tapAt(const Offset(160, 200));
    await tester.pump(const Duration(milliseconds: 350));
    expect(feed.isPlaying, isTrue);
    expect(find.byType(FeedProgressBar), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(FeedProgressBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
