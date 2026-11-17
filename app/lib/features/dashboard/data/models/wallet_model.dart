import '../../domain/entities/wallet_entity.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.walletId,
    required super.currency,
    required super.availableBalance,
    required super.maskedAccountNumber,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      walletId: json['walletId'] as String,
      currency: json['currency'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
      maskedAccountNumber: json['maskedAccountNumber'] as String,
    );
  }
}
