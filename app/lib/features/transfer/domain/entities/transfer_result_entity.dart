import 'package:equatable/equatable.dart';

class TransferResultEntity extends Equatable {
  const TransferResultEntity({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.availableBalance,
    required this.beneficiaryName,
    required this.createdAt,
    this.remarks,
  });

  final String transactionId;
  final String status;
  final double amount;
  final String currency;
  final double availableBalance;
  final String beneficiaryName;
  final DateTime createdAt;
  final String? remarks;

  @override
  List<Object?> get props => [
    transactionId,
    status,
    amount,
    currency,
    availableBalance,
    beneficiaryName,
    createdAt,
    remarks,
  ];
}
