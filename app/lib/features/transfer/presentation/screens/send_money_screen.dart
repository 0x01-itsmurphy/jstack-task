import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/transfer_request_entity.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _continue() {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    final remarks = _remarksController.text.trim();
    final request = TransferRequestEntity(
      beneficiaryName: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      remarks: remarks.isEmpty ? null : remarks,
    );

    context.read<TransferBloc>().add(TransferReviewRequested(request));
    context.push(AppRoutes.transferConfirm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppTextField(
                key: const Key('transfer_name_field'),
                label: 'Beneficiary name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                maxLength: 100,
                validator: Validators.beneficiaryName,
              ),
              const SizedBox(height: 16),
              AppTextField(
                key: const Key('transfer_mobile_field'),
                label: 'Mobile number',
                controller: _mobileController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.mobileNumber,
              ),
              const SizedBox(height: 16),
              AppTextField(
                key: const Key('transfer_amount_field'),
                label: 'Amount (₹)',
                controller: _amountController,
                prefixIcon: Icons.currency_rupee,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: Validators.amount,
              ),
              const SizedBox(height: 16),
              AppTextField(
                key: const Key('transfer_remarks_field'),
                label: 'Remarks (optional)',
                controller: _remarksController,
                prefixIcon: Icons.notes,
                textInputAction: TextInputAction.done,
                maxLength: 200,
                validator: Validators.remarks,
                onFieldSubmitted: (_) => _continue(),
              ),
              const SizedBox(height: 24),
              AppButton(
                key: const Key('transfer_continue_button'),
                label: 'Continue',
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
