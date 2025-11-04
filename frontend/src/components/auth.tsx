import React, { useEffect, useState } from "react";
import { z } from "zod";
import { loggedIn as initLoggedIn, login, req } from "../lib/req";

export const Auth = ({ children }: { children: React.ReactNode }) => {
  const [handle, setHandle] = useState("");
  const [password, setPassword] = useState("");
  const [loggedIn, setLoggedIn] = useState(initLoggedIn());

  const performLogin = (
    e: React.MouseEvent<HTMLButtonElement, MouseEvent> | React.KeyboardEvent
  ) => {
    e.preventDefault();

    login({
      handle: handle,
      password: password,
    })
      .then(() => setLoggedIn(true))
      .catch(() => setLoggedIn(false));
  };

  useEffect(() => {
    void req({ url: "/api/noop/lock", schema: z.any() });
  }, [loggedIn]);

  if (loggedIn) return <>{children}</>;

  return (
    <div className="flex items-center justify-center full-screen">
      <div className="h-64 w-64 p-5 flex flex-col items-center gap-5 shadow-xl rounded-xl bg-card">
        <style>{`input.center { text-align: center }`}</style>
        <input
          type="text"
          autoComplete="username"
          autoCapitalize="off"
          className="pl-4 flex-grow appearance-none border rounded-lg w-full font-semibold"
          placeholder="you know"
          onChange={(e) => setHandle(e.target.value)}
        />
        <input
          type="password"
          autoComplete="password"
          autoCapitalize="off"
          className="flex-grow text-center appearance-none border rounded-lg w-full font-semibold"
          placeholder="what you"
          onChange={(e) => setPassword(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && performLogin(e)}
        />
        <button
          type="submit"
          className="pr-4 flex-grow w-full text-right border rounded-lg bg-primary border-primary font-semibold"
          onClick={performLogin}
        >
          must do
        </button>
      </div>
    </div>
  );
};
