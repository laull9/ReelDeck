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
  });

  @override
  State<FeedGestureHandler> createState() => _FeedGestureHandlerState();
}

class _FeedGestureHandlerState extends State<FeedGestureHandler> {
  final FocusNode _focusNode = FocusNode();
  DateTime _lastScrollTime = DateTime.now();

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
    
    if (event.scrollDelta.dy > 10) {
      _lastScrollTime = now;
      widget.onNext();
    } else if (event.scrollDelta.dy < -10) {
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
          final isShift = HardwareKeyboard.instance.isShiftPressed;
          
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
            onTap: widget.onTogglePlayPause,
            onDoubleTap: widget.onToggleFavorite,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
