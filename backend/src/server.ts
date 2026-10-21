import { createApp } from './app.js';
import { loadConfig } from './config.js';
import { checkDatabaseReady, configureDatabase, createDatabase } from './database.js';

const config = loadConfig();
const database = createDatabase();

await configureDatabase(database, config);

const app = createApp(() => checkDatabaseReady(database));
const server = app.listen(config.PORT, config.HOST, () => {
  console.info(`TAGAME API listening on http://${config.HOST}:${config.PORT}`);
});

async function shutdown(): Promise<void> {
  server.close(async () => {
    await database.$disconnect();
    process.exit(0);
  });
}

process.once('SIGINT', shutdown);
process.once('SIGTERM', shutdown);
