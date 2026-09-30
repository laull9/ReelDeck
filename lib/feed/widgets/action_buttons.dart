import 'package:flutter/material.dart';

import '../feed_controller.dart';

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
        duration: const Duration(milliseconds: 200),
        child: Consumer<FeedController>(
          builder: (context, controller, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
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
