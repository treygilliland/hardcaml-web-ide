import { PostHogProvider } from "posthog-js/react";
import type { ReactNode } from "react";
import { analyticsConfig, isBrowser } from "@/config";

interface AnalyticsProviderProps {
  children: ReactNode;
}

export function AnalyticsProvider({ children }: AnalyticsProviderProps) {
  // Check if we're in browser (client-side only)
  if (!isBrowser) {
    return <>{children}</>;
  }

  // If analytics is disabled, just render children
  if (!analyticsConfig.enabled) {
    return <>{children}</>;
  }

  // Check if we have a valid API key
  if (!analyticsConfig.apiKey || analyticsConfig.apiKey === "phc_default_key") {
    return <>{children}</>;
  }

  return (
    <PostHogProvider
      apiKey={analyticsConfig.apiKey}
      options={{
        api_host: analyticsConfig.host,
        person_profiles: "identified_only",
        capture_pageview: true,
        capture_pageleave: true,
        capture_exceptions: true,
        debug: analyticsConfig.debug,
      }}
    >
      {children}
    </PostHogProvider>
  );
}
