import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    required this.onViewAll,
    required this.onTransactionTap,
  });

  final List<TransactionEntity> transactions;
  final VoidCallback onViewAll;
  final ValueChanged<TransactionEntity> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Recent transactions', style: context.textTheme.titleMedium),
            const Spacer(),
            TextButton(onPressed: onViewAll, child: const Text('View all')),
          ],
        ),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No transactions yet'),
          )
        else
          for (final transaction in transactions)
            TransactionTile(
              transaction: transaction,
              onTap: () => onTransactionTap(transaction),
            ),
      ],
    );
  }
}
