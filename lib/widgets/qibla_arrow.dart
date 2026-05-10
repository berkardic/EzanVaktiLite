import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';

class QiblaArrow extends StatelessWidget {
  final double heading;
  final double qiblaDirection;
  final String language;

  const QiblaArrow({
    super.key,
    required this.heading,
    required this.qiblaDirection,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: (qiblaDirection - heading) / 360,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Align(
          alignment: const Alignment(0, -0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.qiblaArrow,
                size: 50,
                color: AppColors.greenAccent,
                shadows: [
                  Shadow(
                    color: AppColors.greenAccent.withOpacity(0.6),
                    blurRadius: 15,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                language == 'tr' ? 'KİBLE' : language == 'ar' ? 'القبلة' : 'QIBLA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greenAccent,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
