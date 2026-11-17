import { after, before, beforeEach, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { createApp } from '../src/app.js';
import { Store } from '../src/data/store.js';

const TOKEN = 'test_token_abc';
const store = new Store();
let server;
let baseUrl;

before(async () => {
  const app = createApp({
    store,
    silent: true,
    config: { accessToken: TOKEN, responseDelayMs: 0, enableDevRoutes: true },
  });
  await new Promise((resolve) => {
    server = app.listen(0, '127.0.0.1', resolve);
  });
  baseUrl = `http://127.0.0.1:${server.address().port}/api/v1`;
});

after(() => server.close());
beforeEach(() => store.reset());

const request = async (method, path, { body, token = TOKEN, headers = {} } = {}) => {
  const res = await fetch(`${baseUrl}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
    body: body === undefined ? undefined : typeof body === 'string' ? body : JSON.stringify(body),
  });
  return { status: res.status, headers: res.headers, json: await res.json() };
};

const transferBody = { beneficiaryName: 'Rahul Sharma', mobileNumber: '9876543210', amount: 1500, remarks: 'Test' };
const transfer = (key, body = transferBody) =>
  request('POST', '/transactions/transfer', { body, headers: { 'Idempotency-Key': key } });

describe('POST /auth/login', () => {
  test('returns token and user for valid credentials', async () => {
    const { status, json } = await request('POST', '/auth/login', {
      token: null,
      body: { email: 'demo@jstack.co', password: 'Demo@123' },
    });
    assert.equal(status, 200);
    assert.deepEqual(json, {
      success: true,
      data: {
        accessToken: TOKEN,
        user: { id: 'USR10001', name: 'Demo User', email: 'demo@jstack.co' },
      },
    });
  });

  test('email match is case-insensitive', async () => {
    const { status } = await request('POST', '/auth/login', {
      token: null,
      body: { email: ' Demo@JStack.co ', password: 'Demo@123' },
    });
    assert.equal(status, 200);
  });

  test('returns 401 for a wrong password', async () => {
    const { status, json } = await request('POST', '/auth/login', {
      token: null,
      body: { email: 'demo@jstack.co', password: 'wrong' },
    });
    assert.equal(status, 401);
    assert.equal(json.success, false);
    assert.equal(json.error.code, 'INVALID_CREDENTIALS');
  });

  test('returns 400 with field errors for missing fields', async () => {
    const { status, json } = await request('POST', '/auth/login', { token: null, body: { email: 'bad' } });
    assert.equal(status, 400);
    assert.equal(json.error.code, 'VALIDATION_ERROR');
    assert.ok(json.error.details.fieldErrors.email);
    assert.ok(json.error.details.fieldErrors.password);
  });

  test('returns 400 for malformed JSON', async () => {
    const { status, json } = await request('POST', '/auth/login', { token: null, body: '{not json' });
    assert.equal(status, 400);
    assert.equal(json.error.code, 'INVALID_JSON');
  });
});

describe('authentication', () => {
  test('protected endpoints reject a missing token', async () => {
    const { status, json } = await request('GET', '/wallet/balance', { token: null });
    assert.equal(status, 401);
    assert.equal(json.error.code, 'UNAUTHORIZED');
  });

  test('protected endpoints reject an invalid token', async () => {
    const { status, json } = await request('GET', '/wallet/balance', { token: 'nope' });
    assert.equal(status, 401);
    assert.equal(json.error.code, 'INVALID_TOKEN');
  });
});

describe('GET /users/profile and /wallet/balance', () => {
  test('returns the profile', async () => {
    const { status, json } = await request('GET', '/users/profile');
    assert.equal(status, 200);
    assert.deepEqual(json.data, { id: 'USR10001', name: 'Demo User', email: 'demo@jstack.co' });
  });

  test('returns the seeded balance', async () => {
    const { status, json } = await request('GET', '/wallet/balance');
    assert.equal(status, 200);
    assert.deepEqual(json.data, {
      walletId: 'WALLET10001',
      currency: 'INR',
      availableBalance: 25450.75,
      maskedAccountNumber: 'XXXX XXXX 4589',
    });
  });
});

describe('GET /transactions', () => {
  test('returns at least 10 transactions, newest first', async () => {
    const { status, json } = await request('GET', '/transactions?limit=100');
    assert.equal(status, 200);
    assert.ok(json.data.length >= 10);
    const dates = json.data.map((t) => t.createdAt);
    assert.deepEqual(dates, [...dates].sort().reverse());
  });

  test('filters by type', async () => {
    const { json } = await request('GET', '/transactions?type=credit&limit=100');
    assert.ok(json.data.length > 0);
    assert.ok(json.data.every((t) => t.type === 'CREDIT'));
  });

  test('searches by reference or beneficiary name', async () => {
    const byName = await request('GET', '/transactions?search=rahul');
    assert.deepEqual(byName.json.data.map((t) => t.id), ['TXN10001']);
    const byRef = await request('GET', '/transactions?search=txn10002');
    assert.deepEqual(byRef.json.data.map((t) => t.id), ['TXN10002']);
  });

  test('paginates with meta', async () => {
    const { json } = await request('GET', '/transactions?limit=5&page=1');
    assert.equal(json.data.length, 5);
    assert.equal(json.meta.total, 12);
    assert.equal(json.meta.hasMore, true);
  });

  test('rejects an invalid type filter', async () => {
    const { status } = await request('GET', '/transactions?type=REFUND');
    assert.equal(status, 400);
  });
});

describe('GET /transactions/:id', () => {
  test('returns a transaction', async () => {
    const { status, json } = await request('GET', '/transactions/TXN10001');
    assert.equal(status, 200);
    assert.equal(json.data.beneficiaryName, 'Rahul Sharma');
    assert.equal(json.data.remarks, 'Payment for services');
  });

  test('returns 404 for an unknown id', async () => {
    const { status, json } = await request('GET', '/transactions/TXN99999');
    assert.equal(status, 404);
    assert.equal(json.error.code, 'TRANSACTION_NOT_FOUND');
  });
});

describe('POST /transactions/transfer', () => {
  test('deducts balance and records the transaction', async () => {
    const { status, json, headers } = await transfer('key-success-0001');
    assert.equal(status, 200);
    assert.equal(headers.get('idempotent-replayed'), 'false');
    assert.equal(json.data.status, 'SUCCESS');
    assert.equal(json.data.amount, 1500);
    assert.equal(json.data.availableBalance, 23950.75);
    assert.match(json.data.transactionId, /^TXN\d+$/);

    const balance = await request('GET', '/wallet/balance');
    assert.equal(balance.json.data.availableBalance, 23950.75);

    const detail = await request('GET', `/transactions/${json.data.transactionId}`);
    assert.equal(detail.status, 200);
    assert.equal(detail.json.data.type, 'DEBIT');

    const list = await request('GET', '/transactions?limit=1');
    assert.equal(list.json.data[0].id, json.data.transactionId);
  });

  test('handles decimal amounts without floating point drift', async () => {
    const { json } = await transfer('key-decimal-0001', { ...transferBody, amount: 0.1 });
    assert.equal(json.data.availableBalance, 25450.65);
  });

  test('replays the original result for the same key + payload (no double deduction)', async () => {
    const first = await transfer('key-replay-0001');
    const second = await transfer('key-replay-0001');
    assert.equal(second.status, 200);
    assert.equal(second.headers.get('idempotent-replayed'), 'true');
    assert.equal(second.json.data.transactionId, first.json.data.transactionId);

    const balance = await request('GET', '/wallet/balance');
    assert.equal(balance.json.data.availableBalance, 23950.75);
  });

  test('concurrent duplicates with the same key deduct only once', async () => {
    const results = await Promise.all([transfer('key-race-0001'), transfer('key-race-0001'), transfer('key-race-0001')]);
    const ids = new Set(results.map((r) => r.json.data.transactionId));
    assert.equal(ids.size, 1);
    const balance = await request('GET', '/wallet/balance');
    assert.equal(balance.json.data.availableBalance, 23950.75);
  });

  test('rejects reuse of a key with a different payload', async () => {
    await transfer('key-mismatch-01');
    const { status, json } = await transfer('key-mismatch-01', { ...transferBody, amount: 99 });
    assert.equal(status, 409);
    assert.equal(json.error.code, 'IDEMPOTENCY_KEY_REUSED');
  });

  test('returns 409 for insufficient balance and leaves balance untouched', async () => {
    const { status, json } = await transfer('key-insufficient', { ...transferBody, amount: 1_000_000 });
    assert.equal(status, 409);
    assert.equal(json.error.code, 'INSUFFICIENT_BALANCE');
    assert.equal(json.error.details.availableBalance, 25450.75);

    const balance = await request('GET', '/wallet/balance');
    assert.equal(balance.json.data.availableBalance, 25450.75);
  });

  test('allows transferring the exact available balance', async () => {
    const { status, json } = await transfer('key-exact-00001', { ...transferBody, amount: 25450.75 });
    assert.equal(status, 200);
    assert.equal(json.data.availableBalance, 0);
  });

  for (const [name, body, field] of [
    ['empty beneficiary name', { ...transferBody, beneficiaryName: '  ' }, 'beneficiaryName'],
    ['invalid mobile number', { ...transferBody, mobileNumber: '12345' }, 'mobileNumber'],
    ['zero amount', { ...transferBody, amount: 0 }, 'amount'],
    ['negative amount', { ...transferBody, amount: -50 }, 'amount'],
    ['string amount', { ...transferBody, amount: '1500' }, 'amount'],
    ['more than 2 decimals', { ...transferBody, amount: 10.555 }, 'amount'],
  ]) {
    test(`returns 400 for ${name}`, async () => {
      const { status, json } = await transfer(`key-${field}-${Math.random().toString(36).slice(2, 10)}`, body);
      assert.equal(status, 400);
      assert.equal(json.error.code, 'VALIDATION_ERROR');
      assert.ok(json.error.details.fieldErrors[field]);
    });
  }

  test('requires an Idempotency-Key header', async () => {
    const { status, json } = await request('POST', '/transactions/transfer', { body: transferBody });
    assert.equal(status, 400);
    assert.equal(json.error.code, 'IDEMPOTENCY_KEY_REQUIRED');
  });

  test('requires authentication', async () => {
    const { status } = await request('POST', '/transactions/transfer', {
      token: null,
      body: transferBody,
      headers: { 'Idempotency-Key': 'key-noauth-0001' },
    });
    assert.equal(status, 401);
  });
});

describe('errors', () => {
  test('unknown routes return 404 in the standard envelope', async () => {
    const { status, json } = await request('GET', '/does-not-exist');
    assert.equal(status, 404);
    assert.equal(json.error.code, 'ROUTE_NOT_FOUND');
  });

  test('X-Simulate-Error: 500 returns a 500 envelope', async () => {
    const original = console.error;
    console.error = () => {};
    try {
      const { status, json } = await request('GET', '/wallet/balance', { headers: { 'X-Simulate-Error': '500' } });
      assert.equal(status, 500);
      assert.equal(json.error.code, 'INTERNAL_ERROR');
    } finally {
      console.error = original;
    }
  });
});
