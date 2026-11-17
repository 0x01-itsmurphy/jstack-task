import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/details_card.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/transfer_result_entity.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';

class TransferResultScreen extends StatelessWidget {
  const TransferResultScreen({super.key});

  static Future<void> backToDashboard(BuildContext context) async {
    final router = GoRouter.of(context);
    while (router.canPop()) {
      router.pop();
      await WidgetsBinding.instance.endOfFrame;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferBloc, TransferState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !state.isSubmitting) backToDashboard(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Transfer Status'),
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: switch (state.status) {
                TransferStatus.success when state.result != null =>
                  _TransferSuccess(result: state.result!),
                TransferStatus.failure => _TransferFailure(state: state),
                _ => const LoadingView(),
              },
            ),
          ),
        );
      },
    );
  }
}

class _TransferSuccess extends StatelessWidget {
  const _TransferSuccess({required this.result});

  final TransferResultEntity result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 72),
        const SizedBox(height: 12),
        Text(
          'Transfer successful',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        DetailsCard(
          items: [
            ('Reference number', result.transactionId),
            (
              'Amount transferred',
              Formatters.currency(result.amount, currencyCode: result.currency),
            ),
            ('Beneficiary', result.beneficiaryName),
            ('Date & time', Formatters.dateTime(result.createdAt)),
            (
              'Available balance',
              Formatters.currency(
                result.availableBalance,
                currencyCode: result.currency,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(
          key: const Key('transfer_back_button'),
          label: 'Back to Dashboard',
          onPressed: () => TransferResultScreen.backToDashboard(context),
        ),
      ],
    );
  }
}

class _TransferFailure extends StatelessWidget {
  const _TransferFailure({required this.state});

  final TransferState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.cancel, color: AppColors.error, size: 72),
        const SizedBox(height: 12),
        Text(
          'Transfer failed',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          state.failure?.message ?? 'Something went wrong.',
          key: const Key('transfer_failure_message'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (state.canRetry) ...[
          AppButton(
            label: 'Retry',
            onPressed: () =>
                context.read<TransferBloc>().add(const TransferSubmitted()),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Edit details'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => TransferResultScreen.backToDashboard(context),
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }
}
