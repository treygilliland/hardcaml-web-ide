/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_PUBLIC_POSTHOG_KEY?: string;
  readonly VITE_PUBLIC_POSTHOG_HOST?: string;
  readonly VITE_POSTHOG_ENABLED?: string;
  readonly MODE: string;
  readonly PROD: boolean;
  readonly DEV: boolean;
  readonly SSR: boolean;
  readonly PUBLIC_API_BASE_URL?: string;
  readonly SITE?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
