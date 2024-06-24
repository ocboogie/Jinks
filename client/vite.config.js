import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [svelte()],
  server: {
    proxy: {
      "/api": {
        target: "http://localhost:4000",
        rewrite: path => path.replace(/^\/api/, ""),
        changeOrigin: true,
        secure: false,
        ws: true
      }
    }
  }
});
