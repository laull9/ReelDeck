import 'package:flutter/material.dart';

class FeedProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onSeek;
  final ValueChanged<Duration>? onScrub;
  final VoidCallback? onScrubStart;
  final ValueChanged<Duration>? onScrubEnd;

  const FeedProgressBar({
    super.key,
    required this.position,
    required this.duration,
    this.onSeek,
    this.onScrub,
    this.onScrubStart,
    this.onScrubEnd,
  });

  @override
  State<FeedProgressBar> createState() => _FeedProgressBarState();
}

class _FeedProgressBarState extends State<FeedProgressBar> {
  bool _isDragging = false;
  double _dragRatio = 0.0;
  bool _isHovering = false;

  double get _currentRatio {
    if (_isDragging) return _dragRatio;
    final total = widget.duration.inMilliseconds;
    if (total <= 0) return 0.0;
    return (widget.position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  Duration _ratioToDuration(double ratio) {
    final total = widget.duration.inMilliseconds;
    return Duration(milliseconds: (total * ratio).round());
  }

  void _updateRatio(Offset localPosition, double width) {
    if (width <= 0) return;
    final ratio = (localPosition.dx / width).clamp(0.0, 1.0);
    setState(() {
      _dragRatio = ratio;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeRatio = _currentRatio;
    final isInteractive = _isDragging || _isHovering;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              _isDragging = true;
              _updateRatio(details.localPosition, width);
              widget.onScrubStart?.call();
              widget.onScrub?.call(_ratioToDuration(_dragRatio));
            },
            onHorizontalDragUpdate: (details) {
              _updateRatio(details.localPosition, width);
              widget.onScrub?.call(_ratioToDuration(_dragRatio));
            },
            onHorizontalDragEnd: (_) {
              final finalTarget = _ratioToDuration(_dragRatio);
              setState(() {
                _isDragging = false;
              });
              widget.onScrubEnd?.call(finalTarget);
            },
            onTapDown: (details) {
              _updateRatio(details.localPosition, width);
              final target = _ratioToDuration(_dragRatio);
              widget.onSeek?.call(target);
            },
            child: Container(
              height: 24,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // 基础进度条轨道（包含背景与高亮）
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: isInteractive ? 6 : 3,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: activeRatio.clamp(0.0, 1.0),
                      child: Container(color: Colors.white),
                    ),
                  ),

                  // 拖动手柄 Thumb
                  Positioned(
                    left: ((width.isFinite ? width : 0.0) * activeRatio - 6)
                        .clamp(0.0, (width.isFinite ? width - 12 : 0.0)),
                    child: AnimatedScale(
                      scale: isInteractive ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(100),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
