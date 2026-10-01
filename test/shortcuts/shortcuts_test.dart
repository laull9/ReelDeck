import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reel_deck/feed/feed_gestures.dart';
import 'package:reel_deck/settings/settings.dart';
import 'package:reel_deck/shortcuts/shortcut_action.dart';
import 'package:reel_deck/shortcuts/shortcut_binding.dart';
import 'package:reel_deck/shortcuts/shortcuts_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShortcutBinding & ShortcutAction', () {
    test('默认按键完整性检查', () {
      final defaults = ShortcutAction.createDefaultMap();
      expect(defaults.length, ShortcutAction.values.length);
      expect(defaults[ShortcutAction.playPause]!.first.keyId,
          LogicalKeyboardKey.space.keyId);
      expect(defaults[ShortcutAction.favorite]!.first.keyId,
          LogicalKeyboardKey.keyF.keyId);
      expect(defaults[ShortcutAction.hideVideo]!.first.keyId,
          LogicalKeyboardKey.keyH.keyId);
      expect(defaults[ShortcutAction.hideFolder]!.first.isShift, isTrue);
    });

    test('按键匹配与修饰键', () {
      final binding = ShortcutBinding.fromKey(
        LogicalKeyboardKey.keyH,
        isShift: true,
      );

      expect(binding.isShift, isTrue);
      expect(binding.displayString(isMacOS: false), 'Shift + H');
      expect(binding.displayString(isMacOS: true), 'Shift + H');

      final ctrlBinding = ShortcutBinding.fromKey(
        LogicalKeyboardKey.keyS,
        isControl: true,
      );
      expect(ctrlBinding.displayString(isMacOS: false), 'Ctrl + S');
      expect(ctrlBinding.displayString(isMacOS: true), 'Control + S');
    });

    test('JSON 序列化与反序列化保持一致', () {
      const original = ShortcutBinding(
        keyId: 100,
        keyLabel: 'TestKey',
        isShift: true,
        isControl: true,
        isAlt: false,
        isMeta: true,
      );
      final json = original.toJson();
      final restored = ShortcutBinding.fromJson(json);
      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test('识别修饰键及键名显示', () {
      expect(ShortcutBinding.isModifierKey(LogicalKeyboardKey.shiftLeft), isTrue);
      expect(ShortcutBinding.isModifierKey(LogicalKeyboardKey.controlRight), isTrue);
      expect(ShortcutBinding.isModifierKey(LogicalKeyboardKey.keyA), isFalse);
      expect(ShortcutBinding.keyDisplayName(LogicalKeyboardKey.space), 'Space');
      expect(ShortcutBinding.keyDisplayName(LogicalKeyboardKey.arrowDown), '↓');
    });
  });

  group('AppSettings 快捷键持久化', () {
    late Directory tempDir;
    late File settingsFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('shortcuts_test_');
      settingsFile = File('${tempDir.path}/settings.json');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('修改快捷键、保存并重新加载', () async {
      final settings = AppSettings();
      await settings.load(settingsFile);

      // 将暂停改为 P，喜欢改为 L
      settings.updateShortcut(
        ShortcutAction.playPause,
        [ShortcutBinding.fromKey(LogicalKeyboardKey.keyP)],
      );
      settings.updateShortcut(
        ShortcutAction.favorite,
        [ShortcutBinding.fromKey(LogicalKeyboardKey.keyL)],
      );
      await settings.flushed;

      final reloaded = AppSettings();
      await reloaded.load(settingsFile);

      expect(
        reloaded.shortcuts[ShortcutAction.playPause]!.first.keyId,
        LogicalKeyboardKey.keyP.keyId,
      );
      expect(
        reloaded.shortcuts[ShortcutAction.favorite]!.first.keyId,
        LogicalKeyboardKey.keyL.keyId,
      );

      // 重置回默认值
      reloaded.resetShortcuts();
      await reloaded.flushed;

      final resetReloaded = AppSettings();
      await resetReloaded.load(settingsFile);
      expect(
        resetReloaded.shortcuts[ShortcutAction.playPause]!.first.keyId,
        LogicalKeyboardKey.space.keyId,
      );
    });
  });

  group('FeedGestureHandler 自定义快捷键响应', () {
    testWidgets('自定义快捷键触发对应操作', (tester) async {
      var paused = 0;
      var liked = 0;
      var hiddenVideo = 0;
      var hiddenFolder = 0;
      var nextCount = 0;
      var seekFwd = 0;
      void noop() {}

      final customShortcuts = {
        ...ShortcutAction.createDefaultMap(),
        ShortcutAction.playPause: [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyP),
        ],
        ShortcutAction.favorite: [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyL),
        ],
        ShortcutAction.hideVideo: [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyX),
        ],
        ShortcutAction.hideFolder: [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyX, isShift: true),
        ],
        ShortcutAction.next: [
          ShortcutBinding.fromKey(LogicalKeyboardKey.space),
        ],
        ShortcutAction.seekForward: [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyD),
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedGestureHandler(
              shortcuts: customShortcuts,
              onNext: () => nextCount++,
              onPrevious: noop,
              onTogglePlayPause: () => paused++,
              onToggleFavorite: () => liked++,
              onSeekForward: () => seekFwd++,
              onSeekBackward: noop,
              onSeekForwardLarge: noop,
              onSeekBackwardLarge: noop,
              onHideVideo: () => hiddenVideo++,
              onHideFolder: () => hiddenFolder++,
              onReshuffle: noop,
              onToggleInfo: noop,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

      // 按下自定义快捷键 P 触发暂停
      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      expect(paused, 1);

      // 原默认 Space 不再是暂停，而是自定义为下一个
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(nextCount, 1);
      expect(paused, 1);

      // 自定义 L 触发喜欢
      await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
      expect(liked, 1);

      // 自定义 X 触发隐藏视频
      await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
      expect(hiddenVideo, 1);

      // 自定义 D 触发快进
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      expect(seekFwd, 1);

      await tester.pumpAndSettle();
    });
  });

  group('ShortcutsScreen 界面交互', () {
    testWidgets('展示所有快捷键并支持删除与恢复默认', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final settings = AppSettings();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: settings,
          child: const MaterialApp(
            home: ShortcutsScreen(),
          ),
        ),
      );

      // 验证界面渲染各主要分类
      expect(find.text('播放控制'), findsOneWidget);
      expect(find.text('切换与浏览'), findsOneWidget);
      expect(find.text('标记与过滤'), findsOneWidget);
      expect(find.text('界面与显示'), findsOneWidget);

      // 验证具体操作项
      expect(find.text('播放 / 暂停'), findsOneWidget);
      expect(find.text('快速下一个'), findsOneWidget);
      expect(find.text('喜欢这个'), findsOneWidget);
      expect(find.text('隐藏这个'), findsOneWidget);

      // 找到第一个删除按钮并删除一个快捷键
      final chipDeleteIcons = find.byIcon(Icons.close);
      expect(chipDeleteIcons, findsWidgets);
      await tester.tap(chipDeleteIcons.first);
      await tester.pumpAndSettle();

      // 点击恢复默认
      final resetBtn = find.text('恢复默认');
      expect(resetBtn, findsOneWidget);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      // 对话框中点击确定重置
      expect(find.text('确定将所有快捷键重置为系统默认配置吗？'), findsOneWidget);
      await tester.tap(find.text('确定重置'));
      await tester.pumpAndSettle();

      expect(settings.shortcuts[ShortcutAction.playPause]!.isNotEmpty, isTrue);
    });
  });
}
