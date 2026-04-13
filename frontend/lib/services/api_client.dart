import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/graph_models.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:4000',
            );

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<GraphDocument> fetchGraph(String graphId) async {
    final response = await _client.get(_uri('/api/graphs/$graphId'));
    _ensureOk(response);
    return GraphDocument.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GraphDocument> saveGraph(GraphDocument graph) async {
    final response = await _client.put(
      _uri('/api/graphs/${graph.id}'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(graph.toJson()),
    );
    _ensureOk(response);
    return GraphDocument.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GraphDocument> runGraph(GraphDocument graph) async {
    final response = await _client.post(
      _uri('/api/graphs/${graph.id}/run'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(graph.toJson()),
    );
    _ensureOk(response);
    return GraphDocument.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }
}
