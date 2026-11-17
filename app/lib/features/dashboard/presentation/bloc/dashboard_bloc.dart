import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../transactions/domain/entities/transaction_query.dart';
import '../../../transactions/domain/repository/transaction_repository.dart';
import '../../domain/repository/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._dashboardRepository, this._transactionRepository)
    : super(const DashboardState()) {
    on<DashboardRequested>(_onRequested);
    on<DashboardRefreshed>(_onRefreshed);
  }

  static const int recentTransactionsLimit = 5;

  final DashboardRepository _dashboardRepository;
  final TransactionRepository _transactionRepository;

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearFailure: true));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    DashboardRefreshed event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true, clearFailure: true));
    await _load(emit);
  }

  Future<void> _load(Emitter<DashboardState> emit) async {
    final (profile, wallet, recent) = await (
      _dashboardRepository.getProfile(),
      _dashboardRepository.getWalletBalance(),
      _transactionRepository.getTransactions(
        const TransactionQuery(limit: recentTransactionsLimit),
      ),
    ).wait;

    final failure =
        profile.getLeft().toNullable() ??
        wallet.getLeft().toNullable() ??
        recent.getLeft().toNullable();

    if (failure != null) {
      emit(
        state.copyWith(
          status: state.hasData
              ? DashboardStatus.loaded
              : DashboardStatus.failure,
          isRefreshing: false,
          failure: failure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DashboardStatus.loaded,
        user: profile.toNullable(),
        wallet: wallet.toNullable(),
        recentTransactions: recent.toNullable()!.items,
        isRefreshing: false,
      ),
    );
  }
}
