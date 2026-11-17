import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onSendMoney,
    required this.onAddMoney,
    required this.onHistory,
  });

  final VoidCallback onSendMoney;
  final VoidCallback onAddMoney;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          key: const Key('quick_action_send'),
          onPressed: onSendMoney,
          icon: const Icon(Icons.send),
          label: const Text('Send Money'),
        ),
        OutlinedButton.icon(
          key: const Key('quick_action_add'),
          onPressed: onAddMoney,
          icon: const Icon(Icons.add),
          label: const Text('Add Money'),
        ),
        OutlinedButton.icon(
          key: const Key('quick_action_history'),
          onPressed: onHistory,
          icon: const Icon(Icons.history),
          label: const Text('History'),
        ),
      ],
    );
  }
}
