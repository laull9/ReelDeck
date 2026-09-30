import 'package:flutter/services.dart';
import 'shortcut_binding.dart';

enum ShortcutActionCategory {
  playback('播放控制'),
  navigation('切换与浏览'),
  manage('标记与过滤'),
  display('界面与显示');

  final String label;
  const ShortcutActionCategory(this.label);
}

enum ShortcutAction {
  playPause(
    label: '播放 / 暂停',
    description: '暂停或恢复视频播放',
    category: ShortcutActionCategory.playback,
  ),
  seekForward(
    label: '快进',
    description: '向前快进 5 秒',
    category: ShortcutActionCategory.playback,
  ),
  seekBackward(
    label: '快退',
    description: '向后快退 5 秒',
    category: ShortcutActionCategory.playback,
  ),
  seekForwardLarge(
    label: '大幅快进',
    description: '向前快进 15 秒',
    category: ShortcutActionCategory.playback,
  ),
  seekBackwardLarge(
    label: '大幅快退',
    description: '向后快退 15 秒',
    category: ShortcutActionCategory.playback,
  ),
  next(
    label: '快速下一个',
    description: '切换到下一个视频',
    category: ShortcutActionCategory.navigation,
  ),
  previous(
    label: '上一个',
    description: '切换到上一个视频',
    category: ShortcutActionCategory.navigation,
  ),
  reshuffle(
    label: '重新打乱',
    description: '重新随机打乱播放队列',
    category: ShortcutActionCategory.navigation,
  ),
  favorite(
    label: '喜欢这个',
    description: '收藏或取消收藏当前视频',
    category: ShortcutActionCategory.manage,
  ),
  hideVideo(
    label: '隐藏这个',
    description: '隐藏当前视频，不再出现在队列中',
    category: ShortcutActionCategory.manage,
  ),
  hideFolder(
    label: '隐藏所在文件夹',
    description: '隐藏该视频所在的整个文件夹',
    category: ShortcutActionCategory.manage,
  ),
  toggleFullscreen(
    label: '全屏',
    description: '进入全屏播放',
    category: ShortcutActionCategory.display,
  ),
  exitFullscreen(
    label: '退出全屏',
    description: '退出全屏模式',
    category: ShortcutActionCategory.display,
  ),
  toggleMute(
    label: '静音 / 取消静音',
    description: '切换静音状态',
    category: ShortcutActionCategory.display,
  ),
  toggleInfo(
    label: '显示 / 隐藏信息',
    description: '显示或隐藏视频文件名与路径',
    category: ShortcutActionCategory.display,
  );

  final String label;
  final String description;
  final ShortcutActionCategory category;

  const ShortcutAction(
    {required this.label, required this.description, required this.category});

  List<ShortcutBinding> get defaultBindings {
    switch (this) {
      case ShortcutAction.playPause:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.space),
        ];
      case ShortcutAction.seekForward:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.arrowRight),
        ];
      case ShortcutAction.seekBackward:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.arrowLeft),
        ];
      case ShortcutAction.seekForwardLarge:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.arrowRight, isShift: true),
        ];
      case ShortcutAction.seekBackwardLarge:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.arrowLeft, isShift: true),
        ];
      case ShortcutAction.next:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.arrowDown),
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyJ),
        ];
      case ShortcutAction.previous:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.arrowUp),
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyK),
        ];
      case ShortcutAction.reshuffle:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyR),
        ];
      case ShortcutAction.favorite:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyF),
        ];
      case ShortcutAction.hideVideo:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyH),
        ];
      case ShortcutAction.hideFolder:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyH, isShift: true),
        ];
      case ShortcutAction.toggleFullscreen:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.enter),
        ];
      case ShortcutAction.exitFullscreen:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.escape),
        ];
      case ShortcutAction.toggleMute:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyM),
        ];
      case ShortcutAction.toggleInfo:
        return [
          ShortcutBinding.fromKey(LogicalKeyboardKey.keyI),
        ];
    }
  }

  static Map<ShortcutAction, List<ShortcutBinding>> createDefaultMap() {
    return {
      for (final action in ShortcutAction.values)
        action: List<ShortcutBinding>.from(action.defaultBindings),
    };
  }
}
