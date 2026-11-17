import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/wallet_entity.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.wallet});

  final WalletEntity wallet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            const Text('Available balance'),
            Text(
              Formatters.currency(
                wallet.availableBalance,
                currencyCode: wallet.currency,
              ),
              key: const Key('dashboard_balance'),
              style: context.textTheme.headlineMedium,
            ),
            Text('Currency: ${wallet.currency}'),
            Text('Account: ${wallet.maskedAccountNumber}'),
          ],
        ),
      ),
    );
  }
}
