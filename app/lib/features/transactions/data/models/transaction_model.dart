import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.currency,
    required super.beneficiaryName,
    required super.status,
    required super.createdAt,
    super.mobileNumber,
    super.remarks,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: _type(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      beneficiaryName: json['beneficiaryName'] as String,
      status: _status(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      mobileNumber: json['mobileNumber'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  static TransactionType _type(String value) => switch (value) {
    'CREDIT' => TransactionType.credit,
    _ => TransactionType.debit,
  };

  static TransactionStatus _status(String value) => switch (value) {
    'SUCCESS' => TransactionStatus.success,
    'PENDING' => TransactionStatus.pending,
    _ => TransactionStatus.failed,
  };
}
