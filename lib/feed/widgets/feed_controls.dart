import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
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
          mainAxisSize: MainAxisSize.min,
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
              // 保持单行：窄屏用紧凑按钮，仍放不下时整体缩小，不换行。
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) => IconButtonTheme(
                    data: constraints.maxWidth < 480
                        ? IconButtonThemeData(
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(6),
                              minimumSize: const Size(36, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                        : const IconButtonThemeData(),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l10n.previous,
                            onPressed: previous,
                            icon: const Icon(Icons.skip_previous),
                          ),
                          IconButton(
                            tooltip: feed.isPlaying ? l10n.pause : l10n.play,
                            onPressed: feed.togglePlayPause,
                            icon: Icon(
                              feed.isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.next,
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
                            tooltip: feed.fullscreen
                                ? l10n.exitFullscreen
                                : l10n.fullscreen,
                            onPressed: feed.toggleFullscreen,
                            icon: Icon(
                              feed.fullscreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.reshuffle,
                            onPressed: feed.reshuffle,
                            icon: const Icon(Icons.shuffle),
                          ),
                          IconButton(
                            tooltip: feed.muted ? l10n.unmute : l10n.mute,
                            onPressed: feed.toggleMute,
                            icon: Icon(
                              feed.muted ? Icons.volume_off : Icons.volume_up,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
