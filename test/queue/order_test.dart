import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/queue/queue_engine.dart';
import 'package:reel_deck/queue/queue_order.dart';
import 'package:reel_deck/sources/source.dart';

void main() {
  final media = <int, Media>{
    for (var i = 0; i < 12; i++)
      i: Media(
        id: i,
        sourceId: 1,
        relativePath: '${i % 3}/$i.mp4',
        fileName: '$i.mp4',
        extension: 'mp4',
        size: 1,
        modifiedAt: DateTime(2026, 1, i + 1),
      ),
  };
  test('时间排序与单轮完整性', () {
    final ids = media.keys.toList();
    expect(orderMedia(ids, media, 'newest', Random(1)), ids.reversed.toList());
    expect(orderMedia(ids, media, 'oldest', Random(1)), ids);
    expect(
      orderMedia([...ids, 0], media, 'shuffle', Random(1)).toSet(),
      ids.toSet(),
    );
  });
  test('智能随机保留全部媒体并交错目录，所有种子均无重复', () {
    for (var seed = 0; seed < 100; seed++) {
      final ids = orderMedia(media.keys.toList(), media, 'smart', Random(seed));
      expect(ids.toSet(), media.keys.toSet());
      expect(ids.length, media.length);
      for (var index = 1; index < ids.length; index++) {
        expect(ids[index] % 3, isNot(ids[index - 1] % 3));
      }
    }
  });
  test('删除当前项按剩余位置前进，禁止回跳已播放项', () {
    final queue = QueueEngine()..restore([1, 2, 3, 4], 2);
    queue.reconcile([1, 4]);
    expect(queue.currentId, 4);
    expect(queue.currentIndex, 1);
    queue.reconcile([1]);
    expect(queue.currentId, isNull);
    expect(queue.currentIndex, 1);
    queue.restart();
    expect(queue.currentId, 1);
  });
  test('扫描新增只对未播放部分排序，重启恢复不洗牌', () {
    final queue = QueueEngine()..restore([10, 8, 4], 1);
    queue.orderer = (ids, random) => orderMedia(ids, media, 'newest', random);
    queue.reconcile([10, 8, 4, 11, 6], reorderPending: true);
    expect(queue.queue, [10, 8, 11, 6, 4]);
    expect(queue.currentId, 8);
    // 当前项不能因新增文件而被替换。
  });
}
