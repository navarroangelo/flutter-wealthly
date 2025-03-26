import 'package:flutter/material.dart';

class ProgressBarPainter extends CustomPainter {
  final double progress;

  ProgressBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = const Color(0xFF83c5be)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = const Color(0xFF006d77)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14, // start at left
      3.14, // draw full half-circle
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14,
      3.14 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
