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
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Black background when no video is loaded or fitting constraints
      child: Video(
        controller: player.controller,
        fit: fit,
        controls: NoVideoControls, // ReelDeck is a vertical feed, likely wants custom controls
      ),
    );
  }
}
