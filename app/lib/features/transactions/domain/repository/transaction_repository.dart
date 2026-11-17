import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../entities/transaction_entity.dart';
import '../entities/transaction_page_entity.dart';
import '../entities/transaction_query.dart';

abstract interface class TransactionRepository {
  Future<Either<Failure, TransactionPageEntity>> getTransactions(
    TransactionQuery query,
  );

  Future<Either<Failure, TransactionEntity>> getTransaction(String id);
}
