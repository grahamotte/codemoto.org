import React, {
  ReactNode,
  useCallback,
  useEffect,
  useRef,
  useState,
} from "react";

interface ScrollFadeRenderProps {
  style: React.CSSProperties;
  onScroll: React.UIEventHandler<HTMLElement>;
  totalListHeightChanged: (height: number) => void;
}

interface ScrollFadeContainerProps {
  children: (props: ScrollFadeRenderProps) => ReactNode;
  className?: string;
  fadeHeightPx?: number; // Optional: Allow customizing fade height
}

export const ScrollFadeContainer: React.FC<ScrollFadeContainerProps> = ({
  children,
  className,
  fadeHeightPx = 20, // Default fade height
}) => {
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const [scrollHeight, setScrollHeight] = useState(0);
  const [maskStyle, setMaskStyle] = useState<React.CSSProperties>({});

  const handleScroll = useCallback(
    (e: React.UIEvent<HTMLElement>) => {
      const el = e.currentTarget;
      const wrapperEl = scrollContainerRef.current;
      if (!el || !wrapperEl) return;

      const tolerance = 1;
      const fadeHeight = `${fadeHeightPx}px`;

      const scrollTop = el.scrollTop;
      const clientHeight = wrapperEl.clientHeight;

      const isScrollable = scrollHeight > clientHeight + tolerance;
      const isAtTop = scrollTop <= tolerance;
      const isAtBottom =
        Math.abs(scrollHeight - clientHeight - scrollTop) <= tolerance;

      let newMaskImage = "none";

      if (isScrollable) {
        if (isAtTop) {
          newMaskImage = `linear-gradient(to bottom, black 0px, black calc(100% - ${fadeHeight}), transparent)`;
        } else if (isAtBottom) {
          newMaskImage = `linear-gradient(to bottom, transparent, black ${fadeHeight}, black 100%)`;
        } else {
          newMaskImage = `linear-gradient(to bottom, transparent, black ${fadeHeight}, black calc(100% - ${fadeHeight}), transparent)`;
        }
      }

      setMaskStyle((prevStyle) => {
        if (prevStyle.maskImage === newMaskImage) return prevStyle;
        return {
          maskImage: newMaskImage,
          WebkitMaskImage: newMaskImage,
        };
      });
    },
    [scrollHeight, fadeHeightPx]
  );

  const handleTotalListHeightChanged = useCallback((height: number) => {
    setScrollHeight(height);
  }, []);

  useEffect(() => {
    const wrapperEl = scrollContainerRef.current;
    if (!wrapperEl) {
      setMaskStyle({});
      return;
    }

    const scrollerEl = wrapperEl.querySelector<HTMLElement>(
      '[data-virtuoso-scroller="true"]'
    );

    const calculateInitialScroll = (scroller: HTMLElement | null) => {
      if (scroller) {
        const initialScrollTop = scroller.scrollTop;
        const clientHeight = wrapperEl.clientHeight;

        const tolerance = 1;
        const fadeHeight = `${fadeHeightPx}px`;
        const isScrollable = scrollHeight > clientHeight + tolerance;
        const isAtTop = initialScrollTop <= tolerance;
        const isAtBottom =
          Math.abs(scrollHeight - clientHeight - initialScrollTop) <= tolerance;

        let newMaskImage = "none";
        if (isScrollable) {
          if (isAtTop) {
            newMaskImage = `linear-gradient(to bottom, black 0px, black calc(100% - ${fadeHeight}), transparent)`;
          } else if (isAtBottom) {
            newMaskImage = `linear-gradient(to bottom, transparent, black ${fadeHeight}, black 100%)`;
          } else {
            newMaskImage = `linear-gradient(to bottom, transparent, black ${fadeHeight}, black calc(100% - ${fadeHeight}), transparent)`;
          }
        }
        setMaskStyle({
          maskImage: newMaskImage,
          WebkitMaskImage: newMaskImage,
        });
      } else {
        setMaskStyle({});
      }
    };

    calculateInitialScroll(scrollerEl);
  }, [scrollHeight, fadeHeightPx]);

  const scrollFadeProps: ScrollFadeRenderProps = {
    style: maskStyle,
    onScroll: handleScroll,
    totalListHeightChanged: handleTotalListHeightChanged,
  };

  return (
    <div ref={scrollContainerRef} className={className}>
      {children(scrollFadeProps)}
    </div>
  );
};
