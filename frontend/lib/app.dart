import 'package:flutter/material.dart';

import 'services/api_client.dart';
import 'state/graph_editor_controller.dart';
import 'widgets/graph_canvas_page.dart';

class ChainCanvasApp extends StatefulWidget {
  const ChainCanvasApp({super.key});

  @override
  State<ChainCanvasApp> createState() => _ChainCanvasAppState();
}

class _ChainCanvasAppState extends State<ChainCanvasApp> {
  late final ApiClient apiClient;
  late final GraphEditorController controller;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient();
    controller = GraphEditorController(
      apiClient: apiClient,
      graphId: 'demo',
    )..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chain Canvas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: GraphCanvasPage(controller: controller),
    );
  }
}
