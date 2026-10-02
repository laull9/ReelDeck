import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';
import 'package:reel_deck/sources/platform/storage_bridge.dart';

import '../support/fake_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory folder;
  late AppDatabase db;
  late LibraryStore store;
  late SourceManager sources;
  late FeedController feed;
  late AppSettings settings;
  Future<FeedController> createFeed({
    bool preload = true,
    PlayerPool? pool,
  }) async {
    final controller = FeedController(
      sourceManager: sources,
      store: store,
      settings: settings,
      pool:
          pool ??
          PlayerPool(
            playerFactory: FakePlayerService.new,
            preloadEnabled: preload,
          ),
    );
    await controller.initialize();
    return controller;
  }

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('reeldeck-feed');
    await Directory('${folder.path}/sub').create();
    for (final name in ['a.mp4', 'sub/b.mp4', 'sub/c.mp4']) {
      await File('${folder.path}/$name').writeAsString('fixture');
    }
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = LibraryStore(db);
    settings = AppSettings();
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
    feed = await createFeed();
  });
  tearDown(() async {
    await feed.close();
    sources.dispose();
    await db.close();
    await folder.delete(recursive: true);
  });

  test('真实路径打开，播放器状态、跳转、静音和预加载接通', () async {
    expect(feed.currentPath, startsWith(folder.path));
    expect(feed.isPlaying, true);
    expect(feed.pool.nextPlayer!.isPlaying, false);
    await feed.settled;
    final preloaded = feed.pool.nextPlayer;
    await feed.next();
    expect(feed.player, same(preloaded));
    await feed.togglePlayPause();
    expect(feed.isPlaying, false);
    await feed.seekTo(const Duration(seconds: 20));
    expect(feed.player!.position.inSeconds, 20);
    await feed.toggleMute();
    expect((feed.player as FakePlayerService).volume, 0);
  });
  test('连续切换不越界，队列关闭循环后保持末项', () async {
    settings.update(loopQueue: false);
    final last = feed.queue.queue.last;
    await Future.wait([feed.next(), feed.next(), feed.next(), feed.next()]);
    expect(feed.currentMediaId, last);
    expect(feed.isPlaying, false);
    await feed.previous();
    await feed.previous();
    await feed.previous();
    expect(feed.queue.currentIndex, 0);
  });
  test('收藏与队列在重启后恢复，单会话有界', () async {
    await feed.next();
    final id = feed.currentMediaId;
    final queue = feed.queue.queue;
    await feed.toggleFavorite();
    await feed.close();
    feed = await createFeed();
    expect(feed.currentMediaId, id);
    expect(feed.queue.queue, queue);
    expect(feed.isFavorite, true);
    expect(await db.select(db.sessions).get(), hasLength(1));
    await feed.setScope('favorites');
    expect(feed.queue.queue, [id]);
  });
  test('隐藏目录过滤子目录与以后新增文件，恢复隐藏可重新播放', () async {
    final sub = sources.allMedia.firstWhere(
      (m) => m.relativePath.startsWith('sub/'),
    );
    feed.queue.restore([sub.id], 0);
    await feed.retry();
    await feed.hideCurrentFolder();
    expect(feed.queue.queue, hasLength(1));
    await File('${folder.path}/sub/new.mp4').writeAsString('new');
    await sources.scanSource(sources.sources.first);
    await feed.settled;
    expect(feed.queue.queue, hasLength(1));
    await feed.resetHidden();
    expect(feed.queue.queue, hasLength(4));
  });
  test('禁用和移除目录立即停止播放，不生成模拟视频', () async {
    await sources.toggleSource(1);
    await feed.settled;
    expect(feed.currentMediaId, isNull);
    expect(feed.currentPath, isNull);
    expect(feed.isPlaying, false);
    await feed.next();
    await feed.previous();
    expect(feed.currentMediaId, isNull);
  });
  test('缺失文件自动跳过，离线目录保留当前项并显示错误', () async {
    final missing = feed.currentMedia!;
    await File(feed.currentPath!).delete();
    await feed.retry();
    expect(feed.currentMediaId, isNot(missing.id));
    final id = feed.currentMediaId;
    final moved = await folder.rename('${folder.path}-offline');
    await feed.retry();
    expect(feed.currentMediaId, id);
    expect(feed.error, isNotNull);
    await moved.rename(folder.path);
    await feed.retry();
    expect(feed.error, isNull);
  });
  test('完成事件遵守队列设置', () async {
    settings.update(loopQueue: false);
    await feed.next();
    await feed.next();
    final id = feed.currentMediaId;
    (feed.player as FakePlayerService).complete();
    await Future<void>.delayed(Duration.zero);
    await feed.settled;
    expect(feed.currentMediaId, id);
    expect(feed.isPlaying, false);
  });
  test('默认恢复进度，切到下一条再返回从保存位置继续播放', () async {
    final id = feed.currentMediaId!;
    await feed.seekTo(const Duration(seconds: 23));
    await feed.next();
    expect((await db.stateDao.getState(id))!.lastPosition, 23000);
    await feed.previous();
    expect(feed.player!.position, const Duration(seconds: 23));
    expect(feed.currentMediaId, id);
    expect((await db.stateDao.getState(id))!.lastPosition, 23000);
  });

  test('暂停、后台和关闭立即保存，不等待五秒采样', () async {
    final id = feed.currentMediaId!;
    await feed.player!.seekTo(const Duration(milliseconds: 1234));
    await feed.togglePlayPause();
    expect((await db.stateDao.getState(id))!.lastPosition, 1234);
    await feed.player!.seekTo(const Duration(milliseconds: 2345));
    await feed.suspend();
    expect((await db.stateDao.getState(id))!.lastPosition, 2345);
    await feed.player!.seekTo(const Duration(milliseconds: 3456));
    await feed.close();
    feed = await createFeed();
    expect(feed.currentMediaId, id);
    expect(feed.player!.position.inMilliseconds, 3456);
  });

  test('预加载首帧就使用保存位置，关闭恢复开关后重新打开零位置', () async {
    final nextId = feed.queue.nextId!;
    await db.stateDao.updatePosition(nextId, 17000);
    await feed.retry();
    await feed.settled;
    final preloaded = feed.pool.nextPlayer as FakePlayerService;
    expect(preloaded.position.inMilliseconds, 17000);
    await feed.next();
    expect(feed.player, same(preloaded));
    expect(feed.player!.position.inMilliseconds, 17000);
    settings.update(rememberPosition: false);
    await feed.previous();
    await feed.next();
    expect(feed.player!.position, Duration.zero);
  });

  test('Android 单播放器模式可连续前后切换并恢复进度', () async {
    await feed.close();
    feed = await createFeed(preload: false);
    final player = feed.player;
    expect(feed.pool.players, hasLength(1));
    expect(feed.pool.nextPlayer, isNull);
    await feed.seekTo(const Duration(seconds: 19));
    await feed.next();
    await feed.previous();
    expect(feed.player, same(player));
    expect(feed.player!.position.inSeconds, 19);
  });

  test('播放完毕清零保存位置，重新播放从头开始', () async {
    settings.update(loopQueue: false);
    await feed.next();
    await feed.next();
    final id = feed.currentMediaId!;
    await feed.player!.seekTo(const Duration(minutes: 1));
    (feed.player as FakePlayerService).complete();
    await Future<void>.delayed(Duration.zero);
    await feed.settled;
    expect((await db.stateDao.getState(id))!.lastPosition, 0);
    await feed.retry();
    expect(feed.player!.position, Duration.zero);
  });

  test('进度采样不会写到下一条，位置与收藏和播放次数并发更新不丢失', () async {
    final first = feed.currentMediaId!;
    await feed.player!.seekTo(const Duration(seconds: 16));
    final switching = feed.next();
    await Future<void>.delayed(Duration.zero);
    await switching;
    await feed.settled;
    expect((await db.stateDao.getState(first))!.lastPosition, 16000);
    final second = feed.currentMediaId!;
    await Future.wait([
      db.stateDao.updatePosition(second, 22000),
      db.stateDao.setFavorite(second, true),
      db.stateDao.incrementPlayCount(second),
    ]);
    final state = (await db.stateDao.getState(second))!;
    expect(state.lastPosition, 22000);
    expect(state.favorite, true);
    expect(state.playCount, 2);
  });
  test('松开拖动等待之前的 seek 完成，最终位置不会被旧跳转覆盖', () async {
    await feed.close();
    final slow = SlowSeekPlayer();
    feed = await createFeed(
      pool: PlayerPool(preloadEnabled: false, playerFactory: () => slow),
    );
    feed.startScrub();
    feed.scrubTo(const Duration(seconds: 10));
    feed.scrubTo(const Duration(seconds: 20));
    final done = feed.endScrub(const Duration(seconds: 25));
    slow.gate.complete();
    await done;
    expect(slow.position.inSeconds, 25);
    expect(
      (await db.stateDao.getState(feed.currentMediaId!))!.lastPosition,
      25000,
    );
    expect(slow.seeks, [10, 25]);
  });
  test('跨轮后上一条返回实际播放的末项，再下一条回到原首项', () async {
    final ids = feed.queue.queue;
    feed.queue.restore(ids, ids.length - 1);
    await feed.retry();
    final last = feed.currentMediaId;
    await feed.seekTo(const Duration(seconds: 13));
    await feed.next();
    final first = feed.currentMediaId;
    await feed.previous();
    expect(feed.currentMediaId, last);
    expect(feed.player!.position, const Duration(seconds: 13));
    await feed.next();
    expect(feed.currentMediaId, first);
  });

  test('滑到仍在预加载的下一条时复用同一解码任务', () async {
    await feed.close();
    final slow = SlowPreloadPlayer();
    var created = 0;
    feed = await createFeed(
      pool: PlayerPool(
        playerFactory: () => created++ == 0 ? FakePlayerService() : slow,
      ),
    );
    await slow.started.future;
    final switching = feed.next();
    await Future<void>.delayed(Duration.zero);
    slow.gate.complete();
    await switching;
    expect(feed.player, same(slow));
    expect(slow.opens, 1);
    expect(feed.busy, false);
    expect(feed.isPlaying, true);
  });

  test('交接等待时旧视频的完成事件不能额外跳过下一条', () async {
    await feed.close();
    final old = FakePlayerService();
    final slow = SlowPreloadPlayer();
    var created = 0;
    feed = await createFeed(
      pool: PlayerPool(playerFactory: () => created++ == 0 ? old : slow),
    );
    await slow.started.future;
    final next = feed.queue.nextId;
    final switching = feed.next();
    while (feed.currentMediaId != next) {
      await Future<void>.delayed(Duration.zero);
    }
    old.complete();
    await Future<void>.delayed(Duration.zero);
    slow.gate.complete();
    await switching;
    await feed.settled;
    expect(feed.currentMediaId, next);
    expect(feed.queueIndex, 1);
  });

  test('解码超时停止自动遍历，保留当前项并结束加载提示', () async {
    await feed.close();
    final timeoutPlayer = TimeoutPlayer();
    feed = await createFeed(
      pool: PlayerPool(
        preloadEnabled: false,
        playerFactory: () => timeoutPlayer,
      ),
    );
    expect(feed.busy, false);
    expect(feed.error, contains('TimeoutException'));
    expect(feed.currentMediaId, isNotNull);
    expect(timeoutPlayer.opens, 1);
    expect(feed.queueLength, 3);
    timeoutPlayer.fail = false;
    await feed.retry();
    expect(feed.error, isNull);
    expect(feed.isPlaying, true);
  });

  test('切换解码模式重新打开当前视频并保留播放进度', () async {
    final id = feed.currentMediaId;
    await feed.seekTo(const Duration(seconds: 7));
    final opens = (feed.player as FakePlayerService).opens;
    settings.update(decoderMode: 'no');
    await feed.settled;
    expect(feed.currentMediaId, id);
    expect(feed.player!.position, const Duration(seconds: 7));
    expect((feed.player as FakePlayerService).opens, greaterThan(opens));
  });

  test('子目录范围使用路径边界，包含后续新增文件', () async {
    await Directory('${folder.path}/submarine').create();
    await File('${folder.path}/submarine/outside.mp4').writeAsString('fixture');
    await sources.scanSource(sources.sources.first);
    await feed.settled;
    await feed.setScope('folder:1:sub');
    expect(feed.queue.queue, hasLength(2));
    expect(feed.currentFolder, contains('sub'));
    await File('${folder.path}/sub/new.mp4').writeAsString('fixture');
    await sources.scanSource(sources.sources.first);
    await feed.settled;
    expect(feed.queue.queue, hasLength(3));
    expect(
      feed.queue.queue.map(
        (id) => sources.allMedia.firstWhere((m) => m.id == id).relativePath,
      ),
      everyElement(startsWith('sub/')),
    );
  });
  test('顺序设置立即重建并持久化会话，关闭每轮洗牌保持队列', () async {
    for (final media in sources.allMedia) {
      await File('${folder.path}/${media.relativePath}')
          .setLastModified(DateTime(2026, 1, media.id));
    }
    await sources.scanSource(sources.sources.first);
    settings.update(queueOrder: 'newest', reshuffleAfterRound: false);
    await feed.settled;
    expect(
      feed.currentMediaId,
      sources.allMedia.map((m) => m.id).reduce((a, b) => a > b ? a : b),
    );
    final order = feed.queue.queue;
    await feed.next();
    await feed.next();
    await feed.next();
    expect(feed.queue.queue, order);
    expect(feed.queueIndex, 0);
    await feed.close();
    feed = await createFeed();
    expect(feed.queue.queue, order);
  });
  test('回收站失败保留索引并恢复播放，过期确认不删除下一条', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(StorageBridge.channel, (call) async {
      throw PlatformException(code: 'trash', message: '只读磁盘');
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(StorageBridge.channel, null),
    );
    final id = feed.currentMediaId!;
    await feed.trashCurrent(id);
    expect(sources.allMedia, hasLength(3));
    expect(feed.currentMediaId, id);
    expect(feed.currentPath, isNotNull);
    expect(feed.error, contains('只读磁盘'));
    await feed.next();
    await feed.trashCurrent(id);
    expect(sources.allMedia, hasLength(3));
  });
  test('图片默认过滤，开启后计时、暂停、跳转并保存位置', () async {
    final bytes = await File('assets/icon/app_icon.png').readAsBytes();
    await File('${folder.path}/picture.png').writeAsBytes(bytes);
    await sources.scanSource(sources.sources.first);
    await feed.settled;
    expect(feed.queueLength, 3);
    settings.update(includeImages: true, imageSeconds: 2);
    await feed.settled;
    final image = sources.allMedia.firstWhere((m) => m.extension == 'png');
    feed.queue.restore([image.id], 0);
    await feed.retry();
    expect(feed.error, isNull);
    expect(feed.imageBytes, isNotNull);
    expect(feed.duration, const Duration(seconds: 2));
    await Future<void>.delayed(const Duration(milliseconds: 160));
    expect(feed.position, greaterThan(Duration.zero));
    await feed.togglePlayPause();
    final paused = feed.position;
    await Future<void>.delayed(const Duration(milliseconds: 160));
    expect(feed.position, paused);
    await feed.seekTo(const Duration(milliseconds: 700));
    expect((await db.stateDao.getState(image.id))!.lastPosition, 700);
    settings.update(includeImages: false);
    await feed.settled;
    expect(feed.imageBytes, isNull);
    expect(feed.queueLength, 3);
  });
}

class SlowSeekPlayer extends FakePlayerService {
  final gate = Completer<void>();
  final seeks = <int>[];
  @override
  Future<void> seekTo(Duration position) async {
    seeks.add(position.inSeconds);
    if (seeks.length == 1) await gate.future;
    await super.seekTo(position);
  }
}

class TimeoutPlayer extends FakePlayerService {
  bool fail = true;
  @override
  Future<void> open(String path, {Duration start = Duration.zero}) async {
    if (fail) {
      opens++;
      throw TimeoutException('视频输出未就绪');
    }
    await super.open(path, start: start);
  }
}

class SlowPreloadPlayer extends FakePlayerService {
  final started = Completer<void>();
  final gate = Completer<void>();
  @override
  Future<void> open(String path, {Duration start = Duration.zero}) async {
    if (!started.isCompleted) started.complete();
    await gate.future;
    await super.open(path, start: start);
  }
}
