import 'package:equatable/equatable.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/transfer_request_entity.dart';
import '../../domain/entities/transfer_result_entity.dart';

enum TransferStatus { editing, reviewing, submitting, success, failure }

class TransferState extends Equatable {
  const TransferState({
    this.status = TransferStatus.editing,
    this.request,
    this.idempotencyKey,
    this.result,
    this.failure,
  });

  final TransferStatus status;
  final TransferRequestEntity? request;
  final String? idempotencyKey;
  final TransferResultEntity? result;
  final Failure? failure;

  bool get isSubmitting => status == TransferStatus.submitting;

  bool get canSubmit =>
      request != null &&
      (status == TransferStatus.reviewing || status == TransferStatus.failure);

  bool get canRetry => switch (failure) {
    NetworkFailure() || UnknownFailure() => true,
    ApiFailure(:final statusCode) => (statusCode ?? 500) >= 500,
    _ => false,
  };

  TransferState copyWith({
    TransferStatus? status,
    TransferRequestEntity? request,
    String? idempotencyKey,
    TransferResultEntity? result,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return TransferState(
      status: status ?? this.status,
      request: request ?? this.request,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      result: result ?? this.result,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, request, idempotencyKey, result, failure];
}
