import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import { execSync } from "child_process";
import path from "path";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    proxy: {
      "/api": {
        target: process.env.API_URL,
      },
    },
  },
  define: {
    VITE_RELEASE: JSON.stringify(
      execSync("git rev-parse HEAD").toString().trim()
    ),
  },
  build: {
    chunkSizeWarningLimit: 100000000,
  },
});
