import 'package:equatable/equatable.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/transaction_entity.dart';

enum TransactionDetailStatus { initial, loading, loaded, failure }

class TransactionDetailState extends Equatable {
  const TransactionDetailState({
    this.status = TransactionDetailStatus.initial,
    this.transaction,
    this.failure,
  });

  final TransactionDetailStatus status;
  final TransactionEntity? transaction;
  final Failure? failure;

  TransactionDetailState copyWith({
    TransactionDetailStatus? status,
    TransactionEntity? transaction,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return TransactionDetailState(
      status: status ?? this.status,
      transaction: transaction ?? this.transaction,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, transaction, failure];
}
