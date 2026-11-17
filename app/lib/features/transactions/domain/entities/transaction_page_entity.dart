import 'package:equatable/equatable.dart';

import 'transaction_entity.dart';

class TransactionPageEntity extends Equatable {
  const TransactionPageEntity({
    required this.items,
    required this.page,
    required this.total,
    required this.hasMore,
  });

  final List<TransactionEntity> items;
  final int page;
  final int total;
  final bool hasMore;

  @override
  List<Object?> get props => [items, page, total, hasMore];
}
