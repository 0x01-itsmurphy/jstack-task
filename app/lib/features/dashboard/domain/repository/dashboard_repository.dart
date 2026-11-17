import 'package:fpdart/fpdart.dart';

import '../../../../core/failure/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/wallet_entity.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, UserEntity>> getProfile();

  Future<Either<Failure, WalletEntity>> getWalletBalance();
}
