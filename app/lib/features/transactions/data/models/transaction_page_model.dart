import '../../domain/entities/transaction_page_entity.dart';
import 'transaction_model.dart';

class TransactionPageModel extends TransactionPageEntity {
  const TransactionPageModel({
    required super.items,
    required super.page,
    required super.total,
    required super.hasMore,
  });

  factory TransactionPageModel.fromJson(
    List<dynamic> items, {
    Map<String, dynamic> meta = const {},
  }) {
    return TransactionPageModel(
      items: items
          .map(
            (item) => TransactionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      page: meta['page'] as int? ?? 1,
      total: meta['total'] as int? ?? items.length,
      hasMore: meta['hasMore'] as bool? ?? false,
    );
  }
}
