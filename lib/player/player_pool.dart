import 'player_service.dart';
import 'media_kit_player.dart';

/// 播放器缓冲池：管理当前、前一条与后一条播放器，提供平滑切换与零延迟预载。
class PlayerPool {
  final PlayerService Function() _playerFactory;
  final bool preloadEnabled;
  final List<PlayerService> _players = [];

  PlayerService? _currentPlayer;
  PlayerService? _nextPlayer;
  PlayerService? _previousPlayer;

  Duration? _preloadedNextStart;
  Duration? _preloadedPrevStart;

  PlayerPool({
    PlayerService Function()? playerFactory,
    bool? preloadEnabled,
  })  : _playerFactory = playerFactory ?? MediaKitPlayerService.new,
        preloadEnabled = preloadEnabled ?? true;

  List<PlayerService> get players => List.unmodifiable(_players);

  PlayerService? get currentPlayer => _currentPlayer;
  PlayerService? get nextPlayer => _nextPlayer;
  PlayerService? get previousPlayer => _previousPlayer;

  bool hasPreloadedNext(String path, Duration start) =>
      _nextPlayer?.currentPath == path && _preloadedNextStart == start;

  bool hasPreloadedPrevious(String path, Duration start) =>
      _previousPlayer?.currentPath == path && _preloadedPrevStart == start;

  bool hasPreloaded(String path, Duration start) =>
      hasPreloadedNext(path, start);

  Future<void> initialize() async {
    if (_currentPlayer != null) return;
    _currentPlayer = _playerFactory();
    _players.add(_currentPlayer!);
    if (preloadEnabled) {
      _nextPlayer = _playerFactory();
      _players.add(_nextPlayer!);
      _previousPlayer = _playerFactory();
      _players.add(_previousPlayer!);
    }
  }

  Future<void> playMedia(String path) async {
    final player = _currentPlayer;
    if (player != null) {
      await player.open(path);
      await player.play();
    }
  }

  Future<void> preloadNext(
    String path, {
    Duration start = Duration.zero,
  }) async {
    final player = _nextPlayer;
    if (player != null) {
      if (player.currentPath == path && _preloadedNextStart == start) {
        return;
      }
      _preloadedNextStart = null;
      await player.open(path, start: start);
      _preloadedNextStart = start;
    }
  }

  Future<void> preloadPrevious(
    String path, {
    Duration start = Duration.zero,
  }) async {
    final player = _previousPlayer;
    if (player != null) {
      if (player.currentPath == path && _preloadedPrevStart == start) {
        return;
      }
      _preloadedPrevStart = null;
      await player.open(path, start: start);
      _preloadedPrevStart = start;
    }
  }

  Future<void> swapToNext() async {
    if (_currentPlayer == null || _nextPlayer == null) return;
    _preloadedNextStart = null;
    await _currentPlayer?.pause();
    if (_previousPlayer != null) {
      final recycled = _previousPlayer!;
      _previousPlayer = _currentPlayer;
      _currentPlayer = _nextPlayer;
      _nextPlayer = recycled;
    } else {
      final temp = _currentPlayer;
      _currentPlayer = _nextPlayer;
      _nextPlayer = temp;
    }
  }

  Future<void> swapToPrevious() async {
    if (_currentPlayer == null || _previousPlayer == null) return;
    _preloadedPrevStart = null;
    await _currentPlayer?.pause();
    if (_nextPlayer != null) {
      final recycled = _nextPlayer!;
      _nextPlayer = _currentPlayer;
      _currentPlayer = _previousPlayer;
      _previousPlayer = recycled;
    } else {
      final temp = _currentPlayer;
      _currentPlayer = _previousPlayer;
      _previousPlayer = temp;
    }
  }

  Future<void> swap() => swapToNext();

  Future<void> advanceToNext() async {
    await swapToNext();
    await _currentPlayer?.play();
  }

  Future<void> goToPrevious(String path) async {
    if (_previousPlayer != null && _previousPlayer?.currentPath == path) {
      await swapToPrevious();
    } else {
      await swapToPrevious();
      if (_currentPlayer?.currentPath != path) {
        await _currentPlayer?.open(path);
      }
    }
    await _currentPlayer?.play();
  }

  Future<void> dispose() async {
    for (final p in _players) {
      await p.dispose();
    }
    _currentPlayer = null;
    _nextPlayer = null;
    _previousPlayer = null;
    _players.clear();
  }
}
