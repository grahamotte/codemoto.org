import { req } from "@/lib/req";
import { useEffect, useMemo, useRef, useState } from "react";
import { z } from "zod";

const useInterval = (callback: () => void, delay: number | null) => {
  const savedCallback = useRef<(() => void) | undefined>(undefined);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    const tick = () => {
      savedCallback.current?.();
    };

    if (delay !== null) {
      const id = setInterval(tick, delay);
      return () => clearInterval(id);
    }
  }, [delay]);
};

export const Hc = () => {
  const [data, setData] = useState<{
    frontendTime: string;
    backendTime: string;
    databaseTime: string;
  } | null>(null);
  const [error, setError] = useState<string | null>(null);

  const stars = useMemo(() => {
    return Array.from({ length: 150 }, () => ({
      left: Math.random() * 100,
      top: Math.random() * 100,
      size: Math.random() * 3 + 1,
      delay: Math.random() * 5,
      duration: Math.random() * 3 + 2,
      opacity: Math.random() * 0.8 + 0.2,
      twinkle: Math.random() * 3 + 1,
    }));
  }, []);

  const nebulas = useMemo(() => {
    return Array.from({ length: 4 }, () => ({
      left: Math.random() * 100,
      top: Math.random() * 100,
      size: Math.random() * 200 + 300,
      color: ["purple", "blue", "pink", "cyan"][Math.floor(Math.random() * 4)],
      delay: Math.random() * 2,
    }));
  }, []);

  const orbs = useMemo(() => {
    return Array.from({ length: 8 }, () => ({
      left: Math.random() * 100,
      top: Math.random() * 100,
      size: Math.random() * 60 + 40,
      color: ["cyan", "purple", "pink", "blue"][Math.floor(Math.random() * 4)],
      delay: Math.random() * 3,
    }));
  }, []);

  const fetchData = () => {
    req({
      url: "/api/noop/hc",
      params: { frontendTime: new Date().toISOString() },
      schema: z.object({
        frontendTime: z.string(),
        backendTime: z.string(),
        databaseTime: z.string(),
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

  useEffect(() => {
    fetchData();
  }, []);

  useInterval(() => {
    fetchData();
  }, 1000);

  if (!data && !error) return null;

  return (
    <>
      <style>{`
        @keyframes float-gentle {
          0%, 100% { transform: translateY(0px); }
          50% { transform: translateY(-8px); }
        }
        @keyframes card-float {
          0%, 100% { transform: translate(0px, 0px) rotate(0deg) scale(1); }
          25% { transform: translate(15px, -20px) rotate(2deg) scale(1.05); }
          50% { transform: translate(-10px, -15px) rotate(-1.5deg) scale(1.03); }
          75% { transform: translate(-15px, -25px) rotate(1.5deg) scale(1.06); }
        }
        @keyframes border-pulse {
          0%, 100% { border-color: rgba(255, 255, 255, 0.1); box-shadow: 0 0 20px rgba(139, 92, 246, 0.3); }
          50% { border-color: rgba(255, 255, 255, 0.4); box-shadow: 0 0 40px rgba(139, 92, 246, 0.6); }
        }
        @keyframes radial-pulse {
          0%, 100% { opacity: 0.5; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.1); }
        }
        @keyframes pulse-glow-text {
          0%, 100% { opacity: 0.8; filter: brightness(1) drop-shadow(0 0 4px currentColor); }
          50% { opacity: 1; filter: brightness(1.4) drop-shadow(0 0 8px currentColor); }
        }
        @keyframes title-rotate {
          0%, 100% { transform: rotate(0deg) scale(1); }
          25% { transform: rotate(1deg) scale(1.05); }
          50% { transform: rotate(0deg) scale(1.1); }
          75% { transform: rotate(-1deg) scale(1.05); }
        }
        @keyframes corner-glow {
          0%, 100% { opacity: 0.6; filter: brightness(1); }
          50% { opacity: 1; filter: brightness(1.5); }
        }
        @keyframes shimmer-sweep {
          0% { background-position: -200% center; opacity: 0.2; }
          50% { opacity: 0.4; }
          100% { background-position: 200% center; opacity: 0.2; }
        }
        @keyframes orb-float {
          0%, 100% { transform: translate(0, 0) scale(1); opacity: 0.3; }
          33% { transform: translate(20px, -20px) scale(1.2); opacity: 0.5; }
          66% { transform: translate(-15px, 15px) scale(0.8); opacity: 0.4; }
        }
        @keyframes text-bounce {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-3px); }
        }
        @keyframes star-twinkle {
          0%, 100% { opacity: 0.3; transform: scale(1); filter: brightness(1); }
          50% { opacity: 1; transform: scale(1.3); filter: brightness(1.5); }
        }
        @keyframes error-shake {
          0%, 100% { transform: translate(0, 0) rotate(0deg); }
          10%, 30%, 50%, 70%, 90% { transform: translate(-4px, -4px) rotate(-1deg); }
          20%, 40%, 60%, 80% { transform: translate(4px, 4px) rotate(1deg); }
        }
        @keyframes error-pulse {
          0%, 100% { transform: scale(1); box-shadow: 0 0 30px rgba(239, 68, 68, 0.5), 0 0 60px rgba(239, 68, 68, 0.3); }
          50% { transform: scale(1.05); box-shadow: 0 0 50px rgba(239, 68, 68, 0.8), 0 0 100px rgba(239, 68, 68, 0.5); }
        }
        @keyframes error-border-pulse {
          0%, 100% { border-color: rgba(239, 68, 68, 0.5); box-shadow: 0 0 30px rgba(239, 68, 68, 0.6), inset 0 0 30px rgba(239, 68, 68, 0.2); }
          50% { border-color: rgba(239, 68, 68, 1); box-shadow: 0 0 60px rgba(239, 68, 68, 1), inset 0 0 60px rgba(239, 68, 68, 0.4); }
        }
        @keyframes error-glow-text {
          0%, 100% { opacity: 1; filter: brightness(1) drop-shadow(0 0 8px rgba(239, 68, 68, 0.8)) drop-shadow(0 0 16px rgba(239, 68, 68, 0.6)); }
          50% { opacity: 1; filter: brightness(1.5) drop-shadow(0 0 16px rgba(239, 68, 68, 1)) drop-shadow(0 0 32px rgba(239, 68, 68, 0.8)); }
        }
        @keyframes error-radial-pulse {
          0%, 100% { opacity: 0.6; transform: scale(1); }
          50% { opacity: 1; transform: scale(1.2); }
        }
        @keyframes error-shimmer {
          0% { background-position: -200% center; opacity: 0.3; }
          50% { opacity: 0.6; }
          100% { background-position: 200% center; opacity: 0.3; }
        }
        .animate-float-gentle {
          animation: float-gentle 4s ease-in-out infinite;
        }
        .animate-card-float {
          animation: card-float 6s ease-in-out infinite;
        }
        .animate-border-pulse {
          animation: border-pulse 3s ease-in-out infinite;
        }
        .animate-radial-pulse {
          animation: radial-pulse 4s ease-in-out infinite;
        }
        .animate-pulse-glow-text {
          animation: pulse-glow-text 2s ease-in-out infinite;
        }
        .animate-pulse-glow-text-delay-1 {
          animation: pulse-glow-text 2s ease-in-out infinite 0.3s;
        }
        .animate-pulse-glow-text-delay-2 {
          animation: pulse-glow-text 2s ease-in-out infinite 0.6s;
        }
        .animate-title-rotate {
          animation: title-rotate 5s ease-in-out infinite;
        }
        .animate-corner-glow {
          animation: corner-glow 2s ease-in-out infinite;
        }
        .animate-shimmer-sweep {
          background-size: 200% auto;
          animation: shimmer-sweep 6s linear infinite;
        }
        .animate-orb-float {
          animation: orb-float 8s ease-in-out infinite;
        }
        .animate-text-bounce {
          animation: text-bounce 2s ease-in-out infinite;
        }
        .animate-star-twinkle {
          animation: star-twinkle 2s ease-in-out infinite;
        }
        .animate-error-shake {
          animation: error-shake 0.5s ease-in-out infinite;
        }
        .animate-error-pulse {
          animation: error-pulse 1.5s ease-in-out infinite;
        }
        .animate-error-border-pulse {
          animation: error-border-pulse 1s ease-in-out infinite;
        }
        .animate-error-glow-text {
          animation: error-glow-text 1s ease-in-out infinite;
        }
        .animate-error-radial-pulse {
          animation: error-radial-pulse 2s ease-in-out infinite;
        }
        .animate-error-shimmer {
          background-size: 200% auto;
          animation: error-shimmer 3s linear infinite;
        }
      `}</style>
      <div className="h-screen w-screen flex items-center justify-center bg-black relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-indigo-950/50 via-black to-purple-950/50" />
        <div className="absolute inset-0">
          {nebulas.map((nebula, i) => (
            <div
              key={i}
              className={`absolute rounded-full blur-[120px] opacity-20 animate-nebula-float ${
                nebula.color === "purple"
                  ? "bg-purple-500"
                  : nebula.color === "blue"
                  ? "bg-blue-500"
                  : nebula.color === "pink"
                  ? "bg-pink-500"
                  : "bg-cyan-500"
              }`}
              style={{
                left: `${nebula.left}%`,
                top: `${nebula.top}%`,
                width: `${nebula.size}px`,
                height: `${nebula.size}px`,
                animationDelay: `${nebula.delay}s`,
              }}
            />
          ))}
        </div>
        <div className="absolute inset-0">
          {stars.map((star, i) => (
            <div
              key={i}
              className="absolute rounded-full bg-white animate-star-twinkle"
              style={{
                left: `${star.left}%`,
                top: `${star.top}%`,
                width: `${star.size}px`,
                height: `${star.size}px`,
                opacity: star.opacity,
                animationDelay: `${star.delay}s`,
                animationDuration: `${star.twinkle}s`,
                boxShadow: `0 0 ${star.size * 2}px rgba(255, 255, 255, ${
                  star.opacity
                })`,
              }}
            />
          ))}
        </div>
        <div className="absolute inset-0 opacity-20">
          <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_50%_50%,transparent_0%,rgba(139,92,246,0.1)_100%)]" />
        </div>
        <div className="absolute inset-0">
          {orbs.map((orb, i) => (
            <div
              key={i}
              className={`absolute rounded-full blur-[60px] opacity-30 animate-orb-float ${
                orb.color === "purple"
                  ? "bg-purple-400"
                  : orb.color === "blue"
                  ? "bg-blue-400"
                  : orb.color === "pink"
                  ? "bg-pink-400"
                  : "bg-cyan-400"
              }`}
              style={{
                left: `${orb.left}%`,
                top: `${orb.top}%`,
                width: `${orb.size}px`,
                height: `${orb.size}px`,
                animationDelay: `${orb.delay}s`,
              }}
            />
          ))}
        </div>
        <div
          className={`relative z-10 flex flex-col gap-6 w-80 h-80 items-center justify-center text-center font-mono animate-card-entrance ${
            error
              ? "animate-error-shake animate-error-pulse"
              : "animate-card-float"
          }`}
        >
          <div
            className={`absolute inset-0 rounded-[2rem] blur-xl ${
              error
                ? "bg-gradient-to-r from-red-500 via-red-600 to-red-500 opacity-80"
                : "bg-gradient-to-r from-cyan-400 via-purple-500 to-pink-500 opacity-60 animate-gradient-rotate"
            }`}
          />
          <div
            className={`absolute inset-[3px] rounded-[calc(2rem-3px)] bg-black/80 backdrop-blur-md shadow-2xl border ${
              error
                ? "border-red-500/80 animate-error-border-pulse"
                : "border-white/10 animate-border-pulse"
            }`}
          />
          <div
            className={`absolute inset-[3px] rounded-[calc(2rem-3px)] ${
              error
                ? "bg-[radial-gradient(circle_at_center,rgba(239,68,68,0.3)_0%,transparent_70%)] animate-error-radial-pulse"
                : "bg-[radial-gradient(circle_at_center,rgba(139,92,246,0.1)_0%,transparent_70%)] animate-radial-pulse"
            }`}
          />
          <div
            className={`absolute inset-[3px] rounded-[calc(2rem-3px)] bg-gradient-to-r from-transparent ${
              error
                ? "via-red-500/40 to-transparent animate-error-shimmer"
                : "via-cyan-500/20 to-transparent animate-shimmer-sweep"
            }`}
          />
          {error && (
            <div className="absolute inset-[3px] rounded-[calc(2rem-3px)] overflow-hidden pointer-events-none">
              <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-red-500 animate-error-glow-text" />
              <div
                className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-red-500 animate-error-glow-text"
                style={{ animationDelay: "0.25s" }}
              />
              <div
                className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-red-500 animate-error-glow-text"
                style={{ animationDelay: "0.5s" }}
              />
              <div
                className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-red-500 animate-error-glow-text"
                style={{ animationDelay: "0.75s" }}
              />
            </div>
          )}
          {!error && (
            <>
              <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-cyan-400 rounded-tl-[2rem] animate-corner-pulse animate-corner-glow" />
              <div
                className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-purple-400 rounded-tr-[2rem] animate-corner-pulse-delay-1 animate-corner-glow"
                style={{ animationDelay: "0.5s" }}
              />
              <div
                className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-pink-400 rounded-bl-[2rem] animate-corner-pulse-delay-2 animate-corner-glow"
                style={{ animationDelay: "1s" }}
              />
              <div
                className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-cyan-400 rounded-br-[2rem] animate-corner-pulse-delay-3 animate-corner-glow"
                style={{ animationDelay: "1.5s" }}
              />
            </>
          )}
          <div className="relative z-10 flex flex-col gap-6 items-center justify-center w-full h-full px-4 py-4">
            <div
              className={`text-4xl font-bold bg-clip-text text-transparent animate-text-shimmer animate-title-entrance ${
                error
                  ? "bg-gradient-to-r from-red-500 via-red-600 to-red-500 drop-shadow-[0_0_8px_rgba(239,68,68,0.8)]"
                  : "bg-gradient-to-r from-cyan-400 via-purple-400 to-pink-400 drop-shadow-[0_0_8px_rgba(139,92,246,0.5)]"
              }`}
            >
              {import.meta.env.VITE_TITLE}
            </div>
            {error ? (
              <div className="flex flex-col gap-3 items-center">
                <div className="text-2xl font-bold text-red-500 animate-error-glow-text">
                  ⚠️ ERROR ⚠️
                </div>
                <div className="text-sm text-red-400 font-semibold tracking-wider animate-error-glow-text px-4">
                  {error}
                </div>
              </div>
            ) : (
              <div className="flex flex-col gap-4 w-full">
                <div className="text-xs text-cyan-300 font-semibold tracking-wider animate-fade-in drop-shadow-[0_0_4px_rgba(34,211,238,0.5)] animate-pulse-glow-text">
                  {data?.frontendTime}
                </div>
                <div className="text-xs text-purple-300 font-semibold tracking-wider animate-fade-in-delay-1 drop-shadow-[0_0_4px_rgba(196,181,253,0.5)] animate-pulse-glow-text-delay-1">
                  {data?.backendTime}
                </div>
                <div className="text-xs text-pink-300 font-semibold tracking-wider animate-fade-in-delay-2 drop-shadow-[0_0_4px_rgba(244,114,182,0.5)] animate-pulse-glow-text-delay-2">
                  {data?.databaseTime}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
};
