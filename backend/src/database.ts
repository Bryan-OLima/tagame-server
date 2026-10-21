import { PrismaClient } from '@prisma/client';

import type { AppConfig } from './config.js';

export type Database = Pick<PrismaClient, '$disconnect' | '$executeRawUnsafe' | '$queryRawUnsafe'>;

export function createDatabase(): PrismaClient {
  return new PrismaClient();
}

export async function configureDatabase(database: Database, config: Pick<AppConfig, 'SQLITE_BUSY_TIMEOUT_MS'>): Promise<void> {
  await database.$queryRawUnsafe('PRAGMA journal_mode = WAL');
  await database.$queryRawUnsafe('PRAGMA foreign_keys = ON');
  await database.$queryRawUnsafe(`PRAGMA busy_timeout = ${config.SQLITE_BUSY_TIMEOUT_MS}`);
}

export async function checkDatabaseReady(database: Database): Promise<boolean> {
  try {
    const foreignKeys = await database.$queryRawUnsafe('PRAGMA foreign_keys') as Array<{ foreign_keys: number }>;
    const busyTimeout = await database.$queryRawUnsafe('PRAGMA busy_timeout') as Array<{ timeout: number }>;
    await database.$queryRawUnsafe('SELECT 1');

    return Number(foreignKeys[0]?.foreign_keys) === 1 && Number(busyTimeout[0]?.timeout ?? 0) > 0;
  } catch {
    return false;
  }
}
