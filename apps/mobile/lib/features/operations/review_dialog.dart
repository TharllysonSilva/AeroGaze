import 'package:flutter/material.dart';

/// The route owns its controller until the closing animation is disposed.
class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});
  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final notes = TextEditingController();
  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nova tarefa de revisão humana'),
    content: TextField(
      key: const ValueKey('new-review-notes'),
      controller: notes,
      maxLines: 3,
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(hintText: 'Descreva a ocorrência'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton(
        onPressed: notes.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, notes.text.trim()),
        child: const Text('Registrar'),
      ),
    ],
  );
}
