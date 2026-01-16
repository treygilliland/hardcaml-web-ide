import { type ReactNode } from "react";
import posthog from "posthog-js";
import { PostHogProvider } from "@posthog/react";

/**
 * Check if we're running on localhost
 */
const isLocalhost =
  typeof window !== "undefined" &&
  (window.location.hostname === "localhost" ||
    window.location.hostname === "127.0.0.1" ||
    window.location.hostname === "");

/**
 * Check if PostHog should be enabled
 */
const isPostHogEnabled = (): boolean => {
  const explicitSetting = import.meta.env.VITE_POSTHOG_ENABLED;
  const hasKey = !!import.meta.env.VITE_PUBLIC_POSTHOG_KEY;

  // Debug logging
  const isDev = import.meta.env.MODE === "development";
  if (isDev) {
    console.log("[AnalyticsProvider] PostHog configuration check:", {
      explicitSetting,
      hasKey,
      isLocalhost,
      apiKeyPresent: !!import.meta.env.VITE_PUBLIC_POSTHOG_KEY,
      apiKeyLength: import.meta.env.VITE_PUBLIC_POSTHOG_KEY?.length || 0,
      apiKeyPreview: import.meta.env.VITE_PUBLIC_POSTHOG_KEY?.substring(0, 15) + "...",
      hostname: typeof window !== "undefined" ? window.location.hostname : "unknown",
    });
  }

  // If explicitly set to 'false', disable everywhere
  if (explicitSetting === "false") {
    if (isDev) {
      console.log("[AnalyticsProvider] PostHog disabled via VITE_POSTHOG_ENABLED=false");
    }
    return false;
  }

  // If explicitly set to 'true', enable everywhere (including localhost)
  if (explicitSetting === "true") {
    const enabled = hasKey;
    if (isDev) {
      console.log(`[AnalyticsProvider] PostHog ${enabled ? "enabled" : "disabled"} (explicitly set to true, hasKey: ${hasKey})`);
    }
    return enabled;
  }

  // Default: enabled in production (not localhost) if key is provided
  const enabled = !isLocalhost && hasKey;
  if (isDev) {
    console.log(`[AnalyticsProvider] PostHog ${enabled ? "enabled" : "disabled"} (default behavior: !isLocalhost=${!isLocalhost}, hasKey=${hasKey})`);
  }
  return enabled;
};

/**
 * Initialize PostHog if enabled
 */
const initializePostHog = (): typeof posthog | null => {
  if (!isPostHogEnabled()) {
    console.log("[AnalyticsProvider] PostHog not enabled, skipping initialization");
    return null;
  }

  const apiKey = import.meta.env.VITE_PUBLIC_POSTHOG_KEY!;
  const apiHost =
    import.meta.env.VITE_PUBLIC_POSTHOG_HOST || "https://us.i.posthog.com";

  const isDev = import.meta.env.MODE === "development";
  if (isDev) {
    console.log("[AnalyticsProvider] Initializing PostHog:", {
      apiKey: apiKey.substring(0, 15) + "...",
      apiHost,
    });
  }

  posthog.init(apiKey, {
    api_host: apiHost,
    person_profiles: "identified_only", // Only create profiles for identified users
    capture_pageview: true, // Automatically capture pageviews
    capture_pageleave: true, // Automatically capture pageleave events
    loaded: (posthog) => {
      console.log("[AnalyticsProvider] PostHog loaded successfully");
      if (isDev) {
        posthog.debug(); // Enable debug mode in development
        console.log("[AnalyticsProvider] PostHog debug mode enabled");
      }
    },
  });

  return posthog;
};

interface AnalyticsProviderProps {
  children: ReactNode;
}

/**
 * AnalyticsProvider - Wraps the app with PostHog analytics
 * Only initializes and provides PostHog when enabled
 */
export function AnalyticsProvider({ children }: AnalyticsProviderProps) {
  const posthogClient = initializePostHog();

  if (posthogClient) {
    console.log("[AnalyticsProvider] Wrapping app with PostHogProvider");
    return <PostHogProvider client={posthogClient}>{children}</PostHogProvider>;
  }

  console.log("[AnalyticsProvider] Rendering children without PostHog");
  return <>{children}</>;
}
