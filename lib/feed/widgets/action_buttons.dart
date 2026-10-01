import 'package:flutter/material.dart';

import '../feed_controller.dart';

import 'dart:io';

import 'playback_errors.dart';

import 'package:provider/provider.dart';

class ActionButtons extends StatelessWidget {
  final bool visible;

  const ActionButtons({super.key, required this.visible});

  void _showMoreMenu(BuildContext context, FeedController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('只播放所在目录'),
                onTap: () {
                  final media = controller.currentMedia;
                  Navigator.pop(context);
                  if (media != null) {
                    controller.setScope(controller.folderScope(media));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.launch),
                title: const Text('在文件管理器中显示'),
                subtitle: Platform.isAndroid
                    ? const Text('SAF 文件由授权的文档提供方管理')
                    : null,
                enabled: !Platform.isAndroid,
                onTap: () {
                  Navigator.pop(context);
                  controller.revealCurrent();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('移入回收站'),
                subtitle: Platform.isAndroid
                    ? const Text('Android 文档授权不提供统一回收站，请使用隐藏')
                    : null,
                enabled: !Platform.isAndroid,
                onTap: () async {
                  final media = controller.currentMedia;
                  final navigator = Navigator.of(context);
                  if (media == null) return;
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('移入系统回收站？'),
                      content: Text(media.fileName),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('移入回收站'),
                        ),
                      ],
                    ),
                  );
                  if (!context.mounted) return;
                  navigator.pop();
                  if (confirmed == true) {
                    await controller.trashCurrent(media.id);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off, color: Colors.white),
                title: const Text(
                  '隐藏视频',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  controller.hideCurrentVideo();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_off, color: Colors.white),
                title: const Text(
                  '隐藏所在目录（含子目录）',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  controller.hideCurrentFolder();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.aspect_ratio, color: Colors.white),
                title: const Text(
                  '切换画面适配',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  controller.cycleVideoFit();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.error_outline),
                title: const Text('播放错误记录'),
                onTap: () {
                  final parent = Navigator.of(context).context;
                  Navigator.pop(context);
                  showPlaybackErrors(parent, controller);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: context.watch<FeedController>().settings.animations
            ? const Duration(milliseconds: 160)
            : Duration.zero,
        child: Consumer<FeedController>(
          builder: (context, controller, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: controller.isFavorite ? '取消收藏' : '收藏',
                  icon: Icon(
                    controller.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: controller.isFavorite ? Colors.red : Colors.white,
                    size: 32,
                  ),
                  onPressed: () => controller.toggleFavorite(),
                ),
                const SizedBox(height: 16),
                IconButton(
                  tooltip: '更多操作',
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () => _showMoreMenu(context, controller),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
