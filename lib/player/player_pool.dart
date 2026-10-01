import 'dart:io';

import 'player_service.dart';
import 'media_kit_player.dart';

/// Android 只打开当前视频；桌面保留当前和下一条播放器。
class PlayerPool {
  final PlayerService Function() _playerFactory;
  final bool preloadEnabled;
  final List<PlayerService> _players = [];
  Duration? _preloadedStart;

  PlayerService? _currentPlayer;
  PlayerService? _nextPlayer;

  PlayerPool({PlayerService Function()? playerFactory, bool? preloadEnabled})
    : _playerFactory = playerFactory ?? MediaKitPlayerService.new,
      preloadEnabled = preloadEnabled ?? !Platform.isAndroid;

  List<PlayerService> get players => List.unmodifiable(_players);

  bool hasPreloaded(String path, Duration start) =>
      _nextPlayer?.currentPath == path && _preloadedStart == start;

  PlayerService? get currentPlayer => _currentPlayer;
  PlayerService? get nextPlayer => _nextPlayer;

  /// 按平台创建播放器。
  Future<void> initialize() async {
    if (_currentPlayer != null) return;
    _currentPlayer = _playerFactory();
    _players.add(_currentPlayer!);
    if (preloadEnabled) {
      _nextPlayer = _playerFactory();
      _players.add(_nextPlayer!);
    }
  }

  /// Opens and plays the specified media on the current player.
  Future<void> playMedia(String path) async {
    final player = _currentPlayer;
    if (player != null) {
      await player.open(path);
      await player.play();
    }
  }

  /// Preloads the specified media on the next player without playing it.
  Future<void> preloadNext(
    String path, {
    Duration start = Duration.zero,
  }) async {
    final player = _nextPlayer;
    if (player != null) {
      _preloadedStart = null;
      await player.open(path, start: start);
      _preloadedStart = start;
    }
  }

  Future<void> swap() async {
    if (_nextPlayer == null) return;
    _preloadedStart = null;
    await _currentPlayer?.pause();
    final previous = _currentPlayer;
    _currentPlayer = _nextPlayer;
    _nextPlayer = previous;
  }

  /// Swaps the players. The next player becomes the current player and starts playing.
  /// The old current player is paused and becomes the next player (recycled).
  Future<void> advanceToNext() async {
    if (_currentPlayer == null || _nextPlayer == null) return;

    // Pause the currently playing video
    await _currentPlayer!.pause();

    // Swap the players
    final temp = _currentPlayer;
    _currentPlayer = _nextPlayer;
    _nextPlayer = temp;

    // Play the new current player
    await _currentPlayer!.play();
  }

  /// Swaps the players. The current player becomes the next player.
  /// The old next player becomes the current player, and loads the previous media path.
  Future<void> goToPrevious(String path) async {
    if (_currentPlayer == null || _nextPlayer == null) return;

    // Pause the currently playing video
    await _currentPlayer!.pause();

    // Swap the players
    final temp = _currentPlayer;
    _currentPlayer = _nextPlayer;
    _nextPlayer = temp;

    // Open and play the previous media on the new current player
    await _currentPlayer!.open(path);
    await _currentPlayer!.play();
  }

  /// Disposes both players in the pool.
  Future<void> dispose() async {
    await _currentPlayer?.dispose();
    await _nextPlayer?.dispose();
    _currentPlayer = null;
    _nextPlayer = null;
    _players.clear();
  }
}
