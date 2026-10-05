import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/player/player_service.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

import '../support/fake_player.dart';

/// 损坏或高解码压力视频：停滞检测、预加载失败与打开期间的结束事件。
void main() {
  late Directory folder;
  late AppDatabase db;
  late LibraryStore store;
  late SourceManager sources;
  late AppSettings settings;
  FeedController? feed;

  Future<FeedController> createFeed(PlayerService Function() factory) async {
    final controller = FeedController(
      sourceManager: sources,
      store: store,
      settings: settings,
      pool: PlayerPool(playerFactory: factory),
    );
    await controller.initialize();
    await controller.settled;
    return feed = controller;
  }

  Future<void> waitFor(bool Function() condition) async {
    final watch = Stopwatch()..start();
    while (!condition()) {
      if (watch.elapsed > const Duration(seconds: 3)) fail('等待超时');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('reeldeck-recovery');
    for (final name in ['a.mp4', 'b.mp4', 'c.mp4']) {
      await File('${folder.path}/$name').writeAsString('fixture');
    }
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = LibraryStore(db);
    settings = AppSettings()..update(queueOrder: 'oldest');
    sources = SourceManager(store: store);
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
  });

  tearDown(() async {
    await feed?.close();
    feed = null;
    sources.dispose();
    await db.close();
    await folder.delete(recursive: true);
  });

  test('播放中进度长时间不动判定为解码停滞，记录错误并跳过', () async {
    final controller = await createFeed(FakePlayerService.new);
    controller.stallTimeout = const Duration(milliseconds: 100);
    await controller.next();
    final stalled = controller.currentMediaId;
    await waitFor(() => controller.lastPlaybackError != null);
    await controller.settled;
    expect(controller.lastPlaybackError, contains('解码停滞'));
    expect(controller.currentMediaId, isNot(stalled));
    expect(controller.busy, false);
  });

  test('暂停或进度前进时不触发停滞检测', () async {
    final controller = await createFeed(FakePlayerService.new);
    controller.stallTimeout = const Duration(milliseconds: 100);
    await controller.next();
    final id = controller.currentMediaId;
    for (var i = 1; i <= 8; i++) {
      await controller.player!.seekTo(Duration(seconds: i));
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
    await controller.togglePlayPause();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(controller.lastPlaybackError, isNull);
    expect(controller.currentMediaId, id);
  });

  test('预加载发现文件损坏，滑到该视频时直接跳过，不再等待解码', () async {
    var created = 0;
    final broken = FakePlayerService()..failOpen = true;
    final controller = await createFeed(
      () => created++ == 0 ? FakePlayerService() : broken,
    );
    final ids = List.of(controller.queue.queue);
    await controller.next();
    await controller.settled;
    expect(controller.queue.queue, isNot(contains(ids[1])));
    expect(controller.lastPlaybackError, contains('损坏的视频'));
    expect(controller.currentMediaId, ids[2]);
    expect(controller.busy, false);
    expect(controller.error, isNull);
  });

  test('打开期间新视频立即结束，不丢失结束事件', () async {
    var created = 0;
    final ending = CompleteOnPlayPlayer();
    final controller = await createFeed(
      () => created++ == 0 ? FakePlayerService() : ending,
    );
    final ids = List.of(controller.queue.queue);
    ending.completeOnPlay = true;
    await controller.next();
    await waitFor(() => controller.currentMediaId == ids[2]);
    await controller.settled;
    expect(controller.currentMediaId, ids[2]);
  });

  test('自动播完进入预加载视频后，新视频的进度正常保存', () async {
    final controller = await createFeed(FakePlayerService.new);
    final ids = List.of(controller.queue.queue);
    (controller.player as FakePlayerService).complete();
    await waitFor(() => controller.currentMediaId == ids[1]);
    await controller.settled;
    // 由播放器自身推进进度，不经过会重置结束标记的 seekTo。
    await controller.player!.seekTo(const Duration(seconds: 20));
    await controller.next();
    expect((await db.stateDao.getState(ids[1]))!.lastPosition, 20000);
  });
}

class CompleteOnPlayPlayer extends FakePlayerService {
  bool completeOnPlay = false;
  @override
  Future<void> play() async {
    await super.play();
    if (completeOnPlay) {
      completeOnPlay = false;
      complete();
    }
  }
}
