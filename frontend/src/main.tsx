import ReactDOM from "react-dom/client";
import { Helmet } from "react-helmet";
import { BrowserRouter, Route, Routes } from "react-router";
import { Hc } from "./pages/hc";

const Head = ({ name, title }: { name: string; title: string }) => {
  const sizes = [512, 192, 180, 96, 32, 16];

  return (
    <Helmet>
      <title>{title}</title>
      <link rel="manifest" href={`/${name}.webmanifest`} />
      <link rel="icon" type="image/svg+xml" href={`/images/${name}.svg`} />
      {sizes.map((size) => (
        <link
          key={`apple-${size}`}
          rel="apple-touch-icon"
          sizes={`${size}x${size}`}
          href={`/images/${name}-${size}.png`}
        />
      ))}
      {sizes.map((size) => (
        <link
          key={`icon-${size}`}
          rel="icon"
          type="image/png"
          sizes={`${size}x${size}`}
          href={`/images/${name}-${size}.png`}
        />
      ))}
      <link rel="shortcut icon" href={`/images/${name}.ico`} />
    </Helmet>
  );
};

ReactDOM.createRoot(document.getElementById("root")!).render(
  <BrowserRouter>
    <Routes>
      <Route
        path="/hc"
        element={
          <>
            <Head name="codemoto" title="Health Check" />
            <Hc />
          </>
        }
      />
    </Routes>
  </BrowserRouter>,
);
