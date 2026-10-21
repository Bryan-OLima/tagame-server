import request from 'supertest';
import { describe, it } from 'vitest';

import { createApp } from '../src/app.js';

describe('health endpoints', () => {
  it('reports liveness without a database dependency', async () => {
    const app = createApp(async () => false);

    await request(app)
      .get('/health')
      .expect(200)
      .expect({ status: 'ok', service: 'tagame-api' });
  });

  it('reports database readiness when the database is available', async () => {
    const app = createApp(async () => true);

    await request(app)
      .get('/ready')
      .expect(200)
      .expect({ status: 'ready', database: 'ready' });
  });

  it('reports unavailable readiness without exposing database errors', async () => {
    const app = createApp(async () => false);

    await request(app)
      .get('/ready')
      .expect(503)
      .expect({ status: 'not_ready', database: 'unavailable' });
  });
});
