import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jwallet_lite/core/di/injection.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_entity.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_bloc.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_event.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_state.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_bloc.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_event.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_state.dart';
import 'package:jwallet_lite/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:jwallet_lite/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionsBloc transactionsBloc;
  late MockTransactionDetailBloc detailBloc;

  setUp(() {
    transactionsBloc = MockTransactionsBloc();
    detailBloc = MockTransactionDetailBloc();
    getIt
      ..registerFactory<TransactionsBloc>(() => transactionsBloc)
      ..registerFactory<TransactionDetailBloc>(() => detailBloc);
  });

  tearDown(getIt.reset);

  group('TransactionsScreen', () {
    Future<void> pumpHistory(WidgetTester tester, TransactionsState state) {
      when(() => transactionsBloc.state).thenReturn(state);
      return tester.pumpWidget(const MaterialApp(home: TransactionsScreen()));
    }

    testWidgets('requests transactions when opened', (tester) async {
      await pumpHistory(tester, const TransactionsState());

      verify(() => transactionsBloc.add(const TransactionsRequested()))
          .called(1);
    });

    testWidgets('lists reference, name, type, amount and status', (
      tester,
    ) async {
      await pumpHistory(
        tester,
        TransactionsState(
          status: TransactionsStatus.loaded,
          items: tTransactionPage.items,
        ),
      );

      expect(find.textContaining('TXN10001'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.textContaining('Debit ·'), findsOneWidget);
      expect(find.text('-₹1,500.00'), findsOneWidget);
      expect(find.text('SUCCESS'), findsOneWidget);
      expect(find.textContaining('TXN10002'), findsOneWidget);
      expect(find.text('+₹5,000.00'), findsOneWidget);
    });

    testWidgets('shows an empty state', (tester) async {
      await pumpHistory(
        tester,
        const TransactionsState(status: TransactionsStatus.empty),
      );

      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('shows a no-match message when filters are applied', (
      tester,
    ) async {
      await pumpHistory(
        tester,
        const TransactionsState(
          status: TransactionsStatus.empty,
          search: 'zzz',
        ),
      );

      expect(find.text('No matching transactions'), findsOneWidget);
    });

    testWidgets('shows an error with retry', (tester) async {
      await pumpHistory(
        tester,
        const TransactionsState(
          status: TransactionsStatus.failure,
          failure: NetworkFailure('No internet connection.'),
        ),
      );

      expect(find.text('No internet connection.'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      verify(() => transactionsBloc.add(const TransactionsRequested()))
          .called(2);
    });

    testWidgets('filters by credit', (tester) async {
      await pumpHistory(
        tester,
        TransactionsState(
          status: TransactionsStatus.loaded,
          items: tTransactionPage.items,
        ),
      );

      await tester.tap(find.byKey(const Key('filter_Credit')));

      verify(
        () => transactionsBloc.add(
          const TransactionsTypeChanged(TransactionType.credit),
        ),
      ).called(1);
    });

    testWidgets('searches after the user stops typing', (tester) async {
      await pumpHistory(
        tester,
        TransactionsState(
          status: TransactionsStatus.loaded,
          items: tTransactionPage.items,
        ),
      );

      await tester.enterText(
        find.byKey(const Key('transactions_search_field')),
        'rahul',
      );
      verifyNever(
        () => transactionsBloc.add(any(that: isA<TransactionsSearchChanged>())),
      );

      await tester.pump(const Duration(milliseconds: 400));
      verify(
        () => transactionsBloc.add(const TransactionsSearchChanged('rahul')),
      ).called(1);
    });
  });

  group('TransactionDetailScreen', () {
    Future<void> pumpDetail(WidgetTester tester, TransactionDetailState state) {
      when(() => detailBloc.state).thenReturn(state);
      return tester.pumpWidget(
        const MaterialApp(
          home: TransactionDetailScreen(transactionId: 'TXN10001'),
        ),
      );
    }

    testWidgets('requests the transaction when opened', (tester) async {
      await pumpDetail(tester, const TransactionDetailState());

      verify(() => detailBloc.add(const TransactionDetailRequested('TXN10001')))
          .called(1);
    });

    testWidgets('shows all transaction details', (tester) async {
      await pumpDetail(
        tester,
        TransactionDetailState(
          status: TransactionDetailStatus.loaded,
          transaction: TransactionEntity(
            id: 'TXN10001',
            type: TransactionType.debit,
            amount: 1500,
            currency: 'INR',
            beneficiaryName: 'Rahul Sharma',
            status: TransactionStatus.success,
            createdAt: DateTime(2026, 10, 20, 16),
            mobileNumber: '9876543210',
            remarks: 'Payment for services',
          ),
        ),
      );

      for (final text in [
        'TXN10001',
        'Debit',
        '₹1,500.00',
        'Beneficiary',
        'Rahul Sharma',
        '9876543210',
        '20 Oct 2026, 04:00 PM',
        'Success',
        'Payment for services',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('labels the counterparty as sender for credits', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        TransactionDetailState(
          status: TransactionDetailStatus.loaded,
          transaction: tCredit,
        ),
      );

      expect(find.text('Sender'), findsOneWidget);
      expect(find.text('Remarks'), findsNothing);
    });

    testWidgets('shows not found with retry', (tester) async {
      await pumpDetail(
        tester,
        const TransactionDetailState(
          status: TransactionDetailStatus.failure,
          failure: ApiFailure('Transaction TXN10001 was not found.'),
        ),
      );

      expect(find.text('Transaction TXN10001 was not found.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
