import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/queue/filters.dart';
import 'package:reel_deck/queue/queue_engine.dart';
import 'package:reel_deck/queue/shuffle.dart';

void main() {
  group('fisherYatesShuffle', () {
    test('shuffles list in place and retains all elements', () {
      final original = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final items = List<int>.from(original);
      final result = fisherYatesShuffle(items, random: Random(42));

      expect(identical(result, items), isTrue);
      expect(result..sort(), equals(original));
    });

    test('handles empty and single element lists', () {
      expect(fisherYatesShuffle<int>([]), isEmpty);
      expect(fisherYatesShuffle<int>([1]), equals([1]));
    });
  });

  group('MediaFilter', () {
    final filter = MediaFilter();

    test('excludes hiddenIds and hiddenFolderMediaIds', () {
      final media = [1, 2, 3, 4, 5, 6];
      final result = filter.apply(
        media,
        hiddenIds: {2, 4},
        hiddenFolderMediaIds: {5},
      );
      expect(result, equals([1, 3, 6]));
    });

    test('returns full copy when sets are empty', () {
      final media = [1, 2, 3];
      final result = filter.apply(media);
      expect(result, equals([1, 2, 3]));
      expect(identical(result, media), isFalse);
    });
  });

  group('QueueEngine', () {
    test('builds queue and handles advance / goBack', () {
      final engine = QueueEngine(random: Random(42));
      expect(engine.currentId, isNull);
      expect(engine.nextId, isNull);
      expect(engine.previousId, isNull);
      expect(engine.advance(), isFalse);
      expect(engine.goBack(), isFalse);

      engine.buildQueue([10, 20, 30]);
      expect(engine.queue.length, equals(3));
      expect(engine.currentIndex, equals(0));
      expect(engine.currentId, isNotNull);
      expect(engine.previousId, isNull);
      expect(engine.nextId, equals(engine.queue[1]));

      final firstId = engine.currentId;
      expect(engine.advance(), isTrue);
      expect(engine.currentIndex, equals(1));
      expect(engine.previousId, equals(firstId));

      expect(engine.advance(), isTrue);
      expect(engine.currentIndex, equals(2));
      expect(engine.nextId, isNull);
      expect(engine.advance(), isFalse);

      expect(engine.goBack(), isTrue);
      expect(engine.currentIndex, equals(1));
      expect(engine.goBack(), isTrue);
      expect(engine.currentIndex, equals(0));
      expect(engine.goBack(), isFalse);
    });

    test('reshuffle resets index and retains elements', () {
      final engine = QueueEngine(random: Random(42));
      engine.buildQueue([1, 2, 3, 4, 5]);
      engine.advance();
      engine.advance();
      expect(engine.currentIndex, equals(2));

      final originalElements = List<int>.from(engine.queue)..sort();
      engine.reshuffle();

      expect(engine.currentIndex, equals(0));
      final reshuffledElements = List<int>.from(engine.queue)..sort();
      expect(reshuffledElements, equals(originalElements));
    });

    test('下一轮预加载目标与实际首项一致，准备时不改变当前队列', () {
      final engine = QueueEngine(random: Random(42));
      engine.buildQueue([1, 2, 3, 4]);
      while (engine.advance()) {}
      final last = engine.currentId;
      final oldQueue = engine.queue;
      final prepared = engine.prepareNextRound(reshuffle: true);
      expect(engine.currentId, last);
      expect(engine.queue, oldQueue);
      expect(prepared, isNot(last));
      expect(engine.prepareNextRound(reshuffle: true), prepared);
      engine.startNextRound(reshuffle: true);
      expect(engine.currentId, prepared);
      expect(engine.queue.toSet(), oldQueue.toSet());
    });

    test('重扫移除媒体后不复用旧下一轮，顺序循环保留首项', () {
      final engine = QueueEngine(random: Random(42));
      engine.restore([1, 2, 3], 2);
      engine.prepareNextRound(reshuffle: true);
      engine.reconcile([2, 3]);
      final first = engine.queue.first;
      engine.prepareNextRound(reshuffle: false);
      engine.startNextRound(reshuffle: false);
      expect(engine.currentId, first);
      expect(engine.queue, [2, 3]);
    });

    test('empty queue handles methods safely', () {
      final engine = QueueEngine();
      engine.buildQueue([]);
      expect(engine.currentId, isNull);
      expect(engine.nextId, isNull);
      expect(engine.previousId, isNull);
      expect(engine.advance(), isFalse);
      expect(engine.goBack(), isFalse);
      engine.reshuffle();
      expect(engine.currentIndex, equals(-1));
    });
  });
}
