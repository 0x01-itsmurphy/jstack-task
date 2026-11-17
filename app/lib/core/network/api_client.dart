import 'package:dio/dio.dart';

import 'api_response.dart';
import 'app_exceptions.dart';
import 'exception_handler.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _request(
      () => _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<ApiResponse> post(String path, {Object? data, Options? options}) {
    return _request(
      () => _dio.post<Object?>(path, data: data, options: options),
    );
  }

  Future<ApiResponse> _request(
    Future<Response<Object?>> Function() request,
  ) async {
    final Response<Object?> response;
    try {
      response = await request();
    } on DioException catch (error) {
      throw ExceptionHandler.handle(error);
    }

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const UnknownException('Unexpected response from the server.');
    }

    final apiResponse = ApiResponse.fromJson(body);
    if (!apiResponse.success) {
      throw ExceptionHandler.fromBody(body, statusCode: response.statusCode);
    }
    return apiResponse;
  }
}
