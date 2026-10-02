import 'dart:math';

import 'shuffle.dart';

/// Manages an ordered queue of media IDs for playback.
class QueueEngine {
  QueueEngine({Random? random}) : _random = random ?? Random.secure();

  final Random _random;
  List<int> Function(List<int>, Random)? orderer;
  List<int> _queue = [];
  int _currentIndex = -1;
  List<int>? _nextRound;
  bool? _nextRoundShuffled;

  void restore(List<int> ids, int index) {
    _nextRound = null;
    _queue = ids.toSet().toList();
    _currentIndex = _queue.isEmpty ? -1 : index.clamp(0, _queue.length - 1);
  }

  void reconcile(List<int> eligible, {bool reorderPending = false}) {
    _nextRound = null;
    final current = currentId;
    final allowed = eligible.toSet();
    final retained = _queue.where(allowed.contains).toList();
    final existing = retained.toSet();
    final added = eligible.where((id) => !existing.contains(id)).toList();
    fisherYatesShuffle(added, random: _random);
    final played = _queue
        .take(_currentIndex < 0 ? 0 : _currentIndex)
        .where(allowed.contains)
        .toList();
    final upcoming = _queue
        .skip(_currentIndex < 0 ? 0 : _currentIndex)
        .where(allowed.contains)
        .toList();
    var pending = [...upcoming, ...added];
    if (reorderPending && orderer != null) {
      final keepCurrent = current != null && pending.remove(current);
      pending = orderer!(pending, _random);
      if (keepCurrent) pending.insert(0, current);
    }
    if (pending.isEmpty && played.isNotEmpty) {
      _queue = played;
      _currentIndex = played.length;
      return;
    }
    restore([...played, ...pending], played.length);
  }

  void restart() => _currentIndex = _queue.isEmpty ? -1 : 0;

  void _order() {
    if (orderer != null) {
      _queue = orderer!(_queue, _random);
    } else {
      fisherYatesShuffle(_queue, random: _random);
    }
  }

  /// Current list of media IDs in the queue.
  List<int> get queue => List.unmodifiable(_queue);

  /// Current playback index within [_queue].
  int get currentIndex => _currentIndex;

  /// Builds a shuffled queue from [eligibleMediaIds] using Fisher-Yates.
  void buildQueue(List<int> eligibleMediaIds) {
    _nextRound = null;
    _queue = eligibleMediaIds.toSet().toList();
    _order();
    _currentIndex = _queue.isNotEmpty ? 0 : -1;
  }

  /// The media ID currently active, or `null` if the queue is empty or index is invalid.
  int? get currentId {
    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      return _queue[_currentIndex];
    }
    return null;
  }

  /// The media ID next in the queue, or `null` if at the end of the queue.
  int? get nextId {
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= 0 && nextIndex < _queue.length) {
      return _queue[nextIndex];
    }
    return null;
  }

  /// The media ID previous in the queue, or `null` if at the beginning of the queue.
  int? get previousId {
    final prevIndex = _currentIndex - 1;
    if (prevIndex >= 0 && prevIndex < _queue.length) {
      return _queue[prevIndex];
    }
    return null;
  }

  /// Advances to the next item in the queue.
  /// Returns `true` if advanced successfully, or `false` if already at the end.
  bool advance() {
    if (_currentIndex + 1 < _queue.length) {
      _currentIndex++;
      return true;
    }
    return false;
  }

  /// Moves back to the previous item in the queue.
  /// Returns `true` if moved back successfully, or `false` if already at the beginning.
  bool goBack() {
    if (_currentIndex > 0) {
      _nextRound = null;
      _currentIndex--;
      return true;
    }
    return false;
  }

  /// 最后一条播放时确定下一轮首项，让预加载和实际前进使用同一目标。
  int? prepareNextRound({required bool reshuffle}) {
    if (_queue.isEmpty) return null;
    if (_nextRound == null || _nextRoundShuffled != reshuffle) {
      final planned = List<int>.of(_queue);
      if (reshuffle) {
        if (orderer != null) {
          final ordered = List<int>.of(orderer!(planned, _random));
          planned
            ..clear()
            ..addAll(ordered);
        } else {
          fisherYatesShuffle(planned, random: _random);
        }
        if (planned.length > 1 && planned.first == currentId) {
          final index = 1 + _random.nextInt(planned.length - 1);
          final first = planned[0];
          planned[0] = planned[index];
          planned[index] = first;
        }
      }
      _nextRound = planned;
      _nextRoundShuffled = reshuffle;
    }
    return _nextRound!.first;
  }

  void startNextRound({required bool reshuffle}) {
    prepareNextRound(reshuffle: reshuffle);
    if (_nextRound == null) return;
    _queue = _nextRound!;
    _nextRound = null;
    _currentIndex = 0;
  }

  /// Reshuffles the current queue using Fisher-Yates and resets the index to the beginning.
  /// If the queue has more than 1 item, avoids repeating the last played item immediately.
  void reshuffle() {
    _nextRound = null;
    if (_queue.isEmpty) return;
    final previousLast = currentId;
    _order();
    if (_queue.length > 1 && _queue.first == previousLast) {
      final swapIndex = 1 + _random.nextInt(_queue.length - 1);
      final temp = _queue[0];
      _queue[0] = _queue[swapIndex];
      _queue[swapIndex] = temp;
    }
    _currentIndex = 0;
  }
}
