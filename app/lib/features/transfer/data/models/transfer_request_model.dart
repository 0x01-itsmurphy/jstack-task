import '../../domain/entities/transfer_request_entity.dart';

extension TransferRequestJson on TransferRequestEntity {
  Map<String, dynamic> toJson() {
    return {
      'beneficiaryName': beneficiaryName,
      'mobileNumber': mobileNumber,
      'amount': amount,
      if (remarks?.isNotEmpty ?? false) 'remarks': remarks,
    };
  }
}
