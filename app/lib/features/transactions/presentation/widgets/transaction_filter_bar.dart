import 'package:flutter/material.dart';

import '../../domain/entities/transaction_entity.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TransactionType? selected;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <(String, TransactionType?)>[
      ('All', null),
      ('Credit', TransactionType.credit),
      ('Debit', TransactionType.debit),
    ];

    return Wrap(
      spacing: 8,
      children: [
        for (final (label, type) in options)
          ChoiceChip(
            key: Key('filter_$label'),
            label: Text(label),
            selected: selected == type,
            onSelected: (_) => onChanged(type),
          ),
      ],
    );
  }
}
