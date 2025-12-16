import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Enable HMR with polling for Docker
    watch: {
      usePolling: true,
    },
    // Proxy API calls to backend
    // Uses "backend" hostname when running in Docker, localhost otherwise
    proxy: {
      "/compile": {
        target: process.env.DOCKER_ENV
          ? "http://backend:8000"
          : "http://localhost:8000",
        changeOrigin: true,
      },
      "/health": {
        target: process.env.DOCKER_ENV
          ? "http://backend:8000"
          : "http://localhost:8000",
        changeOrigin: true,
      },
      "/examples": {
        target: process.env.DOCKER_ENV
          ? "http://backend:8000"
          : "http://localhost:8000",
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: "dist",
    sourcemap: false,
  },
});
