import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_query.dart';
import '../models/transaction_model.dart';
import '../models/transaction_page_model.dart';

class TransactionRemoteDataSource {
  TransactionRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<TransactionPageModel> getTransactions(TransactionQuery query) async {
    final response = await _apiClient.get(
      ApiEndpoints.transactions,
      queryParameters: {
        'page': query.page,
        'limit': query.limit,
        if (query.type != null) 'type': _type(query.type!),
        if (query.search?.isNotEmpty ?? false) 'search': query.search,
      },
    );

    return TransactionPageModel.fromJson(
      response.data as List<dynamic>,
      meta: response.meta ?? const {},
    );
  }

  Future<TransactionModel> getTransaction(String id) async {
    final response = await _apiClient.get(ApiEndpoints.transaction(id));
    return TransactionModel.fromJson(response.data as Map<String, dynamic>);
  }

  String _type(TransactionType type) => switch (type) {
    TransactionType.credit => 'CREDIT',
    TransactionType.debit => 'DEBIT',
  };
}
