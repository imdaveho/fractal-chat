import 'package:flutter/material.dart';

import '../models/graph_models.dart';

class NodeCard extends StatelessWidget {
  const NodeCard({
    super.key,
    required this.node,
    required this.onChanged,
    required this.onRunRequested,
    required this.onDeleteRequested,
    required this.onBeginOutputConnection,
    required this.onCompleteInputConnection,
    required this.pendingConnection,
  });

  final GraphNode node;
  final void Function(String key, dynamic value) onChanged;
  final VoidCallback onRunRequested;
  final VoidCallback onDeleteRequested;
  final VoidCallback onBeginOutputConnection;
  final VoidCallback onCompleteInputConnection;
  final bool pendingConnection;

  @override
  Widget build(BuildContext context) {
    final title = switch (node.type) {
      NodeType.chatInput => 'Chat input',
      NodeType.llm => 'LLM',
      NodeType.textOutput => 'Text output',
    };

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: NodeGeometry.width,
        constraints: BoxConstraints(
          minHeight: NodeGeometry.heightFor(node.type),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: pendingConnection ? Colors.orange : const Color(0xFFD1D5DB),
            width: pendingConnection ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NodeHeader(
              title: title,
              showInput: node.type != NodeType.chatInput,
              showOutput: true,
              onInputTap: onCompleteInputConnection,
              onOutputTap: onBeginOutputConnection,
              onDeleteTap: onDeleteRequested,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: switch (node.type) {
                NodeType.chatInput => _ChatInputBody(
                    data: node.data,
                    onChanged: onChanged,
                    onRunRequested: onRunRequested,
                  ),
                NodeType.llm => _LlmBody(
                    data: node.data,
                    onChanged: onChanged,
                  ),
                NodeType.textOutput => _TextOutputBody(
                    data: node.data,
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeHeader extends StatelessWidget {
  const _NodeHeader({
    required this.title,
    required this.showInput,
    required this.showOutput,
    required this.onInputTap,
    required this.onOutputTap,
    required this.onDeleteTap,
  });

  final String title;
  final bool showInput;
  final bool showOutput;
  final VoidCallback onInputTap;
  final VoidCallback onOutputTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          if (showInput)
            _PortButton(
              icon: Icons.input,
              tooltip: 'Connect to input',
              onTap: onInputTap,
            )
          else
            const SizedBox(width: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            onPressed: onDeleteTap,
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
          ),
          if (showOutput)
            _PortButton(
              icon: Icons.output,
              tooltip: 'Start output connection',
              onTap: onOutputTap,
            ),
        ],
      ),
    );
  }
}

class _PortButton extends StatelessWidget {
  const _PortButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFE0E7FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Color(0xFF3730A3)),
        ),
      ),
    );
  }
}

class _ChatInputBody extends StatelessWidget {
  const _ChatInputBody({
    required this.data,
    required this.onChanged,
    required this.onRunRequested,
  });

  final Map<String, dynamic> data;
  final void Function(String key, dynamic value) onChanged;
  final VoidCallback onRunRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: data['label']?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Label',
            isDense: true,
          ),
          onChanged: (value) => onChanged('label', value),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: data['message']?.toString() ?? '',
          minLines: 5,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Message',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => onChanged('message', value),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onRunRequested,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}

class _LlmBody extends StatelessWidget {
  const _LlmBody({
    required this.data,
    required this.onChanged,
  });

  final Map<String, dynamic> data;
  final void Function(String key, dynamic value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: data['provider']?.toString() ?? 'mock',
          decoration: const InputDecoration(
            labelText: 'Provider',
            hintText: 'mock | openai_compatible',
            isDense: true,
          ),
          onChanged: (value) => onChanged('provider', value),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: data['model']?.toString() ?? 'gpt-4.1-mini',
          decoration: const InputDecoration(
            labelText: 'Model',
            isDense: true,
          ),
          onChanged: (value) => onChanged('model', value),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: data['temperature']?.toString() ?? '0.2',
          decoration: const InputDecoration(
            labelText: 'Temperature',
            isDense: true,
          ),
          onChanged: (value) => onChanged('temperature', value),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: data['system_prompt']?.toString() ?? '',
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'System prompt',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => onChanged('system_prompt', value),
        ),
      ],
    );
  }
}

class _TextOutputBody extends StatelessWidget {
  const _TextOutputBody({
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final text = data['text']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: data['label']?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Label',
            isDense: true,
          ),
          enabled: false,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            text.isEmpty ? 'Run the graph to populate this node.' : text,
          ),
        ),
      ],
    );
  }
}
