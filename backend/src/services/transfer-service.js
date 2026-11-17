import { createHash } from 'node:crypto';
import { ApiError } from '../utils/api-error.js';
import { toPaise, toRupees } from '../utils/money.js';

export class TransferService {
  constructor(store) {
    this.store = store;
  }

  async transfer({ user, wallet, idempotencyKey, payload }) {
    const recordKey = `${user.id}:${idempotencyKey}`;
    const fingerprint = fingerprintOf(payload);
    const records = this.store.idempotencyRecords;
    const existing = records.get(recordKey);

    if (existing) {
      if (existing.fingerprint !== fingerprint) {
        throw ApiError.conflict(
          'IDEMPOTENCY_KEY_REUSED',
          'This Idempotency-Key was already used with a different request payload.',
        );
      }
      const result = await existing.promise;
      return { ...result, replayed: true };
    }

    const promise = Promise.resolve().then(() => this.#execute(wallet, payload));
    records.set(recordKey, { fingerprint, promise });

    try {
      return { ...(await promise), replayed: false };
    } catch (err) {
      records.delete(recordKey);
      throw err;
    }
  }

  #execute(wallet, { beneficiaryName, mobileNumber, amount, remarks }) {
    const amountPaise = toPaise(amount);

    if (amountPaise > wallet.balancePaise) {
      throw ApiError.conflict('INSUFFICIENT_BALANCE', 'Insufficient wallet balance for this transfer.', {
        availableBalance: toRupees(wallet.balancePaise),
        requestedAmount: amount,
      });
    }

    wallet.balancePaise -= amountPaise;

    const transaction = this.store.addTransaction({
      id: this.store.generateTransactionId(),
      walletId: wallet.walletId,
      type: 'DEBIT',
      amountPaise,
      currency: wallet.currency,
      beneficiaryName,
      mobileNumber,
      status: 'SUCCESS',
      remarks,
      createdAt: new Date().toISOString(),
    });

    return {
      transactionId: transaction.id,
      status: transaction.status,
      amount: toRupees(transaction.amountPaise),
      currency: transaction.currency,
      availableBalance: toRupees(wallet.balancePaise),
      beneficiaryName: transaction.beneficiaryName,
      mobileNumber: transaction.mobileNumber,
      remarks: transaction.remarks,
      createdAt: transaction.createdAt,
    };
  }
}

const fingerprintOf = ({ beneficiaryName, mobileNumber, amount, remarks }) =>
  createHash('sha256')
    .update(JSON.stringify([beneficiaryName, mobileNumber, toPaise(amount), remarks ?? null]))
    .digest('hex');
