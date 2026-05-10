import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'geometric_pattern.dart';
import 'stars_view.dart';

class IslamicBackground extends StatelessWidget {
  const IslamicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.backgroundGradient
                : AppColors.lightBackgroundGradient,
          ),
        ),
        const Positioned.fill(child: GeometricPattern()),
        if (isDark) Positioned.fill(child: StarsView()),
      ],
    );
  }
}
