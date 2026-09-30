import 'package:flutter/material.dart';
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
  testWidgets('一次上滑只切换一条，向下滑和键盘返回有效', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 400));
    expect(next, 1);
    expect(previous, 0);
    await tester.drag(find.byType(FeedGestureHandler), const Offset(0, 200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(previous, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    expect(next, 2);
    await tester.pumpAndSettle();
  });
}
