import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const prismaCli = fileURLToPath(new URL('../node_modules/prisma/build/index.js', import.meta.url));
const child = spawn(process.execPath, [prismaCli, 'migrate', 'deploy'], {
  env: {
    ...process.env,
    RUST_LOG: 'info',
  },
  stdio: 'inherit',
});

child.once('error', (error) => {
  console.error('Unable to start Prisma Migrate.', error);
  process.exitCode = 1;
});

child.once('exit', (code, signal) => {
  process.exitCode = code ?? (signal ? 1 : 0);
});
