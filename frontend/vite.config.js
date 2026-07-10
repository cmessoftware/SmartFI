import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { execSync } from 'node:child_process'

function resolveCommitHash() {
  if (process.env.VITE_COMMIT_HASH) return process.env.VITE_COMMIT_HASH
  if (process.env.COMMIT_HASH) return process.env.COMMIT_HASH

  try {
    return execSync('git rev-parse --short HEAD', { stdio: ['ignore', 'pipe', 'ignore'] })
      .toString()
      .trim()
  } catch {
    return 'dev'
  }
}

const commitHash = resolveCommitHash()

// https://vitejs.dev/config/
export default defineConfig(({ command }) => ({
  plugins: [react()],
  define: {
    __COMMIT_HASH__: JSON.stringify(commitHash)
  },
  server: {
    host: '127.0.0.1',
    port: 5173,
    // Vite dev uses eval() for HMR; allow it only in local dev (not production builds).
    headers: command === 'serve' ? {
      'Content-Security-Policy': [
        "default-src 'self'",
        "script-src 'self' 'unsafe-eval' 'unsafe-inline'",
        "style-src 'self' 'unsafe-inline'",
        "img-src 'self' data: blob:",
        "connect-src 'self' http://localhost:8000 ws://localhost:5173 ws://127.0.0.1:5173",
        "font-src 'self' data:",
      ].join('; '),
    } : undefined,
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000',
        changeOrigin: true,
      }
    }
  }
}))
