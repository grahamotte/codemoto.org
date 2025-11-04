import { ArrowUp } from "lucide-react";
import { useEffect, useState } from "react";
import { cn } from "../lib/cn";

export const BackToTopButton = () => {
  const [isVisible, setIsVisible] = useState(false);

  // Generate random color for the button
  const [buttonDeg] = useState(Math.floor(Math.random() * 360) + 1);
  const buttonBgColor = `oklch(1 0.04 ${buttonDeg}deg)`;
  const iconColor = `oklch(0.7 0.25 ${buttonDeg}deg)`;

  const scrollToTop = () => {
    const rootElement = document.getElementById("root");
    if (rootElement) {
      rootElement.scrollTo({ top: 0, behavior: "smooth" });
    }
  };

  useEffect(() => {
    const rootElement = document.getElementById("root");

    const handleScroll = () => {
      if (rootElement) {
        const threshold = 200; // Show button after scrolling 200px
        if (rootElement.scrollTop > threshold) {
          setIsVisible(true);
        } else {
          setIsVisible(false);
        }
      } else {
        // Fallback or error handling if #root isn't found
        setIsVisible(false);
      }
    };

    if (rootElement) {
      // Initial check
      handleScroll();
      rootElement.addEventListener("scroll", handleScroll);
    }

    // Cleanup listener on component unmount
    return () => {
      if (rootElement) {
        rootElement.removeEventListener("scroll", handleScroll);
      }
    };
  }, []); // Empty dependency array ensures this runs only on mount and unmount

  return (
    <button
      onClick={scrollToTop}
      className={cn(
        "fixed bottom-4 p-2 rounded-full shadow-lg z-50 group cursor-pointer",
        "transition-opacity duration-300 ease-in-out",
        "left-1/2 -translate-x-1/2 md:left-auto md:right-4 md:translate-x-0",
        isVisible ? "opacity-100" : "opacity-0 pointer-events-none"
      )}
      style={{ backgroundColor: buttonBgColor }}
      aria-label="Scroll back to top"
    >
      <ArrowUp size={24} color={iconColor} />
    </button>
  );
};
