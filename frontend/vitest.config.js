import path from "path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    alias: {
      "@": path.resolve(__dirname),
    },
  },
  test: {
    environment: "jsdom",
    fileParallelism: true,
    maxWorkers: 4,
    setupFiles: ["./tests/setup.ts"],
  },
});
