import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

enum TransactionStatus { success, pending, failed }

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.beneficiaryName,
    required this.status,
    required this.createdAt,
    this.mobileNumber,
    this.remarks,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String currency;
  final String beneficiaryName;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? mobileNumber;
  final String? remarks;

  bool get isCredit => type == TransactionType.credit;

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    currency,
    beneficiaryName,
    status,
    createdAt,
    mobileNumber,
    remarks,
  ];
}
