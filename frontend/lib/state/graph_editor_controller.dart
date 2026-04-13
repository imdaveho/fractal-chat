import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/graph_models.dart';
import '../services/api_client.dart';

class GraphEditorController extends ChangeNotifier {
  GraphEditorController({
    required this.apiClient,
    required this.graphId,
  });

  final ApiClient apiClient;
  final String graphId;
  final Random _random = Random();

  GraphDocument? _graph;
  bool _loading = true;
  bool _running = false;
  String? _error;
  String? _pendingSourceNodeId;
  String? _pendingSourcePort;

  GraphDocument? get graph => _graph;
  bool get loading => _loading;
  bool get running => _running;
  String? get error => _error;
  bool get hasPendingConnection => _pendingSourceNodeId != null;
  String? get pendingSourceNodeId => _pendingSourceNodeId;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _graph = await apiClient.fetchGraph(graphId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> save() async {
    final current = _graph;
    if (current == null) return;

    _error = null;
    notifyListeners();

    try {
      _graph = await apiClient.saveGraph(current);
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> runGraph() async {
    final current = _graph;
    if (current == null) return;

    _running = true;
    _error = null;
    notifyListeners();

    try {
      _graph = await apiClient.runGraph(current);
    } catch (e) {
      _error = e.toString();
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  void addNode(NodeType type) {
    final current = _graph;
    if (current == null) return;

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final nodeId = '${type.value}-$suffix';
    final position = Offset(
      120 + _random.nextInt(800).toDouble(),
      120 + _random.nextInt(500).toDouble(),
    );

    final node = GraphNode(
      id: nodeId,
      type: type,
      position: position,
      data: _defaultDataFor(type),
    );

    _graph = current.copyWith(nodes: [...current.nodes, node]);
    notifyListeners();
  }

  void removeNode(String nodeId) {
    final current = _graph;
    if (current == null) return;

    _graph = current.copyWith(
      nodes: current.nodes.where((node) => node.id != nodeId).toList(),
      edges: current.edges
          .where((edge) => edge.sourceNodeId != nodeId && edge.targetNodeId != nodeId)
          .toList(),
    );
    notifyListeners();
  }

  void updateNodePosition(String nodeId, Offset position) {
    final current = _graph;
    if (current == null) return;

    _graph = current.copyWith(
      nodes: current.nodes
          .map((node) => node.id == nodeId ? node.copyWith(position: position) : node)
          .toList(),
    );
    notifyListeners();
  }

  void updateNodeData(String nodeId, String key, dynamic value) {
    final current = _graph;
    if (current == null) return;

    _graph = current.copyWith(
      nodes: current.nodes.map((node) {
        if (node.id != nodeId) return node;
        final updatedData = Map<String, dynamic>.from(node.data)..[key] = value;
        return node.copyWith(data: updatedData);
      }).toList(),
    );
    notifyListeners();
  }

  void beginConnection(String nodeId, String port) {
    _pendingSourceNodeId = nodeId;
    _pendingSourcePort = port;
    notifyListeners();
  }

  void completeConnection(String targetNodeId, String targetPort) {
    final current = _graph;
    if (current == null) return;
    if (_pendingSourceNodeId == null || _pendingSourcePort == null) return;
    if (_pendingSourceNodeId == targetNodeId) {
      _pendingSourceNodeId = null;
      _pendingSourcePort = null;
      notifyListeners();
      return;
    }

    final edge = GraphEdge(
      id: 'edge-${DateTime.now().microsecondsSinceEpoch}',
      sourceNodeId: _pendingSourceNodeId!,
      sourcePort: _pendingSourcePort!,
      targetNodeId: targetNodeId,
      targetPort: targetPort,
    );

    final alreadyExists = current.edges.any((existing) =>
        existing.sourceNodeId == edge.sourceNodeId &&
        existing.targetNodeId == edge.targetNodeId &&
        existing.sourcePort == edge.sourcePort &&
        existing.targetPort == edge.targetPort);

    if (!alreadyExists) {
      _graph = current.copyWith(edges: [...current.edges, edge]);
    }

    _pendingSourceNodeId = null;
    _pendingSourcePort = null;
    notifyListeners();
  }

  void cancelPendingConnection() {
    _pendingSourceNodeId = null;
    _pendingSourcePort = null;
    notifyListeners();
  }

  void removeEdge(String edgeId) {
    final current = _graph;
    if (current == null) return;

    _graph = current.copyWith(
      edges: current.edges.where((edge) => edge.id != edgeId).toList(),
    );
    notifyListeners();
  }

  GraphNode? nodeById(String nodeId) {
    final current = _graph;
    if (current == null) return null;

    for (final node in current.nodes) {
      if (node.id == nodeId) return node;
    }
    return null;
  }

  Map<String, dynamic> _defaultDataFor(NodeType type) {
    switch (type) {
      case NodeType.chatInput:
        return {
          'label': 'Chat input',
          'message': '',
          'last_output': '',
        };
      case NodeType.llm:
        return {
          'label': 'LLM',
          'provider': 'mock',
          'model': 'gpt-4.1-mini',
          'system_prompt': 'You are precise and concise.',
          'temperature': 0.2,
          'last_output': '',
        };
      case NodeType.textOutput:
        return {
          'label': 'Text output',
          'text': '',
          'last_output': '',
        };
    }
  }
}
