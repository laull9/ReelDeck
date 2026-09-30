import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../player/media_kit_player.dart';
import '../player/video_player_widget.dart';
import '../sources/source_manager.dart';
import 'feed_controller.dart';
import 'feed_gestures.dart';
import 'widgets/action_buttons.dart';
import 'widgets/formatters.dart';
import 'widgets/progress_bar.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final GlobalKey<FeedGestureHandlerState> _gestureKey =
      GlobalKey<FeedGestureHandlerState>();

  Future<void> _navigate(BuildContext context, String route) async {
    final feed = context.read<FeedController>();
    await feed.suspend();
    if (context.mounted) await Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final sources = context.watch<SourceManager>();
    final feed = context.watch<FeedController>();
    final settings = feed.settings;
    final player = feed.player;
    final error = feed.error ?? sources.error;
    final fit = switch (feed.videoFit) {
      'fill' => BoxFit.cover,
      'original' => BoxFit.none,
      _ => BoxFit.contain,
    };
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FeedGestureHandler(
          key: _gestureKey,
          shortcuts: feed.settings.shortcuts,
          onNext: feed.next,
          onPrevious: feed.previous,
          incomingChild: (feed.pool.nextPlayer is MediaKitPlayerService &&
                  feed.pool.nextPlayer?.currentPath != null)
              ? VideoPlayerWidget(
                  player: feed.pool.nextPlayer as MediaKitPlayerService,
                  fit: fit,
                )
              : null,
          onTogglePlayPause: feed.togglePlayPause,
          onToggleFavorite: feed.toggleFavorite,
          onSeekForward: feed.seekForward,
          onSeekBackward: feed.seekBackward,
          onSeekForwardLarge: () =>
              feed.seekForward(amount: const Duration(seconds: 15)),
          onSeekBackwardLarge: () =>
              feed.seekBackward(amount: const Duration(seconds: 15)),
          onHideVideo: feed.hideCurrentVideo,
          onHideFolder: feed.hideCurrentFolder,
          onReshuffle: feed.reshuffle,
          onToggleInfo: feed.toggleInfo,
          onToggleMute: feed.toggleMute,
          onFullscreen: feed.toggleFullscreen,
          onExitFullscreen: feed.exitFullscreen,
          onSpeed: feed.setSpeed,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (feed.currentPath != null && player is MediaKitPlayerService)
                VideoPlayerWidget(player: player, fit: fit),
              if (feed.currentMediaId == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.video_library_outlined,
                          size: 56,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          sources.hasSources
                              ? '当前范围没有可播放的视频'
                              : '选择一个文件夹，开始随机播放',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sources.hasSources
                              ? '检查目录开关、隐藏记录，或重新扫描。'
                              : '视频留在原位置，收藏与播放记录只保存在本机。',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: sources.isScanning
                              ? null
                              : sources.pickAndAddFolder,
                          icon: const Icon(Icons.create_new_folder_outlined),
                          label: const Text('添加目录'),
                        ),
                        if (sources.hasSources)
                          TextButton(
                            onPressed: feed.resetHidden,
                            child: const Text('恢复所有隐藏项'),
                          ),
                      ],
                    ),
                  ),
                ),
              if (feed.busy || sources.isScanning)
                const Center(child: CircularProgressIndicator()),
              if (error != null)
                Center(
                  child: Card(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline),
                            const SizedBox(height: 12),
                            Text(error, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              children: [
                                TextButton(
                                  onPressed: feed.retry,
                                  child: const Text('重试'),
                                ),
                                TextButton(
                                  onPressed: feed.next,
                                  child: const Text('跳过'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _navigate(context, AppRoutes.sources),
                                  child: const Text('管理目录'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                left: 16,
                right: 8,
                child: Row(
                  children: [
                    const Text(
                      'ReelDeck',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value:
                              [
                                'all',
                                'favorites',
                                ...sources.sources.map((s) => 'source:${s.id}'),
                              ].contains(feed.scope)
                              ? feed.scope
                              : 'all',
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('全部视频'),
                            ),
                            const DropdownMenuItem(
                              value: 'favorites',
                              child: Text('收藏'),
                            ),
                            ...sources.sources.map(
                              (s) => DropdownMenuItem(
                                value: 'source:${s.id}',
                                child: Text(
                                  s.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) feed.setScope(value);
                          },
                        ),
                      ),
                    ),
                    if (feed.showInfo &&
                        settings.showQueueProgress &&
                        feed.queueLength > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shuffle,
                              size: 13,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${feed.queueIndex >= 0 ? feed.queueIndex + 1 : 0} / ${feed.queueLength}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    IconButton(
                      tooltip: '管理目录',
                      icon: const Icon(Icons.folder_open),
                      onPressed: () => _navigate(context, AppRoutes.sources),
                    ),
                    IconButton(
                      tooltip: '设置',
                      icon: const Icon(Icons.settings),
                      onPressed: () => _navigate(context, AppRoutes.settings),
                    ),
                  ],
                ),
              ),
              if (feed.currentMediaId != null) ...[
                Positioned(
                  right: 12,
                  bottom: 124,
                  child: ActionButtons(visible: feed.showInfo),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (feed.showInfo && settings.showFilename)
                        Text(
                          feed.currentFileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (feed.showInfo && settings.showFolder)
                        Text(
                          feed.currentFolder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      if (feed.showInfo &&
                          (settings.showFileSize || settings.showVideoFormat)) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (settings.showFileSize &&
                                feed.currentFileSize != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(22),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white12,
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sd_storage_outlined,
                                      size: 11,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      formatFileSize(feed.currentFileSize!),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (settings.showVideoFormat &&
                                feed.currentFileExtension.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(22),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white12,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  feed.currentFileExtension
                                      .toUpperCase()
                                      .replaceAll('.', ''),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      Row(
                        children: [
                          IconButton(
                            tooltip: '上一条',
                            onPressed: () {
                              final state = _gestureKey.currentState;
                              if (state != null) {
                                state.animatePrevious();
                              } else {
                                feed.previous();
                              }
                            },
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
                            onPressed: () {
                              final state = _gestureKey.currentState;
                              if (state != null) {
                                state.animateNext();
                              } else {
                                feed.next();
                              }
                            },
                            icon: const Icon(Icons.skip_next),
                          ),
                          Expanded(
                            child: Text(
                              '${_time(feed.position)} / ${_time(feed.duration)}',
                              textAlign: TextAlign.center,
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
                            tooltip: '重新随机排序',
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
                      const SizedBox(height: 4),
                      FeedProgressBar(
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _time(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';
}
