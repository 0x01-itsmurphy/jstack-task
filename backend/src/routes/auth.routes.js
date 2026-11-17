import { Router } from 'express';
import { ApiError } from '../utils/api-error.js';
import { sendSuccess } from '../utils/respond.js';
import { validateLogin } from '../validators/index.js';
import { toUserDto } from '../data/mappers.js';

export const authRoutes = ({ store, config }) => {
  const router = Router();

  router.post('/login', (req, res) => {
    const { email, password } = validateLogin(req.body);
    const user = store.findUserByEmail(email);

    if (!user || user.password !== password) {
      throw ApiError.unauthorized('INVALID_CREDENTIALS', 'Invalid email or password.');
    }

    sendSuccess(res, {
      accessToken: config.accessToken,
      user: toUserDto(user),
    });
  });

  return router;
};
