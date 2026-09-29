import 'package:flutter/material.dart';

/// Wraps a child widget and handles feed gestures such as vertical swipes,
/// tap for play/pause, and double tap for favorite.
class FeedGestureHandler extends StatelessWidget {
  const FeedGestureHandler({
    super.key,
    required this.child,
    this.onSwipeUp,
    this.onSwipeDown,
    this.onTap,
    this.onDoubleTap,
    this.onPlayPause,
    this.onFavorite,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Callback triggered when a vertical upward swipe is detected.
  final VoidCallback? onSwipeUp;

  /// Callback triggered when a vertical downward swipe is detected.
  final VoidCallback? onSwipeDown;

  /// Callback triggered on a single tap.
  final VoidCallback? onTap;

  /// Callback triggered on a double tap.
  final VoidCallback? onDoubleTap;

  /// Optional alias callback triggered on single tap (play/pause).
  final VoidCallback? onPlayPause;

  /// Optional alias callback triggered on double tap (favorite).
  final VoidCallback? onFavorite;

  void _handleTap() {
    onTap?.call();
    onPlayPause?.call();
  }

  void _handleDoubleTap() {
    onDoubleTap?.call();
    onFavorite?.call();
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? details.velocity.pixelsPerSecond.dy;
    if (velocity < 0) {
      onSwipeUp?.call();
    } else if (velocity > 0) {
      onSwipeDown?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTap = onTap != null || onPlayPause != null;
    final hasDoubleTap = onDoubleTap != null || onFavorite != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: _handleVerticalDragEnd,
      onTap: hasTap ? _handleTap : null,
      onDoubleTap: hasDoubleTap ? _handleDoubleTap : null,
      child: child,
    );
  }
}
