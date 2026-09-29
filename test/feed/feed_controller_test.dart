import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/feed/feed_controller.dart';

void main() {
  group('FeedController Tests', () {
    test('Initial state is correct', () {
      final controller = FeedController();
      
      expect(controller.isPlaying, false);
      expect(controller.isFavorite, false);
      expect(controller.showOverlay, true);
      expect(controller.showInfo, true);
      expect(controller.videoFit, 'fit');
    });

    test('togglePlayPause updates state', () {
      final controller = FeedController();
      
      expect(controller.isPlaying, false);
      controller.togglePlayPause();
      expect(controller.isPlaying, true);
    });

    test('cycleVideoFit cycles correctly', () {
      final controller = FeedController();
      
      expect(controller.videoFit, 'fit');
      controller.cycleVideoFit();
      expect(controller.videoFit, 'fill');
      controller.cycleVideoFit();
      expect(controller.videoFit, 'original');
      controller.cycleVideoFit();
      expect(controller.videoFit, 'fit');
    });

    test('next and previous update paths mock', () {
      final controller = FeedController();
      
      controller.next();
      expect(controller.currentMediaId, 1);
      
      controller.previous();
      expect(controller.currentMediaId, 0);
    });
  });
}
