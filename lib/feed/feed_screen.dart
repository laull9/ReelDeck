import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../sources/source_manager.dart';
import 'feed_controller.dart';
import 'feed_gestures.dart';
import 'widgets/action_buttons.dart';
import 'widgets/empty_state.dart';
import 'widgets/progress_bar.dart';
import 'widgets/video_overlay.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, FeedController controller) {
    if (index > (_pageController.page ?? 0)) {
      controller.next();
    } else {
      controller.previous();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceManager = context.watch<SourceManager?>();
    final controller = context.watch<FeedController>();

    // Show empty state if no media discovered yet
    if (sourceManager != null && sourceManager.allMedia.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ],
        ),
        body: EmptyState(
          onPickFolder: () async {
            await sourceManager.pickAndAddFolder();
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FeedGestureHandler(
        onNext: () {
          if (_pageController.hasClients) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          controller.next();
        },
        onPrevious: () {
          if (_pageController.hasClients) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          controller.previous();
        },
        onTogglePlayPause: controller.togglePlayPause,
        onToggleFavorite: controller.toggleFavorite,
        onSeekForward: () =>
            controller.seekForward(amount: const Duration(seconds: 5)),
        onSeekBackward: () =>
            controller.seekBackward(amount: const Duration(seconds: 5)),
        onSeekForwardLarge: () =>
            controller.seekForward(amount: const Duration(seconds: 15)),
        onSeekBackwardLarge: () =>
            controller.seekBackward(amount: const Duration(seconds: 15)),
        onHideVideo: controller.hideCurrentVideo,
        onHideFolder: controller.hideCurrentFolder,
        onReshuffle: controller.reshuffle,
        onToggleInfo: controller.toggleInfo,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: (defaultTargetPlatform == TargetPlatform.windows ||
                      defaultTargetPlatform == TargetPlatform.macOS ||
                      defaultTargetPlatform == TargetPlatform.linux)
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (index) => _onPageChanged(index, controller),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: controller.currentPath != null
                      ? Text(
                          controller.currentFileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const CircularProgressIndicator(),
                );
              },
            ),

            // Top bar settings button
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: AnimatedOpacity(
                opacity: controller.showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white70),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.settings),
                ),
              ),
            ),

            // Bottom metadata overlay
            Positioned(
              bottom: 12,
              left: 0,
              right: 60,
              child: VideoOverlay(
                visible: controller.showOverlay,
                showInfo: controller.showInfo,
                folderName: controller.currentFolder,
                fileName: controller.currentFileName,
              ),
            ),

            // Right side action buttons
            Positioned(
              right: 16,
              bottom: 60,
              child: ActionButtons(
                visible: controller.showOverlay,
              ),
            ),

            // Bottom progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ProgressBar(
                progress: 0.0,
                onSeek: (val) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
