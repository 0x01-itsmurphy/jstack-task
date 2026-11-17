import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/transfer_request_entity.dart';
import '../../domain/entities/transfer_result_entity.dart';
import '../../domain/repository/transfer_repository.dart';
import '../datasource/transfer_remote_data_source.dart';

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._remote);

  final TransferRemoteDataSource _remote;

  @override
  Future<Either<Failure, TransferResultEntity>> transfer({
    required TransferRequestEntity request,
    required String idempotencyKey,
  }) {
    return guard(
      () => _remote.transfer(request: request, idempotencyKey: idempotencyKey),
    );
  }
}
