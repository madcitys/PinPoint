import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'

function resolveApiProxyTarget(apiBaseUrl) {
  if (!apiBaseUrl) {
    return 'http://localhost:4000'
  }

  try {
    return new URL(apiBaseUrl).origin
  } catch {
    return 'http://localhost:4000'
  }
}

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const proxyTarget = resolveApiProxyTarget(env.VITE_API_BASE_URL)

  return {
    plugins: [vue()],
    server: {
      proxy: {
        '/api': {
          target: proxyTarget,
          changeOrigin: true,
        },
      },
    },
  }
})
