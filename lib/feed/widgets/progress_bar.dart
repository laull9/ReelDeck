import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final ValueChanged<double>? onSeek;

  const ProgressBar({
    super.key,
    required this.progress,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (onSeek != null) {
          final box = context.findRenderObject() as RenderBox;
          final position = details.localPosition.dx;
          final width = box.size.width;
          double newProgress = (position / width).clamp(0.0, 1.0);
          onSeek!(newProgress);
        }
      },
      onTapDown: (details) {
        if (onSeek != null) {
          final box = context.findRenderObject() as RenderBox;
          final position = details.localPosition.dx;
          final width = box.size.width;
          double newProgress = (position / width).clamp(0.0, 1.0);
          onSeek!(newProgress);
        }
      },
      child: Container(
        height: 12,
        color: Colors.transparent, // expanded touch area
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 3,
          width: double.infinity,
          color: Colors.white30,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
