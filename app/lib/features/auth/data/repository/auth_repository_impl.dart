import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_local_data_source.dart';
import '../datasource/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) {
    return guard(() async {
      final response = await _remote.login(email: email, password: password);
      await _local.saveSession(
        token: response.accessToken,
        user: response.user,
      );
      return response.user;
    });
  }

  @override
  Future<Either<Failure, UserEntity?>> restoreSession() {
    return guard(_local.readSession);
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return guard(() async {
      await _local.clearSession();
      return unit;
    });
  }
}
