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

  /// Sets the volume (0.0 to 1.0).
  Future<void> setVolume(double volume);

  /// Releases resources associated with the player.
  Future<void> dispose();

  /// Whether media is currently playing.
  bool get isPlaying;

  /// Current playback position.
  Duration get position;

  /// Total duration of the current media.
  Duration get duration;

  /// Path of currently opened media.
  String? get currentPath;

  /// Streams for reactive UI updates.
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  Stream<Duration> get durationStream;
  Stream<bool> get completedStream; // fires when video finishes
}
