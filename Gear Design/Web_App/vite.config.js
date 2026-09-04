import { defineConfig } from 'vite';

export default defineConfig({
  base: './', // Enables portable relative paths for GitHub Pages, Netlify, Vercel, or local hosting
  server: {
    host: true, // Exposes server on local network (0.0.0.0)
    port: 5173
  }
});
