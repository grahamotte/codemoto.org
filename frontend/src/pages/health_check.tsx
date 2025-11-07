import { req } from "@/lib/req";
import { useEffect, useState } from "react";
import { z } from "zod";

export const HealthCheck = () => {
  const [data, setData] = useState<{
    frontendTime: string;
    backendTime: string;
    databaseTime: string;
  } | null>(null);

  useEffect(() => {
    req({
      url: "/api/health_check",
      params: { frontendTime: new Date().toISOString() },
      schema: z.object({
        frontendTime: z.string(),
        backendTime: z.string(),
        databaseTime: z.string(),
      }),
    })
      .then((data) => setData(data))
      .catch((error) => console.error(error));
  }, []);

  return (
    <div className="h-screen w-screen flex items-center justify-center bg-black">
      <div className="flex flex-col gap-4 w-80 h-80 items-center justify-center text-center font-mono bg-black text-white border border-white border-2">
        <div>F = {data?.frontendTime}</div>
        <div>B = {data?.backendTime}</div>
        <div>D = {data?.databaseTime}</div>
      </div>
    </div>
  );
};
