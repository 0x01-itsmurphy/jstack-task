import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jwallet_lite/core/failure/failure.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:jwallet_lite/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_query.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockDashboardRepository dashboardRepository;
  late MockTransactionRepository transactionRepository;

  const networkFailure = NetworkFailure('No internet connection.');

  DashboardBloc buildBloc() =>
      DashboardBloc(dashboardRepository, transactionRepository);

  final loaded = DashboardState(
    status: DashboardStatus.loaded,
    user: tUser,
    wallet: tWallet,
    recentTransactions: tTransactionPage.items,
  );

  setUp(() {
    dashboardRepository = MockDashboardRepository();
    transactionRepository = MockTransactionRepository();
    when(() => dashboardRepository.getProfile())
        .thenAnswer((_) async => const Right(tUser));
    when(() => dashboardRepository.getWalletBalance())
        .thenAnswer((_) async => const Right(tWallet));
    when(() => transactionRepository.getTransactions(any()))
        .thenAnswer((_) async => Right(tTransactionPage));
  });

  blocTest<DashboardBloc, DashboardState>(
    'loads profile, balance and the latest five transactions',
    build: buildBloc,
    act: (bloc) => bloc.add(const DashboardRequested()),
    expect: () => [
      const DashboardState(status: DashboardStatus.loading),
      loaded,
    ],
    verify: (_) => verify(
      () => transactionRepository.getTransactions(
        const TransactionQuery(limit: 5),
      ),
    ).called(1),
  );

  blocTest<DashboardBloc, DashboardState>(
    'emits failure when the balance cannot be loaded',
    setUp: () =>
        when(() => dashboardRepository.getWalletBalance())
            .thenAnswer((_) async => const Left(networkFailure)),
    build: buildBloc,
    act: (bloc) => bloc.add(const DashboardRequested()),
    expect: () => const [
      DashboardState(status: DashboardStatus.loading),
      DashboardState(status: DashboardStatus.failure, failure: networkFailure),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'refresh shows the updated balance from the backend',
    setUp: () =>
        when(() => dashboardRepository.getWalletBalance())
            .thenAnswer((_) async => const Right(tWalletAfterTransfer)),
    build: buildBloc,
    seed: () => loaded,
    act: (bloc) => bloc.add(const DashboardRefreshed()),
    expect: () => [
      loaded.copyWith(isRefreshing: true),
      loaded.copyWith(wallet: tWalletAfterTransfer),
    ],
  );

  blocTest<DashboardBloc, DashboardState>(
    'refresh failure keeps the existing data and exposes the failure',
    setUp: () =>
        when(() => dashboardRepository.getProfile())
            .thenAnswer((_) async => const Left(networkFailure)),
    build: buildBloc,
    seed: () => loaded,
    act: (bloc) => bloc.add(const DashboardRefreshed()),
    expect: () => [
      loaded.copyWith(isRefreshing: true),
      loaded.copyWith(failure: networkFailure),
    ],
  );
}
