import 'dart:math';
import 'package:flutter/material.dart';

class StarsView extends StatelessWidget {
  StarsView({super.key});

  final List<_Star> _stars = List.generate(40, (_) {
    final rng = Random();
    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble() * 0.4,
      size: 1.0 + rng.nextDouble() * 2.0,
      opacity: 0.3 + rng.nextDouble() * 0.5,
    );
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _stars.map((star) {
            return Positioned(
              left: star.x * constraints.maxWidth,
              top: star.y * constraints.maxHeight,
              child: Container(
                width: star.size,
                height: star.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(star.opacity),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double opacity;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}
