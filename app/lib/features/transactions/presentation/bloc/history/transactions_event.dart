import 'package:equatable/equatable.dart';

import '../../../domain/entities/transaction_entity.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

final class TransactionsRequested extends TransactionsEvent {
  const TransactionsRequested();
}

final class TransactionsRefreshed extends TransactionsEvent {
  const TransactionsRefreshed();
}

final class TransactionsNextPageRequested extends TransactionsEvent {
  const TransactionsNextPageRequested();
}

final class TransactionsSearchChanged extends TransactionsEvent {
  const TransactionsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class TransactionsTypeChanged extends TransactionsEvent {
  const TransactionsTypeChanged(this.type);

  final TransactionType? type;

  @override
  List<Object?> get props => [type];
}
