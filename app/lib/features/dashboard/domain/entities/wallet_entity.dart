import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  const WalletEntity({
    required this.walletId,
    required this.currency,
    required this.availableBalance,
    required this.maskedAccountNumber,
  });

  final String walletId;
  final String currency;
  final double availableBalance;
  final String maskedAccountNumber;

  @override
  List<Object?> get props => [
    walletId,
    currency,
    availableBalance,
    maskedAccountNumber,
  ];
}
