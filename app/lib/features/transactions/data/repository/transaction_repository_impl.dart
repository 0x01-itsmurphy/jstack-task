import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_page_entity.dart';
import '../../domain/entities/transaction_query.dart';
import '../../domain/repository/transaction_repository.dart';
import '../datasource/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._remote);

  final TransactionRemoteDataSource _remote;

  @override
  Future<Either<Failure, TransactionPageEntity>> getTransactions(
    TransactionQuery query,
  ) {
    return guard(() => _remote.getTransactions(query));
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(String id) {
    return guard(() => _remote.getTransaction(id));
  }
}
