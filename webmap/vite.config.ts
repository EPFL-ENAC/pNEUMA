import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vite'
import vuetify from 'vite-plugin-vuetify'

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    proxy: {
      '^/data.*': {
        target: 'http://127.0.0.1:8000/data',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/data/, '')
      }
    }
  },
  plugins: [vue(), vuetify()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  base: '/'
})
