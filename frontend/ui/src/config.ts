/**
 * Centralized configuration for the UI package.
 * All environment variables should be accessed through this file.
 */

/**
 * API configuration
 */
export const apiConfig = {
  /**
   * Base URL for the compilation API.
   * - Defaults to production API server
   * - Can be overridden via PUBLIC_API_BASE_URL env var
   */
  baseUrl: import.meta.env.PUBLIC_API_BASE_URL || "https://hardcaml.tg3.dev",
} as const;

/**
 * Get the full API URL for an endpoint
 */
export function getApiUrl(endpoint: string): string {
  const base = apiConfig.baseUrl;
  // Remove trailing slash from base if present
  const cleanBase = base.endsWith("/") ? base.slice(0, -1) : base;
  // Ensure endpoint starts with /
  const cleanEndpoint = endpoint.startsWith("/") ? endpoint : `/${endpoint}`;
  return cleanBase + cleanEndpoint;
}
