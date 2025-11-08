/** @type {import('tailwindcss').Config} */

export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      animation: {
        "float": "float 3s ease-in-out infinite",
        "pulse-glow": "pulse-glow 2s ease-in-out infinite",
        "gradient-rotate": "gradient-rotate 3s linear infinite",
        "text-shimmer": "text-shimmer 2s linear infinite",
        "text-shimmer-reverse": "text-shimmer-reverse 2s linear infinite",
        "fade-in": "fade-in 1s ease-out",
        "fade-in-delay-1": "fade-in 1s ease-out 0.2s both",
        "fade-in-delay-2": "fade-in 1s ease-out 0.4s both",
        "scan": "scan 8s linear infinite",
        "scan-line": "scan-line 2s ease-in-out infinite",
        "corner-pulse": "corner-pulse 2s ease-in-out infinite",
        "corner-pulse-delay-1": "corner-pulse 2s ease-in-out infinite 0.5s",
        "corner-pulse-delay-2": "corner-pulse 2s ease-in-out infinite 1s",
        "corner-pulse-delay-3": "corner-pulse 2s ease-in-out infinite 1.5s",
        "card-entrance": "card-entrance 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) forwards",
        "title-entrance": "title-entrance 1s cubic-bezier(0.34, 1.56, 0.64, 1) 0.3s both",
        "star-twinkle": "star-twinkle 2s ease-in-out infinite",
        "nebula-float": "nebula-float 20s ease-in-out infinite",
        "float-gentle": "float-gentle 4s ease-in-out infinite",
        "card-float": "card-float 6s ease-in-out infinite",
        "border-pulse": "border-pulse 3s ease-in-out infinite",
        "radial-pulse": "radial-pulse 4s ease-in-out infinite",
        "pulse-glow-text": "pulse-glow-text 2s ease-in-out infinite",
        "pulse-glow-text-delay-1": "pulse-glow-text 2s ease-in-out infinite 0.3s",
        "pulse-glow-text-delay-2": "pulse-glow-text 2s ease-in-out infinite 0.6s",
      },
      keyframes: {
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-20px)" },
        },
        "pulse-glow": {
          "0%, 100%": { boxShadow: "0 0 20px rgba(139, 92, 246, 0.5), 0 0 40px rgba(59, 130, 246, 0.3)" },
          "50%": { boxShadow: "0 0 40px rgba(139, 92, 246, 0.8), 0 0 80px rgba(59, 130, 246, 0.5)" },
        },
        "gradient-rotate": {
          "0%": { transform: "rotate(0deg)" },
          "100%": { transform: "rotate(360deg)" },
        },
        "text-shimmer": {
          "0%": { backgroundPosition: "0% 50%" },
          "100%": { backgroundPosition: "200% 50%" },
        },
        "text-shimmer-reverse": {
          "0%": { backgroundPosition: "200% 50%" },
          "100%": { backgroundPosition: "0% 50%" },
        },
        "fade-in": {
          "0%": { opacity: "0", transform: "translateY(10px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        "scan": {
          "0%": { transform: "translateY(0)" },
          "100%": { transform: "translateY(4px)" },
        },
        "scan-line": {
          "0%, 100%": { opacity: "0.3", transform: "translateX(-50%) scaleX(0.5)" },
          "50%": { opacity: "1", transform: "translateX(-50%) scaleX(1)" },
        },
        "corner-pulse": {
          "0%, 100%": { opacity: "0.6", transform: "scale(1)" },
          "50%": { opacity: "1", transform: "scale(1.1)" },
        },
        "card-entrance": {
          "0%": { opacity: "0", transform: "scale(0.8) translateY(20px)" },
          "100%": { opacity: "1", transform: "scale(1) translateY(0)" },
        },
        "title-entrance": {
          "0%": { opacity: "0", transform: "scale(0.5) rotate(-5deg)" },
          "100%": { opacity: "1", transform: "scale(1) rotate(0deg)" },
        },
        "star-twinkle": {
          "0%, 100%": { opacity: "0.3", transform: "scale(1)" },
          "50%": { opacity: "1", transform: "scale(1.2)" },
        },
        "nebula-float": {
          "0%, 100%": { transform: "translate(0, 0) scale(1)" },
          "33%": { transform: "translate(30px, -30px) scale(1.1)" },
          "66%": { transform: "translate(-20px, 20px) scale(0.9)" },
        },
        "float-gentle": {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-8px)" },
        },
        "card-float": {
          "0%, 100%": { transform: "translateY(0px) rotate(0deg)" },
          "50%": { transform: "translateY(-10px) rotate(0.5deg)" },
        },
        "border-pulse": {
          "0%, 100%": { borderColor: "rgba(255, 255, 255, 0.1)", opacity: "1" },
          "50%": { borderColor: "rgba(255, 255, 255, 0.3)", opacity: "1" },
        },
        "radial-pulse": {
          "0%, 100%": { opacity: "0.5" },
          "50%": { opacity: "1" },
        },
        "pulse-glow-text": {
          "0%, 100%": { opacity: "0.8", filter: "brightness(1)" },
          "50%": { opacity: "1", filter: "brightness(1.3)" },
        },
      },
    },
  },
};
