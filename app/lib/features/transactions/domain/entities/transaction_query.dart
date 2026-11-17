import 'package:equatable/equatable.dart';

import 'transaction_entity.dart';

class TransactionQuery extends Equatable {
  const TransactionQuery({
    this.type,
    this.search,
    this.page = 1,
    this.limit = 20,
  });

  final TransactionType? type;
  final String? search;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [type, search, page, limit];
}
