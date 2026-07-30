import { req } from "@/lib/req";
import { useEffect, useState } from "react";
import { z } from "zod";

export const Hc = () => {
  const [data, setData] = useState<{
    frontendTime: string;
    backendTime: string;
    databaseTime: string;
    hcJobFinishedAt?: string | null | undefined;
  } | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = () => {
      req({
        url: "/api/noop/hc",
        params: { frontendTime: new Date().toISOString() },
        schema: z.object({
          frontendTime: z.string(),
          backendTime: z.string(),
          databaseTime: z.string(),
          hcJobFinishedAt: z.string().nullish(),
        }),
      })
        .then((data) => {
          setData(data);
          setError(null);
        })
        .catch((error) => {
          setError(error instanceof Error ? error.message : String(error));
        });
    };

    fetchData();
    const interval = setInterval(fetchData, 1000);
    return () => clearInterval(interval);
  }, []);

  const triggerBackendError = () => {
    void req({
      method: "post",
      url: "/api/noop/error",
      schema: z.any(),
    }).catch(() => undefined);
  };

  if (!data && !error) {
    return (
      <div style={{ fontFamily: "monospace", padding: 20 }}>Loading...</div>
    );
  }

  if (error) {
    return (
      <div style={{ fontFamily: "monospace", padding: 20 }}>
        <div style={{ color: "red", fontWeight: "bold" }}>ERROR</div>
        <div style={{ color: "red" }}>{error}</div>
      </div>
    );
  }

  return (
    <div style={{ fontFamily: "monospace", padding: 20 }}>
      <div style={{ fontWeight: "bold", marginBottom: 10 }}>
        {import.meta.env.VITE_TITLE}
      </div>
      <div>Frontend&nbsp;= {data?.frontendTime}</div>
      <div>Backend&nbsp;&nbsp;= {data?.backendTime}</div>
      <div>Database&nbsp;= {data?.databaseTime}</div>
      <div>Jobs&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;= {data?.hcJobFinishedAt}</div>
      <button onClick={triggerBackendError}>Trigger backend error</button>
    </div>
  );
};
