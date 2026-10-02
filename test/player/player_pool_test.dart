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
  Future<void> open(String path, {Duration start = Duration.zero}) async {
    _path = path;
    _position = start;
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
  test('单播放器模式不创建或打开预加载解码器', () async {
    var created = 0;
    final pool = PlayerPool(
      preloadEnabled: false,
      playerFactory: () {
        created++;
        return FakePlayerService();
      },
    );
    await pool.initialize();
    await pool.playMedia('current.mp4');
    await pool.preloadNext('next.mp4');
    await pool.swap();
    expect(created, 1);
    expect(pool.nextPlayer, isNull);
    expect(pool.currentPlayer!.currentPath, 'current.mp4');
    await pool.dispose();
  });

  test('桌面只用两个解码器，前进后可复用刚暂停的上一条', () async {
    final pool = PlayerPool(playerFactory: FakePlayerService.new);
    await pool.initialize();
    expect(pool.players, hasLength(2));
    await pool.playMedia('current.mp4');
    await pool.currentPlayer!.seekTo(const Duration(seconds: 7));
    final first = pool.currentPlayer;
    await pool.preloadNext('next.mp4', start: const Duration(seconds: 5));
    await pool.advanceToNext();
    expect(pool.currentPlayer!.currentPath, 'next.mp4');
    expect(pool.currentPlayer!.isPlaying, true);
    expect(
      pool.hasPreloadedPrevious('current.mp4', const Duration(seconds: 7)),
      true,
    );
    await pool.goToPrevious('current.mp4');
    expect(pool.currentPlayer, same(first));
    expect(pool.currentPlayer!.position.inSeconds, 7);
    await pool.dispose();
  });

  test('连续预加载与交接串行，旧请求不会覆盖正在播放的文件', () async {
    final slow = SlowOpenPlayer();
    var created = 0;
    final pool = PlayerPool(
      playerFactory: () => created++ == 0 ? FakePlayerService() : slow,
    );
    await pool.initialize();
    await pool.playMedia('current.mp4');
    final preload = pool.preloadNext('next.mp4');
    await slow.started.future;
    final swap = pool.swapToNext();
    final stale = pool.preloadNext('stale.mp4');
    slow.gate.complete();
    await Future.wait([preload, swap, stale]);
    expect(pool.currentPlayer, same(slow));
    expect(pool.currentPlayer!.currentPath, 'next.mp4');
    expect(pool.nextPlayer!.currentPath, 'current.mp4');
    await pool.dispose();
  });

  test('关闭等待在途预加载完成后释放播放器', () async {
    final slow = SlowOpenPlayer();
    var created = 0;
    final pool = PlayerPool(
      playerFactory: () => created++ == 0 ? FakePlayerService() : slow,
    );
    await pool.initialize();
    final preload = pool.preloadNext('next.mp4');
    await slow.started.future;
    final closing = pool.dispose();
    var closed = false;
    closing.then((_) => closed = true);
    await Future<void>.delayed(Duration.zero);
    expect(closed, false);
    slow.gate.complete();
    await preload;
    await closing;
    expect(pool.players, isEmpty);
  });
}

class SlowOpenPlayer extends FakePlayerService {
  final started = Completer<void>();
  final gate = Completer<void>();
  @override
  Future<void> open(String path, {Duration start = Duration.zero}) async {
    started.complete();
    await gate.future;
    await super.open(path, start: start);
  }
}
