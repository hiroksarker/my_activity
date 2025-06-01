import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  const GradientBackground({required this.child, this.opacity = 0.85, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: opacity,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4F8CFF), // Blue
                  Color(0xFFB721FF), // Purple
                  Color(0xFFFF3A44), // Red
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
