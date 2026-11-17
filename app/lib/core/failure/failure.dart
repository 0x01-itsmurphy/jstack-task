import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../network/app_exceptions.dart';

sealed class Failure extends Equatable {
  const Failure(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  List<Object?> get props => [message, statusCode, code];

  @override
  String toString() => message;
}

class ApiFailure extends Failure {
  const ApiFailure(
    super.message, {
    super.statusCode,
    super.code,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

extension AppExceptionMapper on AppException {
  Failure toFailure() => switch (this) {
    NoInternetException() ||
    ServerConnectionException() ||
    RequestTimeoutException() => NetworkFailure(message),
    CacheException() => CacheFailure(message),
    UnknownException() => UnknownFailure(message),
    BadRequestException(:final fieldErrors) => ApiFailure(
      message,
      statusCode: statusCode,
      code: code,
      fieldErrors: fieldErrors,
    ),
    _ => ApiFailure(message, statusCode: statusCode, code: code),
  };
}

Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on AppException catch (error) {
    return Left(error.toFailure());
  } on TypeError {
    return const Left(UnknownFailure('Unexpected response from the server.'));
  } on FormatException {
    return const Left(UnknownFailure('Unexpected response from the server.'));
  }
}
