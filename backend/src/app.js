import express from 'express';
import { config as defaultConfig } from './config.js';
import { Store } from './data/store.js';
import { requireAuth } from './middleware/auth.js';
import {
  errorHandler,
  notFoundHandler,
  requestLogger,
  simulateError,
  simulateLatency,
} from './middleware/common.js';
import { authRoutes } from './routes/auth.routes.js';
import { userRoutes, walletRoutes } from './routes/user.routes.js';
import { transactionRoutes } from './routes/transaction.routes.js';
import { devRoutes } from './routes/dev.routes.js';

export const createApp = ({ config: overrides = {}, store = new Store(), silent = false } = {}) => {
  const config = { ...defaultConfig, ...overrides };
  const deps = { store, config };
  const app = express();

  app.disable('x-powered-by');
  app.use(requestLogger({ silent }));
  app.use(express.json({ limit: '10kb' }));

  const apiInfo = (_req, res) =>
    res.json({
      success: true,
      data: {
        name: 'jWallet Lite Mock API',
        version: 'v1',
        endpoints: [
          'POST /api/v1/auth/login',
          'GET  /api/v1/users/profile',
          'GET  /api/v1/wallet/balance',
          'GET  /api/v1/transactions',
          'POST /api/v1/transactions/transfer',
          'GET  /api/v1/transactions/:id',
        ],
      },
    });

  app.get('/', apiInfo);
  app.get('/health', (_req, res) => res.json({ success: true, data: { status: 'ok' } }));

  const api = express.Router();
  api.get('/', apiInfo);
  api.use(simulateLatency(config.responseDelayMs));
  if (config.enableDevRoutes) {
    api.use(simulateError);
    api.use('/dev', devRoutes(deps));
  }

  api.use('/auth', authRoutes(deps));

  const auth = requireAuth(deps);
  api.use('/users', auth, userRoutes(deps));
  api.use('/wallet', auth, walletRoutes(deps));
  api.use('/transactions', auth, transactionRoutes(deps));

  app.use('/api/v1', api);
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
