import 'dart:async';
import 'dart:io';

import 'player_service.dart';
import 'media_kit_player.dart';

/// 当前播放器与备用播放器交接；Android 备用实例只做软解预加载。
class PlayerPool {
  final PlayerService Function() _playerFactory;
  final bool preloadEnabled;
  final bool _nativeFactory;
  final bool softwarePreload;
  final List<PlayerService> _players = [];
  PlayerService? _currentPlayer;
  PlayerService? _sparePlayer;
  Duration? _preloadedStart;
  Future<void> _pending = Future.value();
  bool _disposed = false;

  PlayerPool({
    PlayerService Function()? playerFactory,
    bool? preloadEnabled,
    bool? softwarePreload,
  }) : _playerFactory = playerFactory ?? MediaKitPlayerService.new,
       _nativeFactory = playerFactory == null,
       softwarePreload = softwarePreload ?? Platform.isAndroid,
       preloadEnabled = preloadEnabled ?? true;

  List<PlayerService> get players => List.unmodifiable(_players);
  PlayerService? get currentPlayer => _currentPlayer;
  PlayerService? get nextPlayer => _sparePlayer;
  PlayerService? get previousPlayer => _sparePlayer;

  bool hasPreloaded(String path, Duration start) =>
      _sparePlayer?.currentPath == path && _preloadedStart == start;
  bool hasPreloadedNext(String path, Duration start) =>
      hasPreloaded(path, start);
  bool hasPreloadedPrevious(String path, Duration start) =>
      hasPreloaded(path, start);

  Future<void> get settled => _pending;

  Future<void> _run(Future<void> Function() action) {
    final result = _pending.then((_) async {
      if (!_disposed) await action();
    });
    _pending = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<void> initialize() async {
    if (_currentPlayer != null) return;
    _currentPlayer = _playerFactory();
    _players.add(_currentPlayer!);
    if (preloadEnabled) {
      _sparePlayer = softwarePreload && _nativeFactory
          ? MediaKitPlayerService(decoderMode: 'no')
          : _playerFactory();
      _players.add(_sparePlayer!);
    }
  }

  Future<void> playMedia(String path) => _run(() async {
    await _currentPlayer?.open(path);
    await _currentPlayer?.play();
  });

  Future<void> preloadNext(String path, {Duration start = Duration.zero}) {
    // 捕获实例，排队期间发生交接则丢弃请求，不能覆盖正在播放的文件。
    final expected = _sparePlayer;
    return _run(() async {
      if (expected == null || !identical(expected, _sparePlayer)) return;
      if (hasPreloaded(path, start)) return;
      _preloadedStart = null;
      await expected.open(path, start: start);
      _preloadedStart = start;
    });
  }

  Future<void> preloadPrevious(String path, {Duration start = Duration.zero}) =>
      preloadNext(path, start: start);

  Future<void> swapToNext() => _run(() async {
    if (_currentPlayer == null || _sparePlayer == null) return;
    final previous = _currentPlayer!;
    if (softwarePreload && previous is MediaKitPlayerService) {
      // 先释放旧硬解，后台已准备的帧继续留在备用 Texture 中。
      await previous.releaseMedia();
    } else {
      await previous.pause();
    }
    _currentPlayer = _sparePlayer;
    _sparePlayer = previous;
    _preloadedStart = previous.position;
  });

  Future<void> swapToPrevious() => swapToNext();
  Future<void> swap() => swapToNext();

  Future<void> advanceToNext() async {
    await swapToNext();
    await _currentPlayer?.play();
  }

  Future<void> goToPrevious(String path) async {
    if (_sparePlayer?.currentPath == path) await swapToPrevious();
    if (_currentPlayer?.currentPath != path) await _currentPlayer?.open(path);
    await _currentPlayer?.play();
  }

  Future<void> releasePreloads() => _run(() async {
    _preloadedStart = null;
    if (_sparePlayer case final MediaKitPlayerService spare) {
      await spare.releaseMedia();
    } else {
      await _sparePlayer?.pause();
    }
  });

  Future<void> dispose() async {
    _disposed = true;
    await _pending;
    for (final player in _players) {
      await player.dispose();
    }
    _currentPlayer = _sparePlayer = null;
    _players.clear();
  }
}
