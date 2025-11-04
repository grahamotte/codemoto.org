import * as Sentry from "@sentry/react";
import ReactDOM from "react-dom/client";
import { Helmet } from "react-helmet";
import { BrowserRouter, Route, Routes } from "react-router";
import Home from "./pages/home";

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
        path="/"
        element={
          <>
            <Helmet>
              <title>Home</title>
            </Helmet>

            <Home />
          </>
        }
      />
    </Routes>
  </BrowserRouter>
);
