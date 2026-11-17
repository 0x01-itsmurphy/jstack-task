import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/details_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/detail/transaction_detail_bloc.dart';
import '../bloc/detail/transaction_detail_event.dart';
import '../bloc/detail/transaction_detail_state.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<TransactionDetailBloc>()
            ..add(TransactionDetailRequested(transactionId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Transaction Details')),
        body: SafeArea(
          child: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
            builder: (context, state) => switch (state.status) {
              TransactionDetailStatus.loaded => _TransactionDetails(
                transaction: state.transaction!,
              ),
              TransactionDetailStatus.failure => ErrorView(
                message:
                    state.failure?.message ?? 'Unable to load the transaction.',
                onRetry: () => context.read<TransactionDetailBloc>().add(
                  TransactionDetailRequested(transactionId),
                ),
              ),
              _ => const LoadingView(),
            },
          ),
        ),
      ),
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final status = switch (transaction.status) {
      TransactionStatus.success => 'Success',
      TransactionStatus.pending => 'Pending',
      TransactionStatus.failed => 'Failed',
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DetailsCard(
          items: [
            ('Transaction ID', transaction.id),
            ('Type', isCredit ? 'Credit' : 'Debit'),
            (
              'Amount',
              Formatters.currency(
                transaction.amount,
                currencyCode: transaction.currency,
              ),
            ),
            (isCredit ? 'Sender' : 'Beneficiary', transaction.beneficiaryName),
            if (transaction.mobileNumber != null)
              ('Mobile number', transaction.mobileNumber!),
            ('Date & time', Formatters.dateTime(transaction.createdAt)),
            ('Status', status),
            if (transaction.remarks?.isNotEmpty ?? false)
              ('Remarks', transaction.remarks!),
          ],
        ),
      ],
    );
  }
}
