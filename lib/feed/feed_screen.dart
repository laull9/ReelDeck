import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../l10n/app_localizations.dart';
import '../player/media_kit_player.dart';
import '../player/video_player_widget.dart';
import '../sources/source_manager.dart';
import 'feed_controller.dart';
import 'feed_gestures.dart';
import 'widgets/action_buttons.dart';
import 'widgets/feed_controls.dart';
import 'widgets/scope_picker.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Timer? _hideTimer;
  bool _awake = true;
  String _lastMode = 'full';
  DateTime? _tapWakeAt;

  void _wake() {
    if (!_awake) setState(() => _awake = true);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _awake = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _awake = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  final GlobalKey<FeedGestureHandlerState> _gestureKey =
      GlobalKey<FeedGestureHandlerState>();

  Future<void> _navigate(BuildContext context, String route) async {
    final feed = context.read<FeedController>();
    await feed.suspend();
    if (context.mounted) await Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sources = context.watch<SourceManager>();
    final feed = context.watch<FeedController>();
    final settings = feed.settings;
    if (_lastMode != settings.overlayMode) {
      _lastMode = settings.overlayMode;
      _awake = settings.overlayMode == 'full';
    }
    final detailed = feed.showInfo && settings.overlayMode == 'full';
    final showProgress = settings.overlayMode != 'none' || _awake;
    final players = feed.pool.players
        .whereType<MediaKitPlayerService>()
        .toList();
    final activeIndex = players.indexWhere((p) => identical(p, feed.player));
    final error = feed.error ?? sources.error;
    final fit = switch (feed.videoFit) {
      'fill' => BoxFit.cover,
      'original' => BoxFit.none,
      _ => BoxFit.contain,
    };
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: MouseRegion(
          onHover: (_) => _wake(),
          child: Listener(
            onPointerDown: (_) {
              final wasAwake = _awake;
              _wake();
              if (!wasAwake && settings.overlayMode != 'full') {
                _tapWakeAt = DateTime.now();
              }
            },
            child: FeedGestureHandler(
              key: _gestureKey,
              displayedMediaId: feed.displayedMediaId,
              canGoNext: feed.canGoNext,
              canGoPrevious: feed.canGoPrevious,
              shortcuts: feed.settings.shortcuts,
              animations: settings.animations,
              doubleTapFavorite: settings.doubleTapFavorite,
              keyboardEnabled: settings.keyboardEnabled,
              swipeEnabled: feed.currentMediaId != null && !feed.busy,
              onNext: feed.next,
              onPrevious: feed.previous,
              onTogglePlayPause: () {
                if (_tapWakeAt != null &&
                    DateTime.now().difference(_tapWakeAt!).inMilliseconds <
                        500) {
                  _tapWakeAt = null;
                  return;
                }
                feed.togglePlayPause();
              },
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
                  if (players.isNotEmpty)
                    IndexedStack(
                      index: activeIndex < 0 ? 0 : activeIndex,
                      sizing: StackFit.expand,
                      children: [
                        for (final player in players)
                          VideoPlayerWidget(
                            key: ObjectKey(player),
                            player: player,
                            fit: fit,
                          ),
                      ],
                    ),
                  if (feed.imageBytes != null)
                    TickerMode(
                      enabled: feed.isPlaying,
                      child: Image.memory(
                        feed.imageBytes!,
                        key: ValueKey(feed.currentMediaId),
                        fit: fit,
                        errorBuilder: (_, error, stack) =>
                            Center(child: Text(l10n.imageDecodeFailed)),
                      ),
                    ),
                  if (feed.currentPath == null)
                    const ColoredBox(color: Colors.black),
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
                                  ? l10n.noVideosInRange
                                  : l10n.selectFolderToStart,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (sources.hasSources) ...[
                              const SizedBox(height: 12),
                              Text(
                                l10n.checkFoldersOrRescan,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white60),
                              ),
                            ],
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: sources.isScanning
                                  ? null
                                  : sources.pickAndAddFolder,
                              icon: const Icon(
                                Icons.create_new_folder_outlined,
                              ),
                              label: Text(l10n.addFolder),
                            ),
                            if (sources.hasSources)
                              TextButton(
                                onPressed: feed.resetHidden,
                                child: Text(l10n.restoreHidden),
                              ),
                          ],
                        ),
                      ),
                    ),
                  // 后台刷新目录时继续播放，不遮挡当前视频。
                  if (feed.busy ||
                      (sources.isScanning && feed.currentMediaId == null))
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
                                      child: Text(l10n.retry),
                                    ),
                                    TextButton(
                                      onPressed: feed.next,
                                      child: Text(l10n.skip),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          _navigate(context, AppRoutes.sources),
                                      child: Text(l10n.manageFolders),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_awake || feed.currentMediaId == null || error != null)
                    Positioned(
                      top: 8,
                      left: 16,
                      right: 8,
                      child: Row(
                        children: [
                          if (MediaQuery.sizeOf(context).width > 480) ...[
                            const Text(
                              'ReelDeck',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: ScopePicker(feed: feed, sources: sources),
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
                            tooltip: l10n.manageFolders,
                            icon: const Icon(Icons.folder_open),
                            onPressed: () =>
                                _navigate(context, AppRoutes.sources),
                          ),
                          IconButton(
                            tooltip: l10n.settings,
                            icon: const Icon(Icons.settings),
                            onPressed: () =>
                                _navigate(context, AppRoutes.settings),
                          ),
                        ],
                      ),
                    ),
                  if (feed.currentMediaId != null &&
                      (showProgress || detailed || _awake))
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (detailed || _awake)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 12,
                                bottom: 8,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ActionButtons(visible: true),
                              ),
                            ),
                          if (showProgress)
                            FeedControls(
                              feed: feed,
                              detailed: detailed,
                              awake: _awake,
                              next: () =>
                                  _gestureKey.currentState?.animateNext(),
                              previous: () =>
                                  _gestureKey.currentState?.animatePrevious(),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
