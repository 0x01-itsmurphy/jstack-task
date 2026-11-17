import 'package:equatable/equatable.dart';

class TransferRequestEntity extends Equatable {
  const TransferRequestEntity({
    required this.beneficiaryName,
    required this.mobileNumber,
    required this.amount,
    this.remarks,
  });

  final String beneficiaryName;
  final String mobileNumber;
  final double amount;
  final String? remarks;

  @override
  List<Object?> get props => [beneficiaryName, mobileNumber, amount, remarks];
}
