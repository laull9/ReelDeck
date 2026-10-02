import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reel_deck/feed/feed_controller.dart';
import 'package:reel_deck/feed/feed_screen.dart';
import 'package:reel_deck/feed/feed_gestures.dart';
import 'package:reel_deck/sources/source_manager.dart';

void main() {
  testWidgets('空状态在手机宽度显示添加目录入口，无溢出', (tester) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sources = SourceManager();
    final feed = FeedController(sourceManager: sources);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sources),
          ChangeNotifierProvider.value(value: feed),
        ],
        child: const MaterialApp(home: FeedScreen()),
      ),
    );
    expect(find.text('选择一个文件夹，开始随机播放'), findsOneWidget);
    expect(find.text('添加目录'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('滑到下方进入下一条，滑回上方和键盘返回有效', (tester) async {
    var next = 0, previous = 0;
    void noop() {}
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedGestureHandler(
            onNext: () => next++,
            onPrevious: () => previous++,
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
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    await tester.drag(find.byType(FeedGestureHandler), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(next, 1);
    expect(previous, 0);
    await tester.drag(find.byType(FeedGestureHandler), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(previous, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.pumpAndSettle();
    expect(next, 2);
  });
  testWidgets('触控板小滚动累积触发，反向滚动立即返回', (tester) async {
    var next = 0, previous = 0;
    void noop() {}
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedGestureHandler(
            animations: false,
            onNext: () => next++,
            onPrevious: () => previous++,
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
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
    Future<void> scroll(double delta) async {
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: const Offset(200, 200),
          scrollDelta: Offset(0, delta),
        ),
      );
      await tester.pump();
    }

    await scroll(8);
    await scroll(8);
    expect(next, 0);
    await scroll(8);
    expect(next, 1);
    await scroll(-12);
    await scroll(-12);
    expect(previous, 1);
    await scroll(-30);
    expect(previous, 1);
    await tester.pumpAndSettle();
  });
}
