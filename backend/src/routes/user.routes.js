import { Router } from 'express';
import { sendSuccess } from '../utils/respond.js';
import { toUserDto, toWalletDto } from '../data/mappers.js';

export const userRoutes = () => {
  const router = Router();

  router.get('/profile', (req, res) => {
    sendSuccess(res, toUserDto(req.user));
  });

  return router;
};

export const walletRoutes = () => {
  const router = Router();

  router.get('/balance', (req, res) => {
    sendSuccess(res, toWalletDto(req.wallet));
  });

  return router;
};
