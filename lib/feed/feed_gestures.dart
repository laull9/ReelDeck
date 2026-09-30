import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class FeedGestureHandler extends StatefulWidget {
  final Widget child;
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

  const FeedGestureHandler({
    super.key,
    required this.child,
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
  });

  @override
  State<FeedGestureHandler> createState() => _FeedGestureHandlerState();
}

class _FeedGestureHandlerState extends State<FeedGestureHandler> {
  final FocusNode _focusNode = FocusNode();
  DateTime _lastScrollTime = DateTime.fromMillisecondsSinceEpoch(0);
  double _scroll = 0, _drag = 0;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleScroll(PointerScrollEvent event) {
    final now = DateTime.now();
    if (now.difference(_lastScrollTime).inMilliseconds < 300) {
      return; // cooldown
    }

    _scroll += event.scrollDelta.dy;
    if (_scroll > 45) {
      _scroll = 0;
      _lastScrollTime = now;
      widget.onNext();
    } else if (_scroll < -45) {
      _scroll = 0;
      _lastScrollTime = now;
      widget.onPrevious();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (ModalRoute.of(context)?.isCurrent != true) {
            return KeyEventResult.ignored;
          }
          final isShift = HardwareKeyboard.instance.isShiftPressed;

          if (event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onFullscreen?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onExitFullscreen?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.keyM) {
            widget.onToggleMute?.call();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
              event.logicalKey == LogicalKeyboardKey.keyJ) {
            widget.onNext();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.keyK) {
            widget.onPrevious();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.space) {
            widget.onTogglePlayPause();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (isShift) {
              widget.onSeekForwardLarge();
            } else {
              widget.onSeekForward();
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (isShift) {
              widget.onSeekBackwardLarge();
            } else {
              widget.onSeekBackward();
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
            widget.onToggleFavorite();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
            if (isShift) {
              widget.onHideFolder();
            } else {
              widget.onHideVideo();
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
            widget.onReshuffle();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
            widget.onToggleInfo();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            _handleScroll(pointerSignal);
          }
        },
        child: MouseRegion(
          onHover: (_) {
            // Desktop hover overlay triggering logic can be added here
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: (_) {
              _drag = 0;
            },
            onVerticalDragUpdate: (d) {
              _drag += d.delta.dy;
            },
            onVerticalDragEnd: (d) {
              final velocity = d.primaryVelocity ?? 0;
              if (_drag < -60 || velocity < -500) {
                widget.onNext();
              } else if (_drag > 60 || velocity > 500) {
                widget.onPrevious();
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
            onHorizontalDragStart: (_) {
              _drag = 0;
            },
            onHorizontalDragUpdate: (d) {
              _drag += d.delta.dx;
              if (_drag > 30) {
                _drag = 0;
                widget.onSeekForward();
              }
              if (_drag < -30) {
                _drag = 0;
                widget.onSeekBackward();
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
