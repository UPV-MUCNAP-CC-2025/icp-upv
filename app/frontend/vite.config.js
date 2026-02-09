import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  const target = env.VITE_API_BASE_URL
  if (!target) {
    console.warn('[vite] VITE_API_BASE_URL is empty - proxy disabled')
  }

  return {
    plugins: [react()],
    server: {
      proxy: target
        ? {
            '/todos': {
              target,
              changeOrigin: true,
            },
          }
        : undefined,
    },
  }
})
