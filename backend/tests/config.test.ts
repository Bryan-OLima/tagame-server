import { describe, expect, it } from 'vitest';

import { loadConfig } from '../src/config.js';

describe('configuration', () => {
  it('accepts an explicit local SQLite database configuration', () => {
    const config = loadConfig({ DATABASE_URL: 'file:./tagame.db' });

    expect(config.DATABASE_URL).toBe('file:./tagame.db');
  });
});
