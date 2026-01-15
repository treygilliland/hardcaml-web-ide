import { useEffect, useRef } from "react";
import { createRoot, type Root } from "react-dom/client";
import App from "@ide/App";
import { AnalyticsProvider } from "./AnalyticsProvider";
// CSS imports - using path aliases for maintainability
import "@ide/index.css";
import "@ide/App.css";

export function IDE() {
  const containerRef = useRef<HTMLDivElement>(null);
  const rootRef = useRef<Root | null>(null);

  useEffect(() => {
    if (containerRef.current && !rootRef.current) {
      try {
        rootRef.current = createRoot(containerRef.current);
        rootRef.current.render(
          <AnalyticsProvider>
            <App />
          </AnalyticsProvider>
        );
      } catch (error) {
        console.error("Failed to mount IDE:", error);
        // Display error message in the container
        if (containerRef.current) {
          containerRef.current.innerHTML = `
            <div style="padding: 20px; color: #e74c3c; font-family: sans-serif;">
              <h2>Failed to load IDE</h2>
              <p>An error occurred while initializing the IDE. Please refresh the page to try again.</p>
              <details style="margin-top: 10px;">
                <summary style="cursor: pointer;">Error details</summary>
                <pre style="margin-top: 10px; padding: 10px; background: #f5f5f5; overflow: auto;">${
                  error instanceof Error ? error.message : String(error)
                }</pre>
              </details>
            </div>
          `;
        }
      }
    }

    return () => {
      if (rootRef.current) {
        try {
          rootRef.current.unmount();
        } catch (error) {
          console.error("Error unmounting IDE:", error);
        }
        rootRef.current = null;
      }
    };
  }, []);

  return <div ref={containerRef} id="root" />;
}
