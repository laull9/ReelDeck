import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../shortcuts/shortcut_action.dart';
import '../shortcuts/shortcut_binding.dart';

class FeedGestureHandler extends StatefulWidget {
  final Widget child;
  final Widget? incomingChild;
  final Widget? topOverlay;
  final Widget? bottomOverlay;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
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
    this.incomingChild,
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

  double _dragOffset = 0.0;
  double _horizontalDrag = 0.0;
  bool _isAnimating = false;
  DateTime _lastScrollTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _animateSlideFrom(double initialOffset) {
    if (!mounted) return;
    _animController.stop();
    _isAnimating = true;
    _dragOffset = initialOffset;
    _slideAnimation = Tween<double>(begin: initialOffset, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _dragOffset = _slideAnimation!.value;
        });
      });

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _animController.removeStatusListener(statusListener);
        _isAnimating = false;
        _dragOffset = 0.0;
        if (mounted) setState(() {});
      }
    }

    _animController.addStatusListener(statusListener);
    _animController.forward(from: 0.0);
  }

  void animateNext([double? height]) {
    widget.onNext();
    _animateSlideFrom(120.0);
  }

  void animatePrevious([double? height]) {
    widget.onPrevious();
    _animateSlideFrom(-120.0);
  }

  void _handleScroll(PointerScrollEvent event, double height) {
    if (_isAnimating) return;
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
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (ModalRoute.of(context)?.isCurrent != true) {
      return KeyEventResult.ignored;
    }

    final activeShortcuts = widget.shortcuts ?? ShortcutAction.createDefaultMap();
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
        widget.onNext();
        return KeyEventResult.handled;
      case ShortcutAction.previous:
        widget.onPrevious();
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

  Widget _buildPlaceholder({required bool isNext}) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Icon(
          isNext ? Icons.skip_next : Icons.skip_previous,
          size: 48,
          color: Colors.white24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 800.0;

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
              onVerticalDragStart: (_) {
                if (_isAnimating) {
                  _animController.stop();
                  _isAnimating = false;
                }
              },
              onVerticalDragUpdate: (details) {
                if (_isAnimating) return;
                setState(() {
                  _dragOffset += details.delta.dy;
                });
              },
              onVerticalDragEnd: (details) {
                if (_isAnimating) return;
                final velocity = details.primaryVelocity ?? 0;
                if (_dragOffset < -60 || velocity < -400) {
                  widget.onNext();
                  _animateSlideFrom(120.0);
                } else if (_dragOffset > 60 || velocity > 400) {
                  widget.onPrevious();
                  _animateSlideFrom(-120.0);
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
              onDoubleTap: widget.onToggleFavorite,
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
                            child: widget.incomingChild ??
                                _buildPlaceholder(isNext: true),
                          ),
                        if (_dragOffset > 0)
                          Transform.translate(
                            offset: Offset(0, _dragOffset - height),
                            child: _buildPlaceholder(isNext: false),
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
