import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/transaction_query.dart';
import '../../../domain/repository/transaction_repository.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this._repository) : super(const TransactionsState()) {
    on<TransactionsRequested>(_onRequested);
    on<TransactionsRefreshed>(_onRefreshed);
    on<TransactionsSearchChanged>(_onSearchChanged);
    on<TransactionsTypeChanged>(_onTypeChanged);
    on<TransactionsNextPageRequested>(_onNextPageRequested);
  }

  static const int pageSize = 20;

  final TransactionRepository _repository;
  int _latestRequest = 0;

  Future<void> _onRequested(
    TransactionsRequested event,
    Emitter<TransactionsState> emit,
  ) {
    return _loadFirstPage(
      emit,
      state.copyWith(status: TransactionsStatus.loading, clearFailure: true),
    );
  }

  Future<void> _onRefreshed(
    TransactionsRefreshed event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state.isRefreshing) return;
    await _loadFirstPage(
      emit,
      state.copyWith(isRefreshing: true, clearFailure: true),
    );
  }

  Future<void> _onSearchChanged(
    TransactionsSearchChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    final search = event.query.trim();
    if (search == state.search) return;
    await _loadFirstPage(
      emit,
      state.copyWith(
        status: TransactionsStatus.loading,
        search: search,
        clearFailure: true,
      ),
    );
  }

  Future<void> _onTypeChanged(
    TransactionsTypeChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    if (event.type == state.type) return;
    await _loadFirstPage(
      emit,
      TransactionsState(
        status: TransactionsStatus.loading,
        type: event.type,
        search: state.search,
      ),
    );
  }

  Future<void> _loadFirstPage(
    Emitter<TransactionsState> emit,
    TransactionsState pending,
  ) async {
    final current = pending.copyWith(isLoadingMore: false);
    emit(current);

    final requestId = ++_latestRequest;
    final result = await _repository.getTransactions(
      TransactionQuery(
        type: current.type,
        search: current.search,
        limit: pageSize,
      ),
    );
    if (requestId != _latestRequest) return;

    result.fold(
      (failure) => emit(
        current.isRefreshing
            ? current.copyWith(isRefreshing: false, failure: failure)
            : current.copyWith(
                status: TransactionsStatus.failure,
                items: const [],
                failure: failure,
              ),
      ),
      (page) => emit(
        current.copyWith(
          status: page.items.isEmpty
              ? TransactionsStatus.empty
              : TransactionsStatus.loaded,
          items: page.items,
          page: page.page,
          hasMore: page.hasMore,
          isRefreshing: false,
        ),
      ),
    );
  }

  Future<void> _onNextPageRequested(
    TransactionsNextPageRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state.status != TransactionsStatus.loaded ||
        !state.hasMore ||
        state.isLoadingMore ||
        state.isRefreshing) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, clearFailure: true));

    final requestId = ++_latestRequest;
    final result = await _repository.getTransactions(
      TransactionQuery(
        type: state.type,
        search: state.search,
        page: state.page + 1,
        limit: pageSize,
      ),
    );
    if (requestId != _latestRequest) return;

    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false, failure: failure)),
      (page) => emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          page: page.page,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      ),
    );
  }
}
