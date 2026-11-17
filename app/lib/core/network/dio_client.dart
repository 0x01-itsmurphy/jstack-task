import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logger_interceptor.dart';

class DioClient {
  DioClient(AuthInterceptor authInterceptor)
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          sendTimeout: AppConfig.sendTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(authInterceptor);
    if (kDebugMode) dio.interceptors.add(LoggerInterceptor());
  }

  final Dio dio;
}
