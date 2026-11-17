import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_bloc.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_event.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/detail/transaction_detail_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository repository;

  setUp(() => repository = MockTransactionRepository());

  blocTest<TransactionDetailBloc, TransactionDetailState>(
    'loads the transaction',
    setUp: () =>
        when(() => repository.getTransaction('TXN10001'))
            .thenAnswer((_) async => Right(tDebit)),
    build: () => TransactionDetailBloc(repository),
    act: (bloc) => bloc.add(const TransactionDetailRequested('TXN10001')),
    expect: () => [
      const TransactionDetailState(status: TransactionDetailStatus.loading),
      TransactionDetailState(
        status: TransactionDetailStatus.loaded,
        transaction: tDebit,
      ),
    ],
  );

  blocTest<TransactionDetailBloc, TransactionDetailState>(
    'emits failure when the transaction is not found',
    setUp: () => when(() => repository.getTransaction('TXN99999')).thenAnswer(
      (_) async => const Left(
        ApiFailure('Transaction TXN99999 was not found.', statusCode: 404),
      ),
    ),
    build: () => TransactionDetailBloc(repository),
    act: (bloc) => bloc.add(const TransactionDetailRequested('TXN99999')),
    expect: () => const [
      TransactionDetailState(status: TransactionDetailStatus.loading),
      TransactionDetailState(
        status: TransactionDetailStatus.failure,
        failure: ApiFailure(
          'Transaction TXN99999 was not found.',
          statusCode: 404,
        ),
      ),
    ],
  );
}
