import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_entity.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_page_entity.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_query.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_bloc.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_event.dart';
import 'package:jwallet_lite/features/transactions/presentation/bloc/history/transactions_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockTransactionRepository repository;

  const failure = NetworkFailure('No internet connection.');
  const emptyPage = TransactionPageEntity(
    items: [],
    page: 1,
    total: 0,
    hasMore: false,
  );

  final loaded = TransactionsState(
    status: TransactionsStatus.loaded,
    items: tTransactionPage.items,
  );

  void stubPage(TransactionPageEntity page) {
    when(() => repository.getTransactions(any()))
        .thenAnswer((_) async => Right(page));
  }

  setUp(() => repository = MockTransactionRepository());

  blocTest<TransactionsBloc, TransactionsState>(
    'loads the first page',
    setUp: () => stubPage(tTransactionPage),
    build: () => TransactionsBloc(repository),
    act: (bloc) => bloc.add(const TransactionsRequested()),
    expect: () => [
      const TransactionsState(status: TransactionsStatus.loading),
      loaded,
    ],
    verify: (_) => verify(
      () => repository.getTransactions(const TransactionQuery(search: '')),
    ).called(1),
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'emits empty when there are no transactions',
    setUp: () => stubPage(emptyPage),
    build: () => TransactionsBloc(repository),
    act: (bloc) => bloc.add(const TransactionsRequested()),
    expect: () => const [
      TransactionsState(status: TransactionsStatus.loading),
      TransactionsState(status: TransactionsStatus.empty),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'emits failure when loading fails',
    setUp: () =>
        when(() => repository.getTransactions(any()))
            .thenAnswer((_) async => const Left(failure)),
    build: () => TransactionsBloc(repository),
    act: (bloc) => bloc.add(const TransactionsRequested()),
    expect: () => const [
      TransactionsState(status: TransactionsStatus.loading),
      TransactionsState(status: TransactionsStatus.failure, failure: failure),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'searches by reference or name',
    setUp: () => stubPage(
      TransactionPageEntity(items: [tDebit], page: 1, total: 1, hasMore: false),
    ),
    build: () => TransactionsBloc(repository),
    seed: () => loaded,
    act: (bloc) => bloc.add(const TransactionsSearchChanged('  rahul ')),
    expect: () => [
      loaded.copyWith(status: TransactionsStatus.loading, search: 'rahul'),
      loaded.copyWith(search: 'rahul', items: [tDebit]),
    ],
    verify: (_) => verify(
      () => repository.getTransactions(const TransactionQuery(search: 'rahul')),
    ).called(1),
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'ignores a search that has not changed',
    build: () => TransactionsBloc(repository),
    seed: () => loaded.copyWith(search: 'rahul'),
    act: (bloc) => bloc.add(const TransactionsSearchChanged('rahul ')),
    expect: () => <TransactionsState>[],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'filters by credit and keeps the search text',
    setUp: () => stubPage(
      TransactionPageEntity(
        items: [tCredit],
        page: 1,
        total: 1,
        hasMore: false,
      ),
    ),
    build: () => TransactionsBloc(repository),
    seed: () => loaded.copyWith(search: 'a'),
    act: (bloc) =>
        bloc.add(const TransactionsTypeChanged(TransactionType.credit)),
    expect: () => [
      const TransactionsState(
        status: TransactionsStatus.loading,
        type: TransactionType.credit,
        search: 'a',
      ),
      TransactionsState(
        status: TransactionsStatus.loaded,
        type: TransactionType.credit,
        search: 'a',
        items: [tCredit],
      ),
    ],
    verify: (_) => verify(
      () => repository.getTransactions(
        const TransactionQuery(type: TransactionType.credit, search: 'a'),
      ),
    ).called(1),
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'appends the next page',
    setUp: () => stubPage(
      TransactionPageEntity(
        items: [tCredit],
        page: 2,
        total: 3,
        hasMore: false,
      ),
    ),
    build: () => TransactionsBloc(repository),
    seed: () => TransactionsState(
      status: TransactionsStatus.loaded,
      items: [tDebit],
      hasMore: true,
    ),
    act: (bloc) => bloc.add(const TransactionsNextPageRequested()),
    expect: () => [
      TransactionsState(
        status: TransactionsStatus.loaded,
        items: [tDebit],
        hasMore: true,
        isLoadingMore: true,
      ),
      TransactionsState(
        status: TransactionsStatus.loaded,
        items: [tDebit, tCredit],
        page: 2,
      ),
    ],
    verify: (_) => verify(
      () => repository.getTransactions(
        const TransactionQuery(search: '', page: 2),
      ),
    ).called(1),
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'does not request another page when there are no more',
    build: () => TransactionsBloc(repository),
    seed: () => loaded,
    act: (bloc) => bloc.add(const TransactionsNextPageRequested()),
    expect: () => <TransactionsState>[],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'refresh failure keeps the list and exposes the failure',
    setUp: () =>
        when(() => repository.getTransactions(any()))
            .thenAnswer((_) async => const Left(failure)),
    build: () => TransactionsBloc(repository),
    seed: () => loaded,
    act: (bloc) => bloc.add(const TransactionsRefreshed()),
    expect: () => [
      loaded.copyWith(isRefreshing: true),
      loaded.copyWith(failure: failure),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'ignores an older search result that arrives after a newer one',
    setUp: () {
      final slow = Completer<Either<Failure, TransactionPageEntity>>();
      when(
        () => repository.getTransactions(const TransactionQuery(search: 'ra')),
      ).thenAnswer((_) => slow.future);
      when(
        () =>
            repository.getTransactions(const TransactionQuery(search: 'rahul')),
      ).thenAnswer((_) async {
        Future<void>.delayed(
          const Duration(milliseconds: 5),
          () => slow.complete(Right(tTransactionPage)),
        );
        return Right(
          TransactionPageEntity(
            items: [tDebit],
            page: 1,
            total: 1,
            hasMore: false,
          ),
        );
      });
    },
    build: () => TransactionsBloc(repository),
    seed: () => loaded,
    act: (bloc) => bloc
      ..add(const TransactionsSearchChanged('ra'))
      ..add(const TransactionsSearchChanged('rahul')),
    wait: const Duration(milliseconds: 30),
    verify: (bloc) {
      expect(bloc.state.search, 'rahul');
      expect(bloc.state.items, [tDebit]);
    },
  );
}
