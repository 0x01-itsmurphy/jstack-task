import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionStatusChip extends StatelessWidget {
  const TransactionStatusChip({super.key, required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TransactionStatus.success => ('SUCCESS', AppColors.success),
      TransactionStatus.pending => ('PENDING', AppColors.warning),
      TransactionStatus.failed => ('FAILED', AppColors.error),
    };

    return Text(label, style: TextStyle(color: color, fontSize: 12));
  }
}
