import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/feed/playback_error_log.dart';

void main() {
  test('播放错误按 100 条保留并持久化，清除可恢复', () async {
    final folder = await Directory.systemTemp.createTemp('reeldeck-errors');
    try {
      final file = File('${folder.path}/errors.json');
      final log = PlaybackErrorLog();
      await log.load(file);
      for (var i = 0; i < 110; i++) {
        log.add('error $i', '$i.mp4');
      }
      await log.flushed;
      final restored = PlaybackErrorLog();
      await restored.load(file);
      expect(restored.entries, hasLength(100));
      expect(restored.entries.first['name'], '109.mp4');
      restored.clear();
      await restored.flushed;
      final cleared = PlaybackErrorLog();
      await cleared.load(file);
      expect(cleared.entries, isEmpty);
    } finally {
      await folder.delete(recursive: true);
    }
  });
}
