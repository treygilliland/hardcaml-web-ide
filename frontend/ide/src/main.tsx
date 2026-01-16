import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "@ide/App";
import { AnalyticsProvider } from "@ide/providers/AnalyticsProvider";

const root = createRoot(document.getElementById("root")!);

root.render(
  <StrictMode>
    <AnalyticsProvider>
      <App />
    </AnalyticsProvider>
  </StrictMode>
);
