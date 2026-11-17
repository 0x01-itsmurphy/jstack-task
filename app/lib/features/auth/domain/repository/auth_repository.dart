import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity?>> restoreSession();

  Future<Either<Failure, Unit>> logout();
}
