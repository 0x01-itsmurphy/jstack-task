import 'package:jwallet_lite/features/auth/domain/entities/user_entity.dart';
import 'package:jwallet_lite/features/dashboard/domain/entities/wallet_entity.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_entity.dart';
import 'package:jwallet_lite/features/transactions/domain/entities/transaction_page_entity.dart';
import 'package:jwallet_lite/features/transfer/domain/entities/transfer_request_entity.dart';
import 'package:jwallet_lite/features/transfer/domain/entities/transfer_result_entity.dart';

const tUser = UserEntity(
  id: 'USR10001',
  name: 'Demo User',
  email: 'demo@jstack.co',
);

const tWallet = WalletEntity(
  walletId: 'WALLET10001',
  currency: 'INR',
  availableBalance: 25450.75,
  maskedAccountNumber: 'XXXX XXXX 4589',
);

const tWalletAfterTransfer = WalletEntity(
  walletId: 'WALLET10001',
  currency: 'INR',
  availableBalance: 23950.75,
  maskedAccountNumber: 'XXXX XXXX 4589',
);

final tDebit = TransactionEntity(
  id: 'TXN10001',
  type: TransactionType.debit,
  amount: 1500,
  currency: 'INR',
  beneficiaryName: 'Rahul Sharma',
  status: TransactionStatus.success,
  createdAt: DateTime(2026, 10, 20, 10, 30),
);

final tCredit = TransactionEntity(
  id: 'TXN10002',
  type: TransactionType.credit,
  amount: 5000,
  currency: 'INR',
  beneficiaryName: 'Amit Kumar',
  status: TransactionStatus.pending,
  createdAt: DateTime(2026, 10, 19, 14, 15),
);

final tTransactionPage = TransactionPageEntity(
  items: [tDebit, tCredit],
  page: 1,
  total: 2,
  hasMore: false,
);

const tTransferRequest = TransferRequestEntity(
  beneficiaryName: 'Rahul Sharma',
  mobileNumber: '9876543210',
  amount: 1500,
  remarks: 'Payment for services',
);

final tTransferResult = TransferResultEntity(
  transactionId: 'TXN10013',
  status: 'SUCCESS',
  amount: 1500,
  currency: 'INR',
  availableBalance: 23950.75,
  beneficiaryName: 'Rahul Sharma',
  createdAt: DateTime(2026, 11, 17, 18, 30),
  remarks: 'Payment for services',
);
