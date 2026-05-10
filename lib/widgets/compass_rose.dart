import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';

class CompassRose extends StatelessWidget {
  final double heading;

  const CompassRose({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return AnimatedRotation(
      turns: -heading / 360,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: SizedBox(
        width: 300,
        height: 300,
        child: CustomPaint(
          painter: _CompassRosePainter(isDark: isDark),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cardinal directions
              for (final entry in _cardinalOffsets.entries)
                _buildDirectionLabel(context, entry.key, entry.value),
              // Kaaba icon at center
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.mosque, size: 24, color: AppColors.gold),
                  const SizedBox(height: 4),
                  Text(
                    'KABE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionLabel(BuildContext context, String direction, double angle) {
    final isNorth = direction == 'N';
    final radians = angle * pi / 180;
    const radius = 115.0;
    final dx = radius * sin(radians);
    final dy = -radius * cos(radians);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(
        angle: 0,
        child: Text(
          direction,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isNorth ? AppColors.gold : AppTheme.textSecondary(context),
          ),
        ),
      ),
    );
  }

  static const Map<String, double> _cardinalOffsets = {
    'N': 0,
    'E': 90,
    'S': 180,
    'W': 270,
  };
}

class _CompassRosePainter extends CustomPainter {
  final bool isDark;
  const _CompassRosePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final circlePaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.2)
          : Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Radial gradient fill
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isDark
              ? const Color.fromRGBO(26, 51, 102, 0.5)
              : const Color.fromRGBO(139, 98, 0, 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, gradientPaint);

    // Tick marks
    for (int i = 0; i < 36; i++) {
      final angle = i * 10.0;
      if (angle % 90 == 0) continue; // Skip cardinal directions

      final isThick = angle % 30 == 0;
      final tickLength = isThick ? 15.0 : 8.0;
      final tickPaint = Paint()
        ..color = isDark
            ? Colors.white.withOpacity(isThick ? 0.5 : 0.2)
            : Colors.black.withOpacity(isThick ? 0.35 : 0.12)
        ..strokeWidth = 2;

      final radians = angle * pi / 180;
      final outerPoint = Offset(
        center.dx + (radius - 2) * sin(radians),
        center.dy - (radius - 2) * cos(radians),
      );
      final innerPoint = Offset(
        center.dx + (radius - 2 - tickLength) * sin(radians),
        center.dy - (radius - 2 - tickLength) * cos(radians),
      );

      canvas.drawLine(outerPoint, innerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
