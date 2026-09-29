import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/player/player_pool.dart';
import 'package:reel_deck/player/player_service.dart';

class FakePlayerService implements PlayerService {
  String? _path;
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
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {
    await _posController.close();
    await _playingController.close();
    await _durationController.close();
    await _completedController.close();
  }
}

void main() {
  test('PlayerPool initialization and advanceToNext logic', () async {
    final pool = PlayerPool(playerFactory: FakePlayerService.new);
    expect(pool.currentPlayer, isNull);
    expect(pool.nextPlayer, isNull);

    await pool.initialize();

    expect(pool.currentPlayer, isNotNull);
    expect(pool.nextPlayer, isNotNull);

    final initialCurrent = pool.currentPlayer;
    final initialNext = pool.nextPlayer;

    await pool.advanceToNext();

    expect(pool.currentPlayer, equals(initialNext));
    expect(pool.nextPlayer, equals(initialCurrent));
    expect(pool.currentPlayer?.isPlaying, isTrue);
  });

  test('PlayerPool goToPrevious logic', () async {
    final pool = PlayerPool(playerFactory: FakePlayerService.new);
    await pool.initialize();

    final initialCurrent = pool.currentPlayer;
    final initialNext = pool.nextPlayer;

    await pool.goToPrevious('test_path.mp4');

    expect(pool.currentPlayer, equals(initialNext));
    expect(pool.nextPlayer, equals(initialCurrent));
    expect(pool.currentPlayer?.currentPath, equals('test_path.mp4'));
    expect(pool.currentPlayer?.isPlaying, isTrue);
  });
}
