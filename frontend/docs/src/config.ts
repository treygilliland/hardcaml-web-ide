/**
 * Centralized configuration for the docs package.
 * All environment variables should be accessed through this file.
 */

/**
 * Check if we're running in a browser environment
 */
export const isBrowser = typeof window !== "undefined";

/**
 * Check if we're running on localhost
 */
export const isLocalhost = isBrowser &&
  (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1");

/**
 * Analytics configuration (PostHog)
 */
export const analyticsConfig = {
  /**
   * PostHog API key
   */
  apiKey: import.meta.env.VITE_PUBLIC_POSTHOG_KEY || "phc_default_key",

  /**
   * PostHog host URL
   */
  host: import.meta.env.VITE_PUBLIC_POSTHOG_HOST || "https://us.i.posthog.com",

  /**
   * Whether analytics is enabled.
   * - Disabled by default on localhost (unless explicitly enabled)
   * - Can be controlled via VITE_POSTHOG_ENABLED env var
   */
  enabled: (() => {
    const explicitSetting = import.meta.env.VITE_POSTHOG_ENABLED;

    // If explicitly set to 'false', disable everywhere
    if (explicitSetting === "false") {
      return false;
    }

    // If explicitly set to 'true', enable everywhere (including localhost)
    if (explicitSetting === "true") {
      return true;
    }

    // Default: enabled in production, disabled on localhost
    return !isLocalhost;
  })(),

  /**
   * Debug mode (enabled in development)
   */
  debug: import.meta.env.MODE === "development",
} as const;

/**
 * Site configuration
 */
export const siteConfig = {
  /**
   * Production site URL
   */
  url: import.meta.env.SITE || "https://hardcaml.tg3.dev",
} as const;
