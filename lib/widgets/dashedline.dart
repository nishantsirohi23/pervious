import 'package:flutter/material.dart';

class DashedLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  DashedLine({
    this.width = double.infinity,
    this.height = 1,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _DashedLinePainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashSpace: dashSpace,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double startX = 0;
    final double endX = size.width;
    double currentX = 0;

    while (currentX < endX) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashLength, 0),
        paint,
      );
      currentX += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
