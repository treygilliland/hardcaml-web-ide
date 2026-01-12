import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

const uiSrc = path.resolve(__dirname, "../ui/src");

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: [
      { find: /^@ide\/(.+)$/, replacement: path.resolve(__dirname, "src/$1") },
      { find: "@ide", replacement: path.resolve(__dirname, "src") },
      { find: /^@ui\/(.+)$/, replacement: path.resolve(uiSrc, "$1") },
      { find: "@hardcaml-examples", replacement: path.resolve(__dirname, "../../hardcaml") },
    ],
  },
  server: {
    host: true,
    watch: {
      usePolling: true,
    },
    fs: {
      allow: [".", "../ui", "../../hardcaml"],
    },
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
