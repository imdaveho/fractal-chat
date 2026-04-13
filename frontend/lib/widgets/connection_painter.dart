import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

import '../models/graph_models.dart';

class ConnectionPainter extends CustomPainter {
  ConnectionPainter({
    required this.transform,
    required this.graph,
    required this.pendingSourceNodeId,
  });

  final Matrix4 transform;
  final GraphDocument graph;
  final String? pendingSourceNodeId;

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final edge in graph.edges) {
      final source = graph.nodes.where((node) => node.id == edge.sourceNodeId).firstOrNull;
      final target = graph.nodes.where((node) => node.id == edge.targetNodeId).firstOrNull;
      if (source == null || target == null) continue;

      final start = _worldToScreen(NodeGeometry.outputPortWorldPosition(source));
      final end = _worldToScreen(NodeGeometry.inputPortWorldPosition(target));

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + 80,
          start.dy,
          end.dx - 80,
          end.dy,
          end.dx,
          end.dy,
        );

      canvas.drawPath(path, edgePaint);
    }

    if (pendingSourceNodeId != null) {
      final source = graph.nodes.where((node) => node.id == pendingSourceNodeId).firstOrNull;
      if (source != null) {
        final center = _worldToScreen(NodeGeometry.outputPortWorldPosition(source));
        canvas.drawCircle(center, 8, Paint()..color = Colors.orange);
      }
    }
  }

  Offset _worldToScreen(Offset worldPoint) {
    final vector = Vector3(worldPoint.dx, worldPoint.dy, 0);
    vector.applyMatrix4(transform);
    return Offset(vector.x, vector.y);
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return oldDelegate.transform != transform ||
        oldDelegate.graph != graph ||
        oldDelegate.pendingSourceNodeId != pendingSourceNodeId;
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
