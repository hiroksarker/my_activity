import 'package:flutter/material.dart';

class GreenPillsWallpaper extends StatelessWidget {
  final Widget child;

  const GreenPillsWallpaper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade50,
                Colors.green.shade100,
                Colors.green.shade200,
              ],
            ),
          ),
        ),
        // Layered pills
        Positioned.fill(
          child: CustomPaint(
            painter: GreenPillsPainter(),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

class GreenPillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green.shade300.withOpacity(0.1);

    // Draw multiple pill shapes
    final pills = [
      // Top left pill
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.width * 0.2, -size.height * 0.1, size.width * 0.8, size.height * 0.4),
        const Radius.circular(100),
      ),
      // Bottom right pill
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4, size.height * 0.6, size.width * 0.8, size.height * 0.4),
        const Radius.circular(100),
      ),
      // Center pill
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.3, size.width * 0.6, size.height * 0.3),
        const Radius.circular(100),
      ),
    ];

    for (var pill in pills) {
      canvas.drawRRect(pill, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
