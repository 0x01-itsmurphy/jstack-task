import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repository/dashboard_repository.dart';
import '../datasource/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDataSource _remote;

  @override
  Future<Either<Failure, UserEntity>> getProfile() {
    return guard(_remote.getProfile);
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance() {
    return guard(_remote.getWalletBalance);
  }
}
