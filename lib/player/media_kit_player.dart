import 'dart:async';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'player_service.dart';

class MediaKitPlayerService implements PlayerService {
  late final Player _player;
  late final VideoController _controller;
  String? _currentPath;

  VideoController get controller => _controller;

  MediaKitPlayerService() {
    _player = Player(configuration: const PlayerConfiguration());
    _controller = VideoController(_player);
  }

  Future<void> setRate(double rate) => _player.setRate(rate);

  Stream<String> get errors => _player.stream.error;

  @override
  Future<void> open(String path) async {
    _currentPath = null;
    await _player.open(Media(path), play: false);
    _currentPath = path;
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seekTo(Duration position) => _player.seek(position);
  @override
  Future<void> setVolume(double volume) =>
      _player.setVolume(volume.clamp(0, 1) * 100);

  @override
  Future<void> dispose() async {
    _currentPath = null;
    await _player.dispose();
  }

  @override
  bool get isPlaying => _player.state.playing;

  @override
  Duration get position => _player.state.position;

  @override
  Duration get duration => _player.state.duration;

  @override
  String? get currentPath => _currentPath;

  @override
  Stream<Duration> get positionStream => _player.stream.position;

  @override
  Stream<bool> get playingStream => _player.stream.playing;

  @override
  Stream<Duration> get durationStream => _player.stream.duration;

  @override
  Stream<bool> get completedStream => _player.stream.completed;
}
