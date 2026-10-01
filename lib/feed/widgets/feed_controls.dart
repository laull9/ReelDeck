import 'package:flutter/material.dart';

import '../feed_controller.dart';
import 'formatters.dart';
import 'progress_bar.dart';

class FeedControls extends StatelessWidget {
  final FeedController feed;
  final bool detailed;
  final bool awake;
  final VoidCallback next;
  final VoidCallback previous;
  const FeedControls({
    super.key,
    required this.feed,
    required this.detailed,
    required this.awake,
    required this.next,
    required this.previous,
  });

  String _time(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final settings = feed.settings;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (detailed && settings.showFilename)
              Text(
                feed.currentFileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (detailed && settings.showFolder)
              Text(
                feed.currentFolder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            if (detailed)
              Wrap(
                spacing: 8,
                children: [
                  if (settings.showFileSize && feed.currentFileSize != null)
                    Text(
                      formatFileSize(feed.currentFileSize!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  if (settings.showVideoFormat)
                    Text(
                      feed.currentFileExtension.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            if (awake)
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    IconButton(
                      tooltip: '上一条',
                      onPressed: previous,
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      tooltip: feed.isPlaying ? '暂停' : '播放',
                      onPressed: feed.togglePlayPause,
                      icon: Icon(
                        feed.isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                    IconButton(
                      tooltip: '下一条',
                      onPressed: next,
                      icon: const Icon(Icons.skip_next),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${_time(feed.position)} / ${_time(feed.duration)}',
                      ),
                    ),
                    IconButton(
                      tooltip: '全屏',
                      onPressed: feed.toggleFullscreen,
                      icon: Icon(
                        feed.fullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                      ),
                    ),
                    IconButton(
                      tooltip: '重新排列队列',
                      onPressed: feed.reshuffle,
                      icon: const Icon(Icons.shuffle),
                    ),
                    IconButton(
                      tooltip: '静音',
                      onPressed: feed.toggleMute,
                      icon: Icon(
                        feed.muted ? Icons.volume_off : Icons.volume_up,
                      ),
                    ),
                  ],
                ),
              ),
            FeedProgressBar(
              animations: settings.animations,
              position: feed.position,
              duration: feed.duration,
              onSeek: feed.seekTo,
              onScrubStart: feed.startScrub,
              onScrub: feed.scrubTo,
              onScrubEnd: feed.endScrub,
            ),
          ],
        ),
      ),
    );
  }
}
