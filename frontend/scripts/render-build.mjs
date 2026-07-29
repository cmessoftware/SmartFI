/**
 * Render static-site build: bake runtime API URL into public/env-config.js
 * before Vite copies it to dist/.
 */
import { writeFileSync } from 'node:fs';

const apiUrl = (process.env.VITE_API_URL || '').trim();

if (!apiUrl) {
  console.warn(
    'WARNING: VITE_API_URL is empty. Set it on smartfi-frontend in Render Environment.'
  );
}

writeFileSync(
  'public/env-config.js',
  `window.ENV = { VITE_API_URL: ${JSON.stringify(apiUrl)} };\n`
);

console.log(`env-config.js written (API URL length: ${apiUrl.length})`);
