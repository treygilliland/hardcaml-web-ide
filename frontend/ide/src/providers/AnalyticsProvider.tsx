import { PostHogProvider } from "posthog-js/react";
import type { ReactNode } from "react";

interface AnalyticsProviderProps {
  children: ReactNode;
}

export function AnalyticsProvider({ children }: AnalyticsProviderProps) {
  const isLocalhost =
    window.location.hostname === "localhost" ||
    window.location.hostname === "127.0.0.1";
  const disabled =
    import.meta.env.VITE_POSTHOG_ENABLED === "false" ||
    (isLocalhost && import.meta.env.VITE_POSTHOG_ENABLED !== "true");
  const posthogKey =
    import.meta.env.VITE_PUBLIC_POSTHOG_KEY || "phc_default_key";
  const posthogHost =
    import.meta.env.VITE_PUBLIC_POSTHOG_HOST || "https://us.i.posthog.com";

  if (disabled) {
    return <>{children}</>;
  }

  return (
    <PostHogProvider
      apiKey={posthogKey}
      options={{
        api_host: posthogHost,
        defaults: "2025-05-24",
        capture_exceptions: true,
        debug: import.meta.env.MODE === "development",
      }}
    >
      {children}
    </PostHogProvider>
  );
}
