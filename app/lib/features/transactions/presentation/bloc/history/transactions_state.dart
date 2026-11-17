import 'package:equatable/equatable.dart';

import '../../../../../core/failure/failure.dart';
import '../../../domain/entities/transaction_entity.dart';

enum TransactionsStatus { initial, loading, loaded, empty, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.items = const [],
    this.type,
    this.search = '',
    this.page = 1,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final TransactionsStatus status;
  final List<TransactionEntity> items;
  final TransactionType? type;
  final String search;
  final int page;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final Failure? failure;

  bool get hasFilters => type != null || search.isNotEmpty;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<TransactionEntity>? items,
    String? search,
    int? page,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      items: items ?? this.items,
      type: type,
      search: search ?? this.search,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    type,
    search,
    page,
    hasMore,
    isRefreshing,
    isLoadingMore,
    failure,
  ];
}
