import 'package:flutter/foundation.dart';
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

  @override
  Future<void> open(String path) async {
    _currentPath = path;
    try {
      await _player.open(Media(path), play: false);
    } catch (e) {
      // Handle gracefully
      debugPrint('Error opening media: $e');
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Error playing media: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing media: $e');
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking media: $e');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume * 100.0); // media_kit volume is 0-100
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

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
