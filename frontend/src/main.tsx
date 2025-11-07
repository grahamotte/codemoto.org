import * as Sentry from "@sentry/react";
import ReactDOM from "react-dom/client";
import { Helmet } from "react-helmet";
import { BrowserRouter, Route, Routes } from "react-router";
import { HealthCheck } from "./pages/health_check";

declare const VITE_RELEASE: string;

Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN_FRONTEND,
  sendDefaultPii: true,
  release: VITE_RELEASE,
  environment: import.meta.env.VITE_ENV,
  integrations: [Sentry.captureConsoleIntegration({ levels: ["error"] })],
});

ReactDOM.createRoot(document.getElementById("root")!).render(
  <BrowserRouter>
    <Routes>
      <Route
        path="/health_check"
        element={
          <>
            <Helmet>
              <title>Health Check</title>
            </Helmet>

            <HealthCheck />
          </>
        }
      />
    </Routes>
  </BrowserRouter>
);
