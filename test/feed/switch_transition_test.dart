import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reel_deck/feed/feed_gestures.dart';

void main() {
  testWidgets('旧视频先离场，新视频显示后逐帧保持零偏移', (tester) async {
    final opened = Completer<void>();
    final key = GlobalKey<FeedGestureHandlerState>();
    var current = '旧视频';
    var switches = 0;
    void noop() {}
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => FeedGestureHandler(
              key: key,
              onNext: () {
                switches++;
                // 播放器先切换画面，后台预加载随后才结束。
                update(() => current = '新视频');
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
              child: Text(current),
            ),
          ),
        ),
      ),
    );
    final origin = tester.getTopLeft(find.text('旧视频'));
    key.currentState!.animateNext();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(switches, 0);
    expect(tester.getTopLeft(find.text('旧视频')).dy, lessThan(origin.dy));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(switches, 1);
    expect(tester.getTopLeft(find.text('新视频')), origin);
    key.currentState!.animateNext();
    await tester.pump(const Duration(seconds: 2));
    expect(switches, 1);
    expect(tester.getTopLeft(find.text('新视频')), origin);
    opened.complete();
    await tester.pump();
    // 回调完成后的每一帧都不能再出现延迟的 48 像素入场跳动。
    for (var frame = 0; frame < 15; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getTopLeft(find.text('新视频')), origin);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('关闭动画时立即切换，打开结束后不移动画面', (tester) async {
    final opened = Completer<void>();
    final key = GlobalKey<FeedGestureHandlerState>();
    var switches = 0;
    void noop() {}
    await tester.pumpWidget(
      MaterialApp(
        home: FeedGestureHandler(
          key: key,
          animations: false,
          onNext: noop,
          onPrevious: () {
            switches++;
            return opened.future;
          },
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
    );
    final origin = tester.getTopLeft(find.text('实际画面'));
    key.currentState!.animatePrevious();
    expect(switches, 1);
    await tester.pump();
    expect(tester.getTopLeft(find.text('实际画面')), origin);
    opened.complete();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('实际画面')), origin);
  });

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
