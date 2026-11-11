import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/database/database.dart';
import 'package:reel_deck/database/library_store.dart';
import 'package:reel_deck/database/state_dao.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

import '../support/fake_player.dart';

void main() {
  late Directory folder;
  late DelayedDatabase db;
  late FailingResolver sources;
  late FeedController feed;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('reeldeck-handoff');
    for (final name in ['a', 'b', 'c']) {
      await File('${folder.path}/$name.mp4').writeAsString('fixture');
    }
    db = DelayedDatabase();
    final store = LibraryStore(db);
    sources = FailingResolver(store: store);
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
    feed = FeedController(
      sourceManager: sources,
      store: store,
      pool: PlayerPool(playerFactory: FakePlayerService.new),
    );
    await feed.initialize();
    await feed.settled;
  });

  tearDown(() async {
    if (!db.delayed.release.isCompleted) db.delayed.release.complete();
    await feed.close();
    sources.dispose();
    feed.settings.dispose();
    await db.close();
    await folder.delete(recursive: true);
  });

  test('新画面已经播放时，慢速写盘不能冻结进度和播放状态', () async {
    db.delayed.delay = true;
    final opening = feed.next();
    await db.delayed.started.future;
    expect(feed.busy, false);
    expect(feed.displayedMediaId, feed.currentMediaId);
    await feed.player!.seekTo(const Duration(seconds: 7));
    await feed.player!.pause();
    await Future<void>.delayed(Duration.zero);
    expect(feed.position, const Duration(seconds: 7));
    expect(feed.isPlaying, false);
    db.delayed.release.complete();
    await opening;
  });

  test('文件解析超时也清理交接状态，旧视频停声且可以重试', () async {
    final old = feed.player!;
    final target = feed.queue.nextId;
    sources.fail = true;
    await feed.next();
    expect(old.isPlaying, false);
    expect(feed.busy, false);
    expect(feed.isPlaying, false);
    expect(feed.currentMediaId, target);
    expect(feed.error, contains('TimeoutException'));
    sources.fail = false;
    await feed.retry();
    expect(feed.error, isNull);
    expect(feed.displayedMediaId, target);
    expect(feed.isPlaying, true);
  });

  test('同一个视频重复发送完成事件只前进一条', () async {
    final target = feed.queue.nextId;
    final old = feed.player as FakePlayerService;
    old.complete();
    old.complete();
    await Future<void>.delayed(Duration.zero);
    await feed.settled;
    expect(feed.currentMediaId, target);
  });

  test('解析路径很慢时显示加载反馈且停止旧声音', () async {
    sources.gate = Completer<void>();
    final previous = feed.player!;
    final opening = feed.next();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(feed.busy, true);
      expect(previous.isPlaying, false);
    } finally {
      sources.gate!.complete();
      sources.gate = null;
      await opening;
    }
    expect(feed.busy, false);
    expect(feed.isPlaying, true);
  });
}

class DelayedDatabase extends AppDatabase {
  DelayedDatabase() : super.forTesting(NativeDatabase.memory());
  late final delayed = DelayedStateDao(this);
  @override
  StateDao get stateDao => delayed;
}

class DelayedStateDao extends StateDao {
  DelayedStateDao(super.db);
  bool delay = false;
  final started = Completer<void>();
  final release = Completer<void>();
  @override
  Future<void> incrementPlayCount(int mediaId) async {
    if (delay) {
      if (!started.isCompleted) started.complete();
      await release.future;
    }
    await super.incrementPlayCount(mediaId);
  }
}

class FailingResolver extends SourceManager {
  FailingResolver({super.store});
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<String?> resolveMediaPath(Media media) async {
    if (fail) throw TimeoutException('模拟文件解析超时');
    await gate?.future;
    return super.resolveMediaPath(media);
  }
}
