# jWallet Lite: Mock REST API

A lightweight Node.js + Express backend for the jWallet Lite Flutter app. Data lives in memory and is re-seeded on every start.

## Requirements

- Node.js **22+** (uses the built-in `--env-file`, `--watch` and `node:test`)

## Setup and run

```bash
cd backend
npm install
cp .env.example .env     # optional: defaults work without it
npm run dev              # auto-restarts on file changes
# or: npm start
```

On startup the server prints the base URL to use for each target:

```
Local:            http://localhost:3000/api/v1
Android emulator: http://10.0.2.2:3000/api/v1
Physical device:  http://<your-LAN-IP>:3000/api/v1
```

For a physical device, the phone and the computer must be on the same Wi-Fi, and the server must listen on `0.0.0.0` (the default).

## Configuration (`.env`)

| Variable | Default | Purpose |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `3000` | Port |
| `MOCK_ACCESS_TOKEN` | `mock_access_token_123` | Bearer token returned by login and required by protected routes |
| `MOCK_DELAY_MS` | `0` | Artificial latency per request, to make loading states visible |
| `ENABLE_DEV_ROUTES` | `true` | Enables `/dev/reset` and the `X-Simulate-Error` header |

## Demo credentials

| Email | Password |
|---|---|
| `demo@jstack.co` | `Demo@123` |

## Endpoints

All responses use one envelope:

```jsonc
// success
{ "success": true, "data": { ... }, "meta": { ... } }   // meta only on paginated lists
// error
{ "success": false, "error": { "code": "INSUFFICIENT_BALANCE", "message": "...", "details": { ... } } }
```

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/v1/auth/login` | – | Authenticate and receive a bearer token |
| GET | `/api/v1/users/profile` | ✔ | Current user |
| GET | `/api/v1/wallet/balance` | ✔ | Wallet balance, currency, masked account |
| GET | `/api/v1/transactions` | ✔ | History, newest first. Query: `type` (CREDIT/DEBIT), `search` (reference or name), `from`/`to` (ISO dates), `page`, `limit` (1–100, default 20) |
| GET | `/api/v1/transactions/:id` | ✔ | Transaction details |
| POST | `/api/v1/transactions/transfer` | ✔ | Money transfer. Requires an `Idempotency-Key` header |
| POST | `/api/v1/dev/reset` | – | Dev only: restore seed data |
| GET | `/health` | – | Liveness check |

### Status codes and error codes

| HTTP | `error.code` | When |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Invalid body or query; `details.fieldErrors` holds per-field messages |
| 400 | `INVALID_JSON`, `IDEMPOTENCY_KEY_REQUIRED`, `INVALID_IDEMPOTENCY_KEY` | Malformed request |
| 401 | `INVALID_CREDENTIALS` | Wrong email or password |
| 401 | `UNAUTHORIZED`, `INVALID_TOKEN` | Missing or invalid bearer token |
| 404 | `TRANSACTION_NOT_FOUND`, `ROUTE_NOT_FOUND` | Unknown transaction or route |
| 409 | `INSUFFICIENT_BALANCE` | Amount exceeds the available balance; `details.availableBalance` is included |
| 409 | `IDEMPOTENCY_KEY_REUSED` | Same key sent with a different payload |
| 500 | `INTERNAL_ERROR` | Unexpected failure |

### Transfer validation rules

- `beneficiaryName`: required, at most 100 characters
- `mobileNumber`: 10-digit Indian mobile number (`^[6-9]\d{9}$`)
- `amount`: JSON number, greater than 0, at most 2 decimal places
- `remarks`: optional, at most 200 characters

## Design notes

- **The backend owns the balance.** Validation, the balance check and the deduction all happen on the server, and the new balance comes back in the transfer response.
- **Idempotency.** The server stores a fingerprint and the result for each `Idempotency-Key`:
  - Same key and same payload: it returns the original result without deducting again, and sets the header `Idempotent-Replayed: true`. This also covers retries that arrive while the first request is still being processed.
  - Same key with a different payload: it returns `409`.
  - Failed attempts (for example, insufficient balance) aren't stored, so retrying them is safe because no money moved.
- **Money is stored as integer paise** internally, so values like ₹0.10 + ₹0.20 don't pick up floating-point errors. Rupee values appear only at the API boundary.
- **Layering:** `routes` (HTTP) → `validators` → `services` (business rules) → `data/store` (in-memory). `createApp()` takes its own store and config, so tests run against isolated instances.

## Tests

```bash
npm test
```

33 tests cover auth, token checks, filters and pagination, transfer validation, insufficient balance, idempotent replays (including concurrent duplicates), and the error envelope.

## API collection

Import `postman/jWallet-Lite.postman_collection.json` into Postman or Bruno. Run **Auth → Login** first; it saves the token for the other requests.

## Known limitations

- Data is in memory only, so restarting the server resets the balance and history.
- There is a single static mock token: it doesn't expire, and logout is client-side only.
- There is only one demo user and one wallet.
