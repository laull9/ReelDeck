/// Interface for media playback service.
///
/// Concrete implementations (e.g., media_kit) will implement this interface.
abstract class PlayerService {
  /// Opens media from the given [path].
  Future<void> open(String path);

  /// Starts or resumes playback.
  Future<void> play();

  /// Pauses playback.
  Future<void> pause();

  /// Seeks to the specified [position].
  Future<void> seekTo(Duration position);

  /// Releases resources associated with the player.
  Future<void> dispose();

  /// Whether media is currently playing.
  bool get isPlaying;

  /// Current playback position.
  Duration get position;

  /// Total duration of the current media.
  Duration get duration;
}
