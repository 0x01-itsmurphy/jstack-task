import 'dart:async';

import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/login/login_event.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_query.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_event.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_event.dart';
import 'package:jwallet_lite/features/transfer/domain/entities/transfer_request_entity.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_event.dart';
import 'package:mocktail/mocktail.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  registerFallbackValue(const LoginSubmitted(email: '', password: ''));
  registerFallbackValue(const AuthSessionRequested());
  registerFallbackValue(const DashboardRequested());
  registerFallbackValue(const TransactionQuery());
  registerFallbackValue(const TransferSubmitted());
  registerFallbackValue(const TransactionsRequested());
  registerFallbackValue(const TransactionDetailRequested(''));
  registerFallbackValue(
    const TransferRequestEntity(
      beneficiaryName: '',
      mobileNumber: '',
      amount: 0,
    ),
  );
  await testMain();
}
