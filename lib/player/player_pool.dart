import 'player_service.dart';
import 'media_kit_player.dart';

/// Manages a fixed pool of players (current + next) for seamless feed playback.
class PlayerPool {
  final PlayerService Function() _playerFactory;

  PlayerService? _currentPlayer;
  PlayerService? _nextPlayer;

  PlayerPool({PlayerService Function()? playerFactory})
    : _playerFactory = playerFactory ?? MediaKitPlayerService.new;

  PlayerService? get currentPlayer => _currentPlayer;
  PlayerService? get nextPlayer => _nextPlayer;

  /// Initializes the pool by creating exactly 2 players.
  Future<void> initialize() async {
    if (_currentPlayer != null) return;
    _currentPlayer = _playerFactory();
    _nextPlayer = _playerFactory();
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
  Future<void> preloadNext(String path) async {
    final player = _nextPlayer;
    if (player != null) {
      await player.open(path);
    }
  }

  Future<void> swap() async {
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
  }
}
