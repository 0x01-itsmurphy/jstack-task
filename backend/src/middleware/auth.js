import { ApiError } from '../utils/api-error.js';

export const requireAuth = ({ store, config }) => (req, _res, next) => {
  const header = req.get('authorization') ?? '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    throw ApiError.unauthorized('UNAUTHORIZED', 'Missing or malformed Authorization header.');
  }
  if (token !== config.accessToken) {
    throw ApiError.unauthorized('INVALID_TOKEN', 'Session is invalid or has expired. Please log in again.');
  }

  const user = store.users[0];
  req.user = user;
  req.wallet = store.findWalletByUserId(user.id);
  next();
};
