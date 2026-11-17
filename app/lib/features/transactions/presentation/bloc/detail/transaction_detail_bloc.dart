import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repository/transaction_repository.dart';
import 'transaction_detail_event.dart';
import 'transaction_detail_state.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  TransactionDetailBloc(this._repository)
    : super(const TransactionDetailState()) {
    on<TransactionDetailRequested>(_onRequested);
  }

  final TransactionRepository _repository;

  Future<void> _onRequested(
    TransactionDetailRequested event,
    Emitter<TransactionDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TransactionDetailStatus.loading,
        clearFailure: true,
      ),
    );

    final result = await _repository.getTransaction(event.id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionDetailStatus.failure,
          failure: failure,
        ),
      ),
      (transaction) => emit(
        state.copyWith(
          status: TransactionDetailStatus.loaded,
          transaction: transaction,
        ),
      ),
    );
  }
}
