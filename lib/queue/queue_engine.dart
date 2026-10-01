import 'dart:math';

import 'shuffle.dart';

/// Manages an ordered queue of media IDs for playback.
class QueueEngine {
  QueueEngine({Random? random}) : _random = random ?? Random.secure();

  final Random _random;
  List<int> Function(List<int>, Random)? orderer;
  List<int> _queue = [];
  int _currentIndex = -1;

  void restore(List<int> ids, int index) {
    _queue = ids.toSet().toList();
    _currentIndex = _queue.isEmpty ? -1 : index.clamp(0, _queue.length - 1);
  }

  void reconcile(List<int> eligible, {bool reorderPending = false}) {
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
      _currentIndex--;
      return true;
    }
    return false;
  }

  /// Reshuffles the current queue using Fisher-Yates and resets the index to the beginning.
  /// If the queue has more than 1 item, avoids repeating the last played item immediately.
  void reshuffle() {
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
