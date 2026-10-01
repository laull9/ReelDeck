import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../shortcuts/shortcut_action.dart';
import '../shortcuts/shortcut_binding.dart';

class FeedGestureHandler extends StatefulWidget {
  final Widget child;
  final bool animations;
  final bool doubleTapFavorite;
  final bool keyboardEnabled;
  final Widget? topOverlay;
  final Widget? bottomOverlay;
  final FutureOr<void> Function() onNext;
  final FutureOr<void> Function() onPrevious;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleFavorite;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForwardLarge;
  final VoidCallback onSeekBackwardLarge;
  final VoidCallback onHideVideo;
  final VoidCallback onHideFolder;
  final VoidCallback onReshuffle;
  final VoidCallback onToggleInfo;
  final VoidCallback? onToggleMute;
  final VoidCallback? onFullscreen;
  final VoidCallback? onExitFullscreen;
  final ValueChanged<double>? onSpeed;
  final Map<ShortcutAction, List<ShortcutBinding>>? shortcuts;

  const FeedGestureHandler({
    super.key,
    required this.child,
    this.animations = true,
    this.doubleTapFavorite = true,
    this.keyboardEnabled = true,
    this.topOverlay,
    this.bottomOverlay,
    required this.onNext,
    required this.onPrevious,
    required this.onTogglePlayPause,
    required this.onToggleFavorite,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onSeekForwardLarge,
    required this.onSeekBackwardLarge,
    required this.onHideVideo,
    required this.onHideFolder,
    required this.onReshuffle,
    required this.onToggleInfo,
    this.onToggleMute,
    this.onFullscreen,
    this.onExitFullscreen,
    this.onSpeed,
    this.shortcuts,
  });

  @override
  State<FeedGestureHandler> createState() => FeedGestureHandlerState();
}

class FeedGestureHandlerState extends State<FeedGestureHandler>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _animController;
  Animation<double>? _slideAnimation;
  bool _switching = false;
  double _viewportHeight = 800;

  double _dragOffset = 0.0;
  double _horizontalDrag = 0.0;
  bool _isAnimating = false;
  DateTime _lastScrollTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 180),
        )..addListener(() {
          if (mounted) {
            setState(() => _dragOffset = _slideAnimation?.value ?? 0);
          }
        });
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _animateSlideFrom(double initialOffset) async {
    await _animateSlide(initialOffset, 0);
  }

  Future<void> _animateSlide(double initialOffset, double targetOffset) async {
    if (!mounted) return;
    if (!widget.animations) {
      setState(() => _dragOffset = targetOffset);
      return;
    }
    _animController.stop();
    _isAnimating = true;
    _dragOffset = initialOffset;
    _slideAnimation = Tween<double>(
      begin: initialOffset,
      end: targetOffset,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_animController);
    try {
      await _animController.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
    if (mounted) {
      setState(() {
        _isAnimating = false;
        _dragOffset = targetOffset;
      });
    }
  }

  Future<void> _switch(bool next) async {
    if (_switching || _isAnimating) return;
    _switching = true;
    try {
      // 只移动旧画面。打开回调包含后台预加载，不能在它结束后再移动新视频。
      if (widget.animations) {
        await _animateSlide(
          _dragOffset,
          next ? -_viewportHeight : _viewportHeight,
        );
      }
      if (!mounted) return;
      setState(() {
        _dragOffset = 0;
      });
      final result = next ? widget.onNext() : widget.onPrevious();
      if (result is Future<void>) await result;
    } finally {
      _switching = false;
    }
  }

  void animateNext([double? height]) => unawaited(_switch(true));
  void animatePrevious([double? height]) => unawaited(_switch(false));

  void _handleScroll(PointerScrollEvent event, double height) {
    if (_isAnimating || _switching) return;
    final now = DateTime.now();
    if (now.difference(_lastScrollTime).inMilliseconds < 350) return;

    if (event.scrollDelta.dy > 20) {
      _lastScrollTime = now;
      animateNext(height);
    } else if (event.scrollDelta.dy < -20) {
      _lastScrollTime = now;
      animatePrevious(height);
    }
  }

  KeyEventResult _handleKeyEvent(
    FocusNode node,
    KeyEvent event,
    double height,
  ) {
    if (!widget.keyboardEnabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (ModalRoute.of(context)?.isCurrent != true) {
      return KeyEventResult.ignored;
    }

    final activeShortcuts =
        widget.shortcuts ?? ShortcutAction.createDefaultMap();
    final action = ShortcutBinding.matchAction(
      activeShortcuts,
      event,
      HardwareKeyboard.instance,
    );

    if (action == null) return KeyEventResult.ignored;

    switch (action) {
      case ShortcutAction.playPause:
        widget.onTogglePlayPause();
        return KeyEventResult.handled;
      case ShortcutAction.seekForward:
        widget.onSeekForward();
        return KeyEventResult.handled;
      case ShortcutAction.seekBackward:
        widget.onSeekBackward();
        return KeyEventResult.handled;
      case ShortcutAction.seekForwardLarge:
        widget.onSeekForwardLarge();
        return KeyEventResult.handled;
      case ShortcutAction.seekBackwardLarge:
        widget.onSeekBackwardLarge();
        return KeyEventResult.handled;
      case ShortcutAction.next:
        animateNext(height);
        return KeyEventResult.handled;
      case ShortcutAction.previous:
        animatePrevious(height);
        return KeyEventResult.handled;
      case ShortcutAction.reshuffle:
        widget.onReshuffle();
        return KeyEventResult.handled;
      case ShortcutAction.favorite:
        widget.onToggleFavorite();
        return KeyEventResult.handled;
      case ShortcutAction.hideVideo:
        widget.onHideVideo();
        return KeyEventResult.handled;
      case ShortcutAction.hideFolder:
        widget.onHideFolder();
        return KeyEventResult.handled;
      case ShortcutAction.toggleFullscreen:
        widget.onFullscreen?.call();
        return KeyEventResult.handled;
      case ShortcutAction.exitFullscreen:
        widget.onExitFullscreen?.call();
        return KeyEventResult.handled;
      case ShortcutAction.toggleMute:
        widget.onToggleMute?.call();
        return KeyEventResult.handled;
      case ShortcutAction.toggleInfo:
        widget.onToggleInfo();
        return KeyEventResult.handled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 800.0;
        _viewportHeight = height;

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) => _handleKeyEvent(node, event, height),
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                _handleScroll(pointerSignal, height);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) {},
              onVerticalDragCancel: () {
                if (!_switching && !_isAnimating) {
                  _animateSlideFrom(_dragOffset);
                }
              },
              onVerticalDragUpdate: (details) {
                if (_isAnimating || _switching) return;
                setState(() {
                  _dragOffset += details.delta.dy;
                });
              },
              onVerticalDragEnd: (details) {
                if (_isAnimating || _switching) return;
                final velocity = details.primaryVelocity ?? 0;
                if (_dragOffset < -60 || velocity < -400) {
                  animateNext(height);
                } else if (_dragOffset > 60 || velocity > 400) {
                  animatePrevious(height);
                } else {
                  _animateSlideFrom(_dragOffset);
                }
              },
              onHorizontalDragStart: (_) => _horizontalDrag = 0,
              onHorizontalDragUpdate: (details) {
                _horizontalDrag += details.delta.dx;
                if (_horizontalDrag > 35) {
                  _horizontalDrag = 0;
                  widget.onSeekForward();
                } else if (_horizontalDrag < -35) {
                  _horizontalDrag = 0;
                  widget.onSeekBackward();
                }
              },
              onTap: () {
                _focusNode.requestFocus();
                widget.onTogglePlayPause();
              },
              onDoubleTap: widget.doubleTapFavorite
                  ? widget.onToggleFavorite
                  : null,
              onLongPressStart: (_) => widget.onSpeed?.call(2),
              onLongPressEnd: (_) => widget.onSpeed?.call(1),
              onLongPressCancel: () => widget.onSpeed?.call(1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. 滑动视图容器
                  ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Transform.translate(
                          offset: Offset(0, _dragOffset),
                          child: widget.child,
                        ),
                        if (_dragOffset < 0)
                          Transform.translate(
                            offset: Offset(0, _dragOffset + height),
                            child: const ColoredBox(color: Colors.black),
                          ),
                        if (_dragOffset > 0)
                          Transform.translate(
                            offset: Offset(0, _dragOffset - height),
                            child: const ColoredBox(color: Colors.black),
                          ),
                      ],
                    ),
                  ),

                  // 2. 固定的顶部控制栏
                  if (widget.topOverlay != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: widget.topOverlay!,
                    ),

                  // 3. 固定的底部控制栏
                  if (widget.bottomOverlay != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: widget.bottomOverlay!,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
