import { ApiError } from '../utils/api-error.js';

export const requestLogger = ({ silent }) => (req, res, next) => {
  if (silent) return next();
  const start = process.hrtime.bigint();
  res.on('finish', () => {
    const ms = Number(process.hrtime.bigint() - start) / 1e6;
    console.log(`${req.method} ${req.originalUrl} -> ${res.statusCode} (${ms.toFixed(0)}ms)`);
  });
  next();
};

export const simulateLatency = (delayMs) => async (_req, _res, next) => {
  if (delayMs > 0) await new Promise((resolve) => setTimeout(resolve, delayMs));
  next();
};

export const simulateError = (req, _res, next) => {
  const status = Number(req.get('x-simulate-error'));
  if (status === 500) throw new Error('Simulated server failure');
  if (status >= 400 && status < 600) {
    throw new ApiError(status, 'SIMULATED_ERROR', `Simulated ${status} error.`);
  }
  next();
};

export const notFoundHandler = (req) => {
  throw ApiError.notFound('ROUTE_NOT_FOUND', `Route ${req.method} ${req.path} does not exist.`);
};

export const errorHandler = (err, _req, res, _next) => {
  let apiError = err;

  if (!(err instanceof ApiError)) {
    if (err.type === 'entity.parse.failed') {
      apiError = ApiError.badRequest('INVALID_JSON', 'Request body is not valid JSON.');
    } else if (err.type === 'entity.too.large') {
      apiError = ApiError.badRequest('PAYLOAD_TOO_LARGE', 'Request body is too large.');
    } else {
      console.error(err);
      apiError = new ApiError(500, 'INTERNAL_ERROR', 'Something went wrong. Please try again later.');
    }
  }

  const error = { code: apiError.code, message: apiError.message };
  if (apiError.details) error.details = apiError.details;
  res.status(apiError.status).json({ success: false, error });
};
