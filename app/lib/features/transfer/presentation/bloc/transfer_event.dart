import 'package:equatable/equatable.dart';

import '../../domain/entities/transfer_request_entity.dart';

sealed class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

final class TransferReviewRequested extends TransferEvent {
  const TransferReviewRequested(this.request);

  final TransferRequestEntity request;

  @override
  List<Object?> get props => [request];
}

final class TransferSubmitted extends TransferEvent {
  const TransferSubmitted();
}

final class TransferReset extends TransferEvent {
  const TransferReset();
}
