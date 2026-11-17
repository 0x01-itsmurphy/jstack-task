import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_status_chip.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});

  final TransactionEntity transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final amount = Formatters.currency(
      transaction.amount,
      currencyCode: transaction.currency,
    );

    return ListTile(
      onTap: onTap,
      leading: Icon(
        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
        color: isCredit ? AppColors.credit : AppColors.debit,
      ),
      title: Text(transaction.beneficiaryName),
      isThreeLine: true,
      subtitle: Text(
        '${transaction.id}\n'
        '${isCredit ? 'Credit' : 'Debit'} · ${Formatters.dateTime(transaction.createdAt)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${isCredit ? '+' : '-'}$amount'),
          TransactionStatusChip(status: transaction.status),
        ],
      ),
    );
  }
}
