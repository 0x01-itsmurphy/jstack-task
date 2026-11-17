import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('--> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    AppLogger.info(
      '<-- ${response.statusCode} ${request.method} ${request.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    AppLogger.error(
      '<-- ${err.response?.statusCode ?? err.type.name} ${request.method} ${request.uri}',
    );
    handler.next(err);
  }
}
