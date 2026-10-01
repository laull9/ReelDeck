import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'media_kit_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final MediaKitPlayerService player;
  final BoxFit fit;

  const VideoPlayerWidget({
    super.key,
    required this.player,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Video(
        key: ObjectKey(player.controller),
        controller: player.controller,
        fit: fit,
        controls: NoVideoControls,
        wakelock: false,
        // 应用统一处理后台暂停，避免多个 Video 重复调用播放器。
        pauseUponEnteringBackgroundMode: false,
      ),
      ValueListenableBuilder<bool>(
        valueListenable: player.presentationReady,
        builder: (_, ready, _) => ready
            ? const SizedBox.shrink()
            : const ColoredBox(color: Colors.black),
      ),
    ],
  );
}
