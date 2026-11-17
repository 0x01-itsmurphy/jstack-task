import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repository/transfer_repository.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc(this._repository, {String Function()? generateKey})
    : _generateKey = generateKey ?? const Uuid().v4,
      super(const TransferState()) {
    on<TransferReviewRequested>(_onReviewRequested);
    on<TransferSubmitted>(_onSubmitted);
    on<TransferReset>(_onReset);
  }

  final TransferRepository _repository;
  final String Function() _generateKey;

  void _onReviewRequested(
    TransferReviewRequested event,
    Emitter<TransferState> emit,
  ) {
    if (state.isSubmitting) return;

    final isSameTransfer =
        state.request == event.request &&
        state.idempotencyKey != null &&
        state.status != TransferStatus.success;

    emit(
      TransferState(
        status: TransferStatus.reviewing,
        request: event.request,
        idempotencyKey: isSameTransfer ? state.idempotencyKey : _generateKey(),
      ),
    );
  }

  Future<void> _onSubmitted(
    TransferSubmitted event,
    Emitter<TransferState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: TransferStatus.submitting, clearFailure: true));

    final result = await _repository.transfer(
      request: state.request!,
      idempotencyKey: state.idempotencyKey!,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: TransferStatus.failure, failure: failure),
      ),
      (transfer) => emit(
        state.copyWith(status: TransferStatus.success, result: transfer),
      ),
    );
  }

  void _onReset(TransferReset event, Emitter<TransferState> emit) {
    emit(const TransferState());
  }
}
