import 'package:flutter/material.dart';

class ProgressBarPainter extends CustomPainter {
  final double progress;

  ProgressBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final startAngle = -3.14;
    final sweepAngle = 3.14 * progress;

    final bgPaint = Paint()
      ..color = const Color(0xFF83c5be)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = const Color(0xFF006d77)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, 3.14, false, bgPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
