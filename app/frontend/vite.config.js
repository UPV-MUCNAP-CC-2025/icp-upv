import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/todos': {
        target: 'http://localstack:4566/restapis/g99vdf0lwk/dev/_user_request_',
        changeOrigin: true
      }
    }
  }
})