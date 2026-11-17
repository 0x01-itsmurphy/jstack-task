import { Router } from 'express';
import { sendSuccess } from '../utils/respond.js';

export const devRoutes = ({ store }) => {
  const router = Router();

  router.post('/reset', (_req, res) => {
    store.reset();
    sendSuccess(res, { message: 'Mock data reset to seed state.' });
  });

  return router;
};
