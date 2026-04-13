import 'package:canvas_kit/canvas_kit.dart';
import 'package:flutter/material.dart';

import '../models/graph_models.dart';
import '../state/graph_editor_controller.dart';
import 'connection_painter.dart';
import 'grid_painter.dart';
import 'node_card.dart';

class GraphCanvasPage extends StatefulWidget {
  const GraphCanvasPage({
    super.key,
    required this.controller,
  });

  final GraphEditorController controller;

  @override
  State<GraphCanvasPage> createState() => _GraphCanvasPageState();
}

class _GraphCanvasPageState extends State<GraphCanvasPage> {
  late final CanvasKitController canvasController;

  @override
  void initState() {
    super.initState();
    canvasController = CanvasKitController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final graph = widget.controller.graph;

        if (widget.controller.loading || graph == null) {
          return Scaffold(
            body: Center(
              child: widget.controller.error == null
                  ? const CircularProgressIndicator()
                  : Text(widget.controller.error!),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: CanvasKit(
                  controller: canvasController,
                  backgroundBuilder: (transform) => Container(
                    color: const Color(0xFFF8FAFC),
                    child: CustomPaint(
                      painter: GridPainter(transform),
                      size: Size.infinite,
                    ),
                  ),
                  foregroundLayers: [
                    (transform) => ConnectionPainter(
                          transform: transform,
                          graph: graph,
                          pendingSourceNodeId: widget.controller.pendingSourceNodeId,
                        ),
                  ],
                  children: graph.nodes
                      .map(
                        (node) => CanvasItem(
                          id: node.id,
                          worldPosition: node.position,
                          draggable: true,
                          estimatedSize: Size(
                            NodeGeometry.width,
                            NodeGeometry.heightFor(node.type),
                          ),
                          onWorldMoved: (newPosition) {
                            widget.controller.updateNodePosition(node.id, newPosition);
                          },
                          child: NodeCard(
                            node: node,
                            pendingConnection:
                                widget.controller.pendingSourceNodeId == node.id,
                            onChanged: (key, value) {
                              widget.controller.updateNodeData(node.id, key, value);
                            },
                            onRunRequested: widget.controller.runGraph,
                            onDeleteRequested: () {
                              widget.controller.removeNode(node.id);
                            },
                            onBeginOutputConnection: () {
                              widget.controller.beginConnection(node.id, 'out');
                            },
                            onCompleteInputConnection: () {
                              widget.controller.completeConnection(node.id, 'in');
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: _Toolbar(controller: widget.controller),
              ),
              if (widget.controller.hasPendingConnection)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Select a target node input to finish the connection.'),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: widget.controller.cancelPendingConnection,
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.controller.running)
                const Positioned(
                  top: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Running graph...'),
                        ],
                      ),
                    ),
                  ),
                ),
              if (widget.controller.error != null)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: SizedBox(
                    width: 420,
                    child: Card(
                      color: const Color(0xFFFEE2E2),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(widget.controller.error!),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.controller,
  });

  final GraphEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => controller.addNode(NodeType.chatInput),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Add chat input'),
            ),
            FilledButton.icon(
              onPressed: () => controller.addNode(NodeType.llm),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Add LLM'),
            ),
            FilledButton.icon(
              onPressed: () => controller.addNode(NodeType.textOutput),
              icon: const Icon(Icons.notes),
              label: const Text('Add text output'),
            ),
            OutlinedButton.icon(
              onPressed: controller.save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
            OutlinedButton.icon(
              onPressed: controller.runGraph,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run graph'),
            ),
          ],
        ),
      ),
    );
  }
}
