import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/details_card.dart';
import '../../../../core/widgets/error_view.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';

class TransferConfirmationScreen extends StatelessWidget {
  const TransferConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransferBloc, TransferState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == TransferStatus.success ||
              current.status == TransferStatus.failure),
      listener: (context, state) =>
          context.pushReplacement(AppRoutes.transferResult),
      builder: (context, state) {
        final request = state.request;

        return PopScope(
          canPop: !state.isSubmitting,
          child: Scaffold(
            appBar: AppBar(title: const Text('Confirm Transfer')),
            body: request == null
                ? const ErrorView(message: 'There is no transfer to confirm.')
                : SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          'Please review the transfer details',
                          style: context.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        DetailsCard(
                          items: [
                            ('Beneficiary', request.beneficiaryName),
                            ('Mobile number', request.mobileNumber),
                            ('Amount', Formatters.currency(request.amount)),
                            ('Remarks', request.remarks ?? '-'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          key: const Key('transfer_confirm_button'),
                          label: 'Confirm & Send',
                          isLoading: state.isSubmitting,
                          onPressed: () => context.read<TransferBloc>().add(
                            const TransferSubmitted(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () => context.pop(),
                          child: const Text('Edit'),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
