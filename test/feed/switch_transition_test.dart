import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/feed/feed_gestures.dart';

void main() {
  testWidgets('打开未完成时不做入场动画，也不接受重复切换', (tester) async {
    final opened = Completer<void>();
    final key = GlobalKey<FeedGestureHandlerState>();
    var switches = 0;
    void noop() {}
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedGestureHandler(
            key: key,
            onNext: () {
              switches++;
              return opened.future;
            },
            onPrevious: noop,
            onTogglePlayPause: noop,
            onToggleFavorite: noop,
            onSeekForward: noop,
            onSeekBackward: noop,
            onSeekForwardLarge: noop,
            onSeekBackwardLarge: noop,
            onHideVideo: noop,
            onHideFolder: noop,
            onReshuffle: noop,
            onToggleInfo: noop,
            child: const Text('实际画面'),
          ),
        ),
      ),
    );
    key.currentState!.animateNext();
    await tester.pump();
    key.currentState!.animateNext();
    key.currentState!.animatePrevious();
    await tester.pump(const Duration(milliseconds: 300));
    expect(switches, 1);
    final transform = tester.widget<Transform>(find.byType(Transform).first);
    expect(transform.transform.storage[13], 0);
    expect(find.byIcon(Icons.skip_next), findsNothing);
    opened.complete();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(switches, 1);
    expect(tester.takeException(), isNull);
  });
}
