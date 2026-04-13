import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

class GridPainter extends CustomPainter {
  GridPainter(this.transform);

  final Matrix4 transform;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double x = -4000; x <= 4000; x += 80) {
      final start = _worldToScreen(Offset(x, -4000));
      final end = _worldToScreen(Offset(x, 4000));
      canvas.drawLine(start, end, paint);
    }

    for (double y = -4000; y <= 4000; y += 80) {
      final start = _worldToScreen(Offset(-4000, y));
      final end = _worldToScreen(Offset(4000, y));
      canvas.drawLine(start, end, paint);
    }
  }

  Offset _worldToScreen(Offset worldPoint) {
    final vector = Vector3(worldPoint.dx, worldPoint.dy, 0);
    vector.applyMatrix4(transform);
    return Offset(vector.x, vector.y);
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.transform != transform;
  }
}
