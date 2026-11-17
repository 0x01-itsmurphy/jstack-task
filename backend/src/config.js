const toInt = (value, fallback) => {
  const parsed = Number.parseInt(value ?? '', 10);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : fallback;
};

export const config = Object.freeze({
  host: process.env.HOST ?? '0.0.0.0',
  port: toInt(process.env.PORT, 3000),
  accessToken: process.env.MOCK_ACCESS_TOKEN ?? 'mock_access_token_123',
  responseDelayMs: toInt(process.env.MOCK_DELAY_MS, 0),
  enableDevRoutes: (process.env.ENABLE_DEV_ROUTES ?? 'true') === 'true',
});
