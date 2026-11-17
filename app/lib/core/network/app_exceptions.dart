sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class BadRequestException extends AppException {
  const BadRequestException(
    super.message, {
    super.statusCode,
    super.code,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode, super.code});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode, super.code});
}

class ConflictException extends AppException {
  const ConflictException(super.message, {super.statusCode, super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.code});
}

class ServerConnectionException extends AppException {
  const ServerConnectionException([
    super.message = 'Unable to reach the server. Please try again.',
  ]);
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException([
    super.message = 'The request timed out. Please try again.',
  ]);
}

class NoInternetException extends AppException {
  const NoInternetException([
    super.message = 'No internet connection. Check your network and retry.',
  ]);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Unable to access secure storage.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong.']);
}
