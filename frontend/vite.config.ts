import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Proxy API calls to backend during development
    proxy: {
      "/compile": "http://localhost:8000",
      "/health": "http://localhost:8000",
      "/examples": "http://localhost:8000",
    },
  },
  build: {
    // Output to dist folder
    outDir: "dist",
    // Generate source maps for debugging
    sourcemap: false,
  },
});
