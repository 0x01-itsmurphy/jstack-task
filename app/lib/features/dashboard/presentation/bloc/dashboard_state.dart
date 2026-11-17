import 'package:equatable/equatable.dart';

import '../../../../core/failure/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet_entity.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.user,
    this.wallet,
    this.recentTransactions = const [],
    this.isRefreshing = false,
    this.failure,
  });

  final DashboardStatus status;
  final UserEntity? user;
  final WalletEntity? wallet;
  final List<TransactionEntity> recentTransactions;
  final bool isRefreshing;
  final Failure? failure;

  bool get hasData => user != null && wallet != null;

  DashboardState copyWith({
    DashboardStatus? status,
    UserEntity? user,
    WalletEntity? wallet,
    List<TransactionEntity>? recentTransactions,
    bool? isRefreshing,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      user: user ?? this.user,
      wallet: wallet ?? this.wallet,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    wallet,
    recentTransactions,
    isRefreshing,
    failure,
  ];
}
