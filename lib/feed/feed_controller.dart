import 'package:flutter/foundation.dart';

/// Controller managing feed playback state and navigation.
class FeedController extends ChangeNotifier {
  FeedController({
    this.currentIndex = 0,
    this.isPlaying = true,
  });

  /// Current index in the feed.
  int currentIndex;

  /// Whether playback is currently active.
  bool isPlaying;

  /// Navigates to the next item in the feed.
  void next() {
    currentIndex++;
    notifyListeners();
  }

  /// Navigates to the previous item in the feed.
  void previous() {
    if (currentIndex > 0) {
      currentIndex--;
      notifyListeners();
    }
  }

  /// Toggles between play and pause states.
  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }
}
