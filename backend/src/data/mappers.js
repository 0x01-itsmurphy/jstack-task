import { toRupees } from '../utils/money.js';

export const toUserDto = (user, wallet) => ({
  id: user.id,
  name: user.name,
  email: user.email,
  walletId: wallet?.walletId ?? null,
});

export const toWalletDto = (wallet) => ({
  walletId: wallet.walletId,
  currency: wallet.currency,
  availableBalance: toRupees(wallet.balancePaise),
  maskedAccountNumber: wallet.maskedAccountNumber,
});

export const toTransactionDto = (t) => ({
  id: t.id,
  type: t.type,
  amount: toRupees(t.amountPaise),
  currency: t.currency,
  beneficiaryName: t.beneficiaryName,
  mobileNumber: t.mobileNumber,
  status: t.status,
  remarks: t.remarks,
  createdAt: t.createdAt,
});
