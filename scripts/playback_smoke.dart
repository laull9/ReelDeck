import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:drift/native.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';
import 'package:reel_deck/player/media_kit_player.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/player/video_player_widget.dart';

/// 由 prepare_playback_smoke.py 生成的入口调用；临时文件写入应用沙盒。
Future<void> runPlaybackSmoke(Map<String, Uint8List> fixtures) async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final directory = await Directory.systemTemp.createTemp('reeldeck-smoke');
  final pool = PlayerPool(
    preloadEnabled: true,
    softwarePreload: const bool.fromEnvironment('SOFTWARE_PRELOAD'),
  );
  await pool.initialize();
  final players = pool.players.cast<MediaKitPlayerService>();
  final activeIndex = ValueNotifier(0);
  runApp(
    MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: activeIndex,
          builder: (_, index, _) => IndexedStack(
            index: index,
            sizing: StackFit.expand,
            children: [
              for (final player in players) VideoPlayerWidget(player: player),
            ],
          ),
        ),
      ),
    ),
  );
  var result = 0;
  FeedController? feed;
  AppDatabase? db;
  SourceManager? sources;
  AppSettings? settings;
  var measuringSwitch = false;
  var switchShowedLoading = false;
  try {
    for (final fixture in fixtures.entries) {
      final file = File('${directory.path}/${fixture.key}.mp4');
      await file.writeAsBytes(fixture.value);
      final player = pool.currentPlayer as MediaKitPlayerService;
      await player.setVolume(0);
      final watch = Stopwatch()..start();
      await player.open(file.path, start: const Duration(seconds: 7));
      check(player.presentationReady.value, '首帧未就绪');
      check((player.position.inMilliseconds - 7000).abs() < 350, '恢复位置错误');
      check((player.controller.rect.value?.width ?? 0) > 0, 'Texture 尺寸无效');
      final native = player.controller.player.platform as NativePlayer;
      final hwdec = await native.getProperty('hwdec-current');
      debugPrint(
        'SMOKE ${fixture.key} open=${watch.elapsedMilliseconds}ms hwdec=$hwdec',
      );
      await player.play();
      await Future<void>.delayed(const Duration(seconds: 2));
      check(player.position > const Duration(seconds: 8), '播放位置未前进');
      debugPrint(
        'SMOKE ${fixture.key} position=${player.position} '
        'drops=${await native.getProperty('decoder-frame-drop-count')}',
      );
      await player.pause();
      await player.seekTo(const Duration(milliseconds: 7333));
      check((player.position.inMilliseconds - 7333).abs() < 350, '非关键帧跳转错误');
      final spare = pool.nextPlayer as MediaKitPlayerService;
      await spare.setDecoderMode(pool.softwarePreload ? 'no' : 'auto');
      await pool.preloadNext(file.path, start: const Duration(seconds: 17));
      if (pool.softwarePreload) {
        final spareNative = spare.controller.player.platform as NativePlayer;
        check(
          await spareNative.getProperty('hwdec-current') == 'no',
          '后台播放器占用了硬解',
        );
      }
      await pool.swapToNext();
      activeIndex.value = players.toList().indexOf(
        pool.currentPlayer as MediaKitPlayerService,
      );
      final next = pool.currentPlayer as MediaKitPlayerService;
      check((next.position.inMilliseconds - 17000).abs() < 350, '预加载位置错误');
      await next.setDecoderMode('auto');
      await next.play();
      await Future<void>.delayed(const Duration(seconds: 1));
      check(next.position > const Duration(milliseconds: 17500), '交接后未播放');
      await next.pause();
      await next.setDecoderMode('no');
      await next.open(file.path, start: const Duration(seconds: 7));
      final nextNative = next.controller.player.platform as NativePlayer;
      check(await nextNative.getProperty('hwdec-current') == 'no', '软解设置未生效');
      await next.play();
      await Future<void>.delayed(const Duration(seconds: 1));
      check(next.position > const Duration(milliseconds: 7500), '软解未播放');
      await next.pause();
      await next.setDecoderMode('auto');
    }
    final player = pool.currentPlayer as MediaKitPlayerService;
    final file = File('${directory.path}/${fixtures.keys.first}.mp4');
    await player.open(file.path, start: const Duration(hours: 1));
    check(player.position < const Duration(seconds: 1), '过期进度未从头开始');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final store = LibraryStore(db);
    sources = SourceManager(store: store);
    final source = Source(
      id: 1,
      name: '验收样本',
      locator: directory.path,
      lastKnownPath: directory.path,
      platform: 'test',
    );
    await store.saveSource(source);
    sources.addSource(source);
    await sources.scanSource(source);
    for (final media in sources.allMedia) {
      await db.stateDao.updatePosition(media.id, 7000);
    }
    settings = AppSettings()..update(defaultVolume: 0);
    feed = FeedController(
      sourceManager: sources,
      store: store,
      settings: settings,
      pool: pool,
    );
    feed.addListener(() {
      if (measuringSwitch && feed!.busy) switchShowedLoading = true;
      activeIndex.value = players.toList().indexOf(
        pool.currentPlayer as MediaKitPlayerService,
      );
    });
    await feed.initialize();
    // 不等待后台预加载完成就滑动，交接必须接管在途任务。
    await feed.next();
    await feed.settled;
    check(
      !feed.busy && feed.error == null && feed.isPlaying,
      'Feed 初始化失败：${feed.error}',
    );
    check((feed.position.inMilliseconds - 7000).abs() < 1000, 'Feed 恢复位置错误');
    for (var i = 0; i < 4; i++) {
      final prepared = pool.nextPlayer;
      final watch = Stopwatch()..start();
      measuringSwitch = true;
      switchShowedLoading = false;
      await feed.next();
      measuringSwitch = false;
      {
        check(identical(feed.player, prepared), '交接没有复用已准备的播放器');
        check(!switchShowedLoading, '预加载交接仍显示加载提示');
      }
      debugPrint(
        'SMOKE Feed switch=${watch.elapsedMilliseconds}ms spinner=$switchShowedLoading',
      );
      await feed.settled;
      check(
        !feed.busy && feed.error == null && feed.isPlaying,
        'Feed 切换失败：${feed.error}',
      );
    }
    await feed.suspend();
    settings.update(decoderMode: 'no');
    await feed.settled;
    check(!feed.busy && feed.error == null && !feed.isPlaying, '解码设置未保留暂停状态');
    debugPrint('SMOKE Feed startup/switch/settings PASS');
    debugPrint('SMOKE PASS');
  } catch (error, stack) {
    result = 1;
    debugPrint('SMOKE FAIL $error\n$stack');
  } finally {
    if (feed != null) {
      await feed.close();
    } else {
      await pool.dispose();
    }
    sources?.dispose();
    settings?.dispose();
    await db?.close();
    await directory.delete(recursive: true);
  }
  exit(result);
}

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}
