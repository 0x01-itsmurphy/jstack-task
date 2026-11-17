import { Router } from 'express';
import { ApiError } from '../utils/api-error.js';
import { sendSuccess } from '../utils/respond.js';
import { validateTransactionQuery, validateTransfer } from '../validators/index.js';
import { toTransactionDto } from '../data/mappers.js';
import { TransferService } from '../services/transfer-service.js';

const IDEMPOTENCY_KEY_RE = /^[A-Za-z0-9_-]{8,128}$/;

export const transactionRoutes = ({ store }) => {
  const router = Router();
  const transferService = new TransferService(store);

  router.get('/', (req, res) => {
    const { type, search, page, limit, from, to } = validateTransactionQuery(req.query);
    const needle = search?.toLowerCase();

    const filtered = store
      .listTransactions(req.wallet.walletId)
      .filter((t) => !type || t.type === type)
      .filter((t) => !needle || t.id.toLowerCase().includes(needle) || t.beneficiaryName.toLowerCase().includes(needle))
      .filter((t) => !from || new Date(t.createdAt) >= from)
      .filter((t) => !to || new Date(t.createdAt) <= to)
      .sort((a, b) => b.createdAt.localeCompare(a.createdAt));

    const total = filtered.length;
    const totalPages = Math.max(1, Math.ceil(total / limit));
    const items = filtered.slice((page - 1) * limit, page * limit).map(toTransactionDto);

    sendSuccess(res, items, { page, limit, total, totalPages, hasMore: page < totalPages });
  });

  router.post('/transfer', async (req, res) => {
    const idempotencyKey = req.get('idempotency-key');
    if (!idempotencyKey) {
      throw ApiError.badRequest('IDEMPOTENCY_KEY_REQUIRED', 'Idempotency-Key header is required.');
    }
    if (!IDEMPOTENCY_KEY_RE.test(idempotencyKey)) {
      throw ApiError.badRequest(
        'INVALID_IDEMPOTENCY_KEY',
        'Idempotency-Key must be 8-128 characters (letters, digits, "-" or "_").',
      );
    }

    const payload = validateTransfer(req.body);
    const { replayed, ...result } = await transferService.transfer({
      user: req.user,
      wallet: req.wallet,
      idempotencyKey,
      payload,
    });

    res.set('Idempotent-Replayed', String(replayed));
    sendSuccess(res, result);
  });

  router.get('/:id', (req, res) => {
    const transaction = store.findTransaction(req.wallet.walletId, req.params.id.toUpperCase());
    if (!transaction) {
      throw ApiError.notFound('TRANSACTION_NOT_FOUND', `Transaction ${req.params.id} was not found.`);
    }
    sendSuccess(res, toTransactionDto(transaction));
  });

  return router;
};
