import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../entities/transfer_request_entity.dart';
import '../entities/transfer_result_entity.dart';

abstract interface class TransferRepository {
  Future<Either<Failure, TransferResultEntity>> transfer({
    required TransferRequestEntity request,
    required String idempotencyKey,
  });
}
