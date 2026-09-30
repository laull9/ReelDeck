import 'dart:async';

import 'package:reel_deck/player/player_service.dart';

class FakePlayerService implements PlayerService {
  String? _path;
  double volume = 1;
  int opens = 0;
  bool failOpen = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  final Duration _duration = const Duration(minutes: 1);

  final _posController = StreamController<Duration>.broadcast();
  final _playingController = StreamController<bool>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _completedController = StreamController<bool>.broadcast();

  @override
  String? get currentPath => _path;

  @override
  bool get isPlaying => _isPlaying;

  @override
  Duration get position => _position;

  @override
  Duration get duration => _duration;

  @override
  Stream<Duration> get positionStream => _posController.stream;

  @override
  Stream<bool> get playingStream => _playingController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Stream<bool> get completedStream => _completedController.stream;

  @override
  Future<void> open(String path) async {
    opens++;
    if (failOpen) throw StateError('损坏的视频');
    _position = Duration.zero;
    _path = path;
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    _playingController.add(true);
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _playingController.add(false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    _position = position;
    _posController.add(position);
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume = volume;
  }

  void complete() {
    _completedController.add(true);
  }

  @override
  Future<void> dispose() async {
    await _posController.close();
    await _playingController.close();
    await _durationController.close();
    await _completedController.close();
  }
}
