import { defineConfig } from 'vite';
import { authPlugin } from './server/auth.mjs';
import { aiPlugin } from './server/ai.mjs';

export default defineConfig({
  base: process.env.VITE_BASE || '/',
  plugins: [authPlugin(), aiPlugin()],
  server: {
    host: '0.0.0.0',
    port: 5173,
  },
  preview: {
    host: '0.0.0.0',
    port: 4173,
  },
  build: {
    target: 'es2020',
    chunkSizeWarningLimit: 900,
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (id.includes('node_modules/three')) return 'three';
          return undefined;
        },
      },
    },
  },
});
