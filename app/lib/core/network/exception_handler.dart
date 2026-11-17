import 'package:dio/dio.dart';

import 'app_exceptions.dart';

abstract final class ExceptionHandler {
  static AppException handle(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const RequestTimeoutException(),
      DioExceptionType.connectionError => _connectionError(error),
      DioExceptionType.badResponse => fromBody(
        error.response?.data,
        statusCode: error.response?.statusCode,
      ),
      DioExceptionType.cancel => const UnknownException('Request cancelled.'),
      DioExceptionType.badCertificate ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.unknown => _connectionError(error),
    };
  }

  static AppException _connectionError(DioException error) {
    final cause = error.error?.toString().toLowerCase() ?? '';
    if (cause.contains('connection refused')) {
      return const ServerConnectionException();
    }
    if (cause.contains('socket') || cause.contains('host lookup')) {
      return const NoInternetException();
    }
    return const UnknownException();
  }

  static AppException fromBody(Object? body, {int? statusCode}) {
    final error = _errorBody(body);
    final code = error?['code'] as String?;
    final message =
        error?['message'] as String? ?? _fallbackMessage(statusCode);

    return switch (statusCode) {
      400 => BadRequestException(
        message,
        statusCode: statusCode,
        code: code,
        fieldErrors: _fieldErrors(error),
      ),
      401 => UnauthorizedException(message, statusCode: statusCode, code: code),
      404 => NotFoundException(message, statusCode: statusCode, code: code),
      409 => ConflictException(message, statusCode: statusCode, code: code),
      _ => ServerException(message, statusCode: statusCode, code: code),
    };
  }

  static Map<String, dynamic>? _errorBody(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    final error = data['error'];
    return error is Map<String, dynamic> ? error : null;
  }

  static Map<String, String> _fieldErrors(Map<String, dynamic>? error) {
    final details = error?['details'];
    if (details is! Map<String, dynamic>) return const {};
    final fields = details['fieldErrors'];
    if (fields is! Map<String, dynamic>) return const {};
    return fields.map((key, value) => MapEntry(key, value.toString()));
  }

  static String _fallbackMessage(int? statusCode) => switch (statusCode) {
    400 => 'Invalid request.',
    401 => 'Your session has expired. Please log in again.',
    404 => 'The requested resource was not found.',
    409 => 'The request could not be completed.',
    _ => 'Server error. Please try again later.',
  };
}
