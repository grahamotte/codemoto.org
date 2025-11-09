import * as React from "react";

import { cn } from "../lib/cn";

function Cols({
  className,
  children,
  gap = 4,
  ...props
}: React.PropsWithChildren<React.ComponentProps<"div"> & { gap?: number }>) {
  let gapClass = "gap-4";
  switch (gap) {
    case 0:
      gapClass = "gap-0";
      break;
    case 1:
      gapClass = "gap-1";
      break;
    case 2:
      gapClass = "gap-2";
      break;
    case 3:
      gapClass = "gap-3";
      break;
    case 4:
      gapClass = "gap-4";
      break;
    case 5:
      gapClass = "gap-5";
      break;
    case 6:
      gapClass = "gap-6";
      break;
    case 7:
      gapClass = "gap-7";
      break;
    case 8:
      gapClass = "gap-8";
  }

  return (
    <div
      data-slot="cols"
      className={cn("flex flex-row items-center", gapClass, className)}
      {...props}
    >
      {children}
    </div>
  );
}

export { Cols };
