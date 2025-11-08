import { req } from "@/lib/req";
import { useEffect, useMemo, useState } from "react";
import { z } from "zod";

export const Hc = () => {
  const [data, setData] = useState<{
    frontendTime: string;
    backendTime: string;
    databaseTime: string;
  } | null>(null);

  const particles = useMemo(() => {
    return Array.from({ length: 20 }, () => ({
      left: Math.random() * 100,
      top: Math.random() * 100,
      size: Math.random() * 4 + 2,
      delay: Math.random() * 5,
      duration: Math.random() * 3 + 2,
    }));
  }, []);

  useEffect(() => {
    req({
      url: "/api/noop/hc",
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

  if (!data) return null;

  return (
    <div className="h-screen w-screen flex items-center justify-center bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900 relative overflow-hidden">
      <div className="absolute inset-0">
        {particles.map((particle, i) => (
          <div
            key={i}
            className="absolute rounded-full bg-white opacity-20 animate-float"
            style={{
              left: `${particle.left}%`,
              top: `${particle.top}%`,
              width: `${particle.size}px`,
              height: `${particle.size}px`,
              animationDelay: `${particle.delay}s`,
              animationDuration: `${particle.duration}s`,
            }}
          />
        ))}
      </div>
      <div className="absolute inset-0 opacity-30">
        <div className="absolute top-0 left-0 w-full h-full bg-[linear-gradient(90deg,transparent_50%,rgba(255,255,255,0.03)_50%)] bg-[length:4px_4px] animate-scan" />
      </div>
      <div className="relative z-10 flex flex-col gap-6 w-96 h-96 items-center justify-center text-center font-mono">
        <div className="absolute inset-0 rounded-[2rem] bg-gradient-to-r from-cyan-400 via-purple-500 to-pink-500 opacity-75 blur-xl animate-gradient-rotate" />
        <div className="absolute inset-[3px] rounded-[calc(2rem-3px)] bg-gradient-to-br from-purple-950 via-blue-950 to-indigo-950 backdrop-blur-sm shadow-2xl" />
        <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-cyan-400 rounded-tl-[2rem] animate-corner-pulse" />
        <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-purple-400 rounded-tr-[2rem] animate-corner-pulse-delay-1" />
        <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-pink-400 rounded-bl-[2rem] animate-corner-pulse-delay-2" />
        <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-cyan-400 rounded-br-[2rem] animate-corner-pulse-delay-3" />
        <div className="relative z-10 flex flex-col gap-6 items-center justify-center w-full h-full">
          <div className="text-4xl font-bold bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400 bg-clip-text text-transparent animate-text-shimmer drop-shadow-[0_0_8px_rgba(139,92,246,0.5)]">
            CODE MOTO
          </div>
          <div className="flex flex-col gap-3">
            <div className="text-xs text-cyan-300 font-semibold tracking-wider animate-fade-in drop-shadow-[0_0_4px_rgba(34,211,238,0.5)]">
              {data?.frontendTime}
            </div>
            <div className="text-xs text-purple-300 font-semibold tracking-wider animate-fade-in-delay-1 drop-shadow-[0_0_4px_rgba(196,181,253,0.5)]">
              {data?.backendTime}
            </div>
            <div className="text-xs text-pink-300 font-semibold tracking-wider animate-fade-in-delay-2 drop-shadow-[0_0_4px_rgba(244,114,182,0.5)]">
              {data?.databaseTime}
            </div>
          </div>
          {/* <div className="absolute bottom-8 left-1/2 -translate-x-1/2 w-32 h-1 bg-gradient-to-r from-transparent via-cyan-400 to-transparent opacity-50 animate-scan-line" /> */}
        </div>
      </div>
    </div>
  );
};
