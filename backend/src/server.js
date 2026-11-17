import { networkInterfaces } from 'node:os';
import { createApp } from './app.js';
import { config } from './config.js';

const lanAddresses = () =>
  Object.values(networkInterfaces())
    .flat()
    .filter((iface) => iface && iface.family === 'IPv4' && !iface.internal)
    .map((iface) => iface.address);

const app = createApp();

app.listen(config.port, config.host, () => {
  const base = (host) => `http://${host}:${config.port}/api/v1`;
  console.log('jWallet Lite mock API is running');
  console.log(`  Local:            ${base('localhost')}`);
  console.log(`  Android emulator: ${base('10.0.2.2')}`);
  for (const ip of lanAddresses()) console.log(`  Physical device:  ${base(ip)}`);
  console.log(`  Response delay:   ${config.responseDelayMs}ms | Dev routes: ${config.enableDevRoutes}`);
});
