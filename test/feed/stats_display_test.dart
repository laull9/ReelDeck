import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/feed/feed_screen.dart';
import 'package:reel_deck/feed/widgets/formatters.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

import '../support/fake_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatFileSize 格式化工具', () {
    test('正确转换不同量级文件大小', () {
      expect(formatFileSize(0), '0 B');
      expect(formatFileSize(-10), '0 B');
      expect(formatFileSize(512), '512 B');
      expect(formatFileSize(1024), '1.0 KB');
      expect(formatFileSize(1536), '1.5 KB');
      expect(formatFileSize(1024 * 1024), '1.0 MB');
      expect(formatFileSize((45.5 * 1024 * 1024).round()), '45.5 MB');
      expect(formatFileSize((1.75 * 1024 * 1024 * 1024).round()), '1.75 GB');
    });
  });

  group('统计信息配置与持久化', () {
    late Directory tempDir;
    late File settingsFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('stats_test_');
      settingsFile = File('${tempDir.path}/settings.json');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('统计开关配置可更新并保存到文件', () async {
      final settings = AppSettings();
      await settings.load(settingsFile);

      expect(settings.showFileSize, isTrue);
      expect(settings.showQueueProgress, isTrue);
      expect(settings.showVideoFormat, isTrue);

      settings.update(
        showFileSize: false,
        showQueueProgress: false,
        showVideoFormat: false,
      );
      await settings.flushed;

      final reloaded = AppSettings();
      await reloaded.load(settingsFile);

      expect(reloaded.showFileSize, isFalse);
      expect(reloaded.showQueueProgress, isFalse);
      expect(reloaded.showVideoFormat, isFalse);
    });
  });

  group('FeedScreen 统计信息渲染及手动关闭', () {
    testWidgets('队列进度徽标与文件元数据正常显示，开关关闭后隐藏', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late Directory tempDir;
      late AppDatabase db;
      late LibraryStore store;
      late SourceManager sources;
      late FeedController feed;
      final settings = AppSettings();

      await tester.runAsync(() async {
        tempDir = await Directory.systemTemp.createTemp('stats_widget_test_');
        final testFile = File('${tempDir.path}/sample_video.mp4');
        final raf = await testFile.open(mode: FileMode.write);
        await raf.truncate(52428800); // 快速稀疏生成 50MB
        await raf.close();

        db = AppDatabase.forTesting(NativeDatabase.memory());
        store = LibraryStore(db);
        sources = SourceManager(store: store);
        final source = Source(
          id: 1,
          name: '测试',
          locator: tempDir.path,
          lastKnownPath: tempDir.path,
          platform: 'test',
          enabled: true,
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
          await db.close();
          if (await tempDir.exists()) await tempDir.delete(recursive: true);
        });
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settings),
            ChangeNotifierProvider.value(value: sources),
            ChangeNotifierProvider.value(value: feed),
          ],
          child: const MaterialApp(home: FeedScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('50.0 MB'), findsOneWidget);
      expect(find.text('MP4'), findsOneWidget);

      settings.update(showFileSize: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('50.0 MB'), findsNothing);
      expect(find.text('MP4'), findsOneWidget);
      expect(find.text('1 / 1'), findsOneWidget);

      settings.update(showQueueProgress: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('1 / 1'), findsNothing);
      expect(find.text('MP4'), findsOneWidget);

      settings.update(showVideoFormat: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('MP4'), findsNothing);

      settings.update(
        showFileSize: true,
        showQueueProgress: true,
        showVideoFormat: true,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('50.0 MB'), findsOneWidget);
      expect(find.text('MP4'), findsOneWidget);
    });
  });
}
