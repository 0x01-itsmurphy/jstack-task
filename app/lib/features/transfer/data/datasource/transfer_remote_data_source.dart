import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/transfer_request_entity.dart';
import '../models/transfer_request_model.dart';
import '../models/transfer_result_model.dart';

class TransferRemoteDataSource {
  TransferRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<TransferResultModel> transfer({
    required TransferRequestEntity request,
    required String idempotencyKey,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.transfer,
      data: request.toJson(),
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );

    return TransferResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}
