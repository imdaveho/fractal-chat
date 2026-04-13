import 'dart:ui';

enum NodeType {
  chatInput('chat_input'),
  llm('llm'),
  textOutput('text_output');

  const NodeType(this.value);
  final String value;

  static NodeType fromValue(String value) {
    return NodeType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NodeType.chatInput,
    );
  }
}

class GraphDocument {
  GraphDocument({
    required this.id,
    required this.nodes,
    required this.edges,
  });

  final String id;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  factory GraphDocument.fromJson(Map<String, dynamic> json) {
    return GraphDocument(
      id: json['id'] as String? ?? 'demo',
      nodes: ((json['nodes'] as List?) ?? const [])
          .map((node) => GraphNode.fromJson(node as Map<String, dynamic>))
          .toList(),
      edges: ((json['edges'] as List?) ?? const [])
          .map((edge) => GraphEdge.fromJson(edge as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nodes': nodes.map((node) => node.toJson()).toList(),
      'edges': edges.map((edge) => edge.toJson()).toList(),
    };
  }

  GraphDocument copyWith({
    String? id,
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
  }) {
    return GraphDocument(
      id: id ?? this.id,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
    );
  }
}

class GraphNode {
  GraphNode({
    required this.id,
    required this.type,
    required this.position,
    required this.data,
  });

  final String id;
  final NodeType type;
  final Offset position;
  final Map<String, dynamic> data;

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    final position = (json['position'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    return GraphNode(
      id: json['id'] as String,
      type: NodeType.fromValue(json['type'] as String? ?? 'chat_input'),
      position: Offset(
        ((position['x'] as num?) ?? 0).toDouble(),
        ((position['y'] as num?) ?? 0).toDouble(),
      ),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'position': {
        'x': position.dx,
        'y': position.dy,
      },
      'data': data,
    };
  }

  GraphNode copyWith({
    String? id,
    NodeType? type,
    Offset? position,
    Map<String, dynamic>? data,
  }) {
    return GraphNode(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      data: data ?? this.data,
    );
  }
}

class GraphEdge {
  GraphEdge({
    required this.id,
    required this.sourceNodeId,
    required this.sourcePort,
    required this.targetNodeId,
    required this.targetPort,
  });

  final String id;
  final String sourceNodeId;
  final String sourcePort;
  final String targetNodeId;
  final String targetPort;

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    final source = (json['source'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final target = (json['target'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    return GraphEdge(
      id: json['id'] as String,
      sourceNodeId: source['node_id'] as String,
      sourcePort: source['port'] as String? ?? 'out',
      targetNodeId: target['node_id'] as String,
      targetPort: target['port'] as String? ?? 'in',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': {
        'node_id': sourceNodeId,
        'port': sourcePort,
      },
      'target': {
        'node_id': targetNodeId,
        'port': targetPort,
      },
    };
  }
}

class NodeGeometry {
  static const double width = 320;

  static double heightFor(NodeType type) {
    switch (type) {
      case NodeType.chatInput:
        return 220;
      case NodeType.llm:
        return 260;
      case NodeType.textOutput:
        return 240;
    }
  }

  static Offset inputPortWorldPosition(GraphNode node) {
    return Offset(
      node.position.dx,
      node.position.dy + 48,
    );
  }

  static Offset outputPortWorldPosition(GraphNode node) {
    return Offset(
      node.position.dx + width,
      node.position.dy + 48,
    );
  }
}
