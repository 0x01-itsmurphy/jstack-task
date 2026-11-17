import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwallet_lite/core/di/injection.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/core/router/app_router.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:jwallet_lite/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:jwallet_lite/features/transfer/presentation/bloc/transfer_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthBloc authBloc;
  late MockDashboardBloc dashboardBloc;
  late MockTransferRepository transferRepository;

  final nameField = find.byKey(const Key('transfer_name_field'));
  final mobileField = find.byKey(const Key('transfer_mobile_field'));
  final amountField = find.byKey(const Key('transfer_amount_field'));
  final remarksField = find.byKey(const Key('transfer_remarks_field'));
  final continueButton = find.byKey(const Key('transfer_continue_button'));
  final confirmButton = find.byKey(const Key('transfer_confirm_button'));

  setUp(() {
    authBloc = MockAuthBloc();
    dashboardBloc = MockDashboardBloc();
    transferRepository = MockTransferRepository();

    when(() => authBloc.state).thenReturn(const AuthState.authenticated(tUser));
    when(() => dashboardBloc.state).thenReturn(
      DashboardState(
        status: DashboardStatus.loaded,
        user: tUser,
        wallet: tWallet,
        recentTransactions: tTransactionPage.items,
      ),
    );

    getIt
      ..registerFactory<DashboardBloc>(() => dashboardBloc)
      ..registerFactory<TransferBloc>(
        () => TransferBloc(transferRepository, generateKey: () => 'test-key'),
      );
  });

  tearDown(getIt.reset);

  Future<void> openSendMoney(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: MaterialApp.router(routerConfig: AppRouter(authBloc).router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick_action_send')));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fillForm(WidgetTester tester, {String amount = '1500'}) async {
    await tester.enterText(nameField, 'Rahul Sharma');
    await tester.enterText(mobileField, '9876543210');
    await tester.enterText(amountField, amount);
    await tester.enterText(remarksField, 'Payment for services');
  }

  testWidgets('shows validation errors for empty mandatory fields', (
    tester,
  ) async {
    await openSendMoney(tester);
    await tapVisible(tester, continueButton);

    expect(find.text('Beneficiary name is required'), findsOneWidget);
    expect(find.text('Mobile number is required'), findsOneWidget);
    expect(find.text('Amount is required'), findsOneWidget);
    expect(find.text('Confirm Transfer'), findsNothing);
  });

  testWidgets('rejects an invalid mobile number and a zero amount', (
    tester,
  ) async {
    await openSendMoney(tester);
    await tester.enterText(nameField, 'Rahul Sharma');
    await tester.enterText(mobileField, '12345');
    await tester.enterText(amountField, '0');
    await tapVisible(tester, continueButton);

    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    expect(find.text('Amount must be greater than zero'), findsOneWidget);
    expect(find.text('Confirm Transfer'), findsNothing);
  });

  testWidgets(
    'completes a transfer and refreshes the dashboard on the way back',
    (tester) async {
      when(
        () => transferRepository.transfer(
          request: any(named: 'request'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenAnswer((_) async => Right(tTransferResult));

      await openSendMoney(tester);
      await fillForm(tester);
      await tapVisible(tester, continueButton);

      expect(find.text('Confirm Transfer'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('₹1,500.00'), findsOneWidget);

      await tapVisible(tester, confirmButton);

      verify(
        () => transferRepository.transfer(
          request: tTransferRequest,
          idempotencyKey: 'test-key',
        ),
      ).called(1);
      expect(find.text('Transfer successful'), findsOneWidget);
      expect(find.text('TXN10013'), findsOneWidget);
      expect(find.text('₹23,950.75'), findsOneWidget);

      await tapVisible(tester, find.byKey(const Key('transfer_back_button')));

      expect(find.byKey(const Key('dashboard_balance')), findsOneWidget);
      verify(() => dashboardBloc.add(const DashboardRefreshed())).called(1);
    },
  );

  testWidgets('shows insufficient balance and lets the user edit the details', (
    tester,
  ) async {
    when(
      () => transferRepository.transfer(
        request: any(named: 'request'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer(
      (_) async => const Left(
        ApiFailure(
          'Insufficient wallet balance for this transfer.',
          statusCode: 409,
          code: 'INSUFFICIENT_BALANCE',
        ),
      ),
    );

    await openSendMoney(tester);
    await fillForm(tester, amount: '999999');
    await tapVisible(tester, continueButton);
    await tapVisible(tester, confirmButton);

    expect(find.text('Transfer failed'), findsOneWidget);
    expect(
      find.text('Insufficient wallet balance for this transfer.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsNothing);

    await tapVisible(tester, find.text('Edit details'));

    expect(find.text('Send Money'), findsOneWidget);
    expect(find.text('999999'), findsOneWidget);
  });

  testWidgets('offers retry after a network failure', (tester) async {
    when(
      () => transferRepository.transfer(
        request: any(named: 'request'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer(
      (_) async => const Left(
        NetworkFailure('The request timed out. Please try again.'),
      ),
    );

    await openSendMoney(tester);
    await fillForm(tester);
    await tapVisible(tester, continueButton);
    await tapVisible(tester, confirmButton);

    expect(
      find.text('The request timed out. Please try again.'),
      findsOneWidget,
    );

    when(
      () => transferRepository.transfer(
        request: any(named: 'request'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async => Right(tTransferResult));

    await tapVisible(tester, find.text('Retry'));

    expect(find.text('Transfer successful'), findsOneWidget);
    verify(
      () => transferRepository.transfer(
        request: tTransferRequest,
        idempotencyKey: 'test-key',
      ),
    ).called(2);
  });
}
