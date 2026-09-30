import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

import '../support/fake_player.dart';

void main() {
  late Directory folder;
  late AppDatabase db;
  late LibraryStore store;
  late SourceManager sources;
  late FeedController feed;
  late AppSettings settings;
  Future<FeedController> createFeed() async {
    final controller = FeedController(
      sourceManager: sources,
      store: store,
      settings: settings,
      pool: PlayerPool(playerFactory: FakePlayerService.new),
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
}
