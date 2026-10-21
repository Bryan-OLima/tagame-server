import express from 'express';

export type ReadinessCheck = () => Promise<boolean>;

export function createApp(checkReadiness: ReadinessCheck): express.Express {
  const app = express();
  app.disable('x-powered-by');

  app.get('/health', (_request, response) => {
    response.status(200).json({ status: 'ok', service: 'tagame-api' });
  });

  app.get('/ready', async (_request, response) => {
    if (await checkReadiness()) {
      response.status(200).json({ status: 'ready', database: 'ready' });
      return;
    }

    response.status(503).json({ status: 'not_ready', database: 'unavailable' });
  });

  return app;
}
