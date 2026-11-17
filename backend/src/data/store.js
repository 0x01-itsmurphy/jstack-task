import { DEMO_USER, DEMO_WALLET, SEED_TRANSACTIONS } from './seed.js';

const TXN_PREFIX = 'TXN';

export class Store {
  constructor() {
    this.reset();
  }

  reset() {
    this.users = [{ ...DEMO_USER }];
    this.wallets = [{ ...DEMO_WALLET }];
    this.transactions = SEED_TRANSACTIONS.map((t) => ({ ...t }));
    this.idempotencyRecords = new Map();
    this.nextTxnNumber =
      Math.max(...this.transactions.map((t) => Number(t.id.slice(TXN_PREFIX.length)))) + 1;
  }

  findUserByEmail(email) {
    return this.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
  }

  findUserById(id) {
    return this.users.find((u) => u.id === id);
  }

  findWalletByUserId(userId) {
    return this.wallets.find((w) => w.userId === userId);
  }

  listTransactions(walletId) {
    return this.transactions.filter((t) => t.walletId === walletId);
  }

  findTransaction(walletId, id) {
    return this.transactions.find((t) => t.walletId === walletId && t.id === id);
  }

  addTransaction(transaction) {
    this.transactions.push(transaction);
    return transaction;
  }

  generateTransactionId() {
    return `${TXN_PREFIX}${this.nextTxnNumber++}`;
  }
}
