part of 'feed_controller.dart';

extension FeedImages on FeedController {
  Future<void> _openImage(Media media, String path, Duration start) async {
    Uint8List? bytes;
    if (path.startsWith('content://')) {
      bytes = await StorageBridge.readImage(path);
    } else {
      final file = File(path);
      if (await file.length() > 64 * 1024 * 1024) {
        throw StateError('图片超过 64 MiB');
      }
      bytes = await file.readAsBytes();
    }
    if (bytes == null || bytes.isEmpty) throw StateError('无法读取图片');
    // 在交接前验证图片，损坏的图片走与视频相同的跳过流程。
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
    imageBytes = bytes;
    duration = Duration(seconds: settings.imageSeconds);
    position = start >= duration ? Duration.zero : start;
  }

  void _startImageClock() {
    _imageClock?.cancel();
    _imageClock = null;
    if (imageBytes == null || !_playing) return;
    final watch = Stopwatch()..start();
    var previous = Duration.zero;
    _imageClock = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final elapsed = watch.elapsed;
      if (!_isScrubbing) position += (elapsed - previous) * _imageRate;
      previous = elapsed;
      if (position >= duration) {
        position = duration;
        _completed = true;
        _imageClock?.cancel();
        _imageClock = null;
        next();
      }
      _notify();
    });
  }

  void _pauseImage() {
    _imageClock?.cancel();
    _imageClock = null;
    if (imageBytes != null) _playing = false;
  }
}
