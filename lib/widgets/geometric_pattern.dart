import 'package:flutter/material.dart';

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const sp = 60.0;
    const s = 18.0;

    final rows = (size.height / sp).ceil() + 2;
    final cols = (size.width / sp).ceil() + 2;

    for (int row = 0; row <= rows; row++) {
      for (int col = 0; col <= cols; col++) {
        final x = col * sp + (row.isEven ? 0 : sp / 2);
        final y = row * sp * 0.866;
        final cx = x;
        final cy = y;

        final path = Path()
          ..moveTo(cx, cy - s)
          ..lineTo(cx + s * 0.7, cy - s * 0.3)
          ..lineTo(cx + s * 0.7, cy + s * 0.3)
          ..lineTo(cx, cy + s)
          ..lineTo(cx - s * 0.7, cy + s * 0.3)
          ..lineTo(cx - s * 0.7, cy - s * 0.3)
          ..close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GeometricPattern extends StatelessWidget {
  const GeometricPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.07,
      child: CustomPaint(
        painter: GeometricPatternPainter(),
        size: Size.infinite,
      ),
    );
  }
}
