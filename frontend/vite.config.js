import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";
import { execSync } from "child_process";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    proxy: {
      "/api": {
        target: `http://localhost:${process.env.API_PORT}`,
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
