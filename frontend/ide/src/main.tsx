import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "@ide/App";
import { AnalyticsProvider } from "@ide/providers/AnalyticsProvider";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <AnalyticsProvider>
      <App />
    </AnalyticsProvider>
  </StrictMode>
);
