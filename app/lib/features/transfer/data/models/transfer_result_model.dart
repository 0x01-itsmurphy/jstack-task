import '../../domain/entities/transfer_result_entity.dart';

class TransferResultModel extends TransferResultEntity {
  const TransferResultModel({
    required super.transactionId,
    required super.status,
    required super.amount,
    required super.currency,
    required super.availableBalance,
    required super.beneficiaryName,
    required super.createdAt,
    super.remarks,
  });

  factory TransferResultModel.fromJson(Map<String, dynamic> json) {
    return TransferResultModel(
      transactionId: json['transactionId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      availableBalance: (json['availableBalance'] as num).toDouble(),
      beneficiaryName: json['beneficiaryName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      remarks: json['remarks'] as String?,
    );
  }
}
