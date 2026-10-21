import 'dotenv/config';

import { z } from 'zod';

const environmentSchema = z.object({
  DATABASE_URL: z.string().min(1),
  HOST: z.string().default('127.0.0.1'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  SQLITE_BUSY_TIMEOUT_MS: z.coerce.number().int().min(1).max(60_000).default(5_000),
});

export type AppConfig = z.infer<typeof environmentSchema>;

export function loadConfig(environment: NodeJS.ProcessEnv = process.env): AppConfig {
  return environmentSchema.parse(environment);
}
