import {
  Angry,
  DotIcon,
  Ghost,
  LoaderIcon,
  TrafficConeIcon,
} from "lucide-react";

export type JobStatus = "running" | "passed" | "failed" | "noop" | "blocked";

export const StatusIcon = ({
  status,
  size = 16,
  strokeWidth = 1.5,
}: {
  status: JobStatus;
  size?: number;
  strokeWidth?: number;
}) => {
  if (status === "passed")
    return (
      <DotIcon
        size={size}
        strokeWidth={strokeWidth + 2}
        fill="currentColor"
        className="flex-none"
      />
    );
  if (status === "noop")
    return (
      <DotIcon
        size={size}
        strokeWidth={strokeWidth}
        fill="currentColor"
        className="flex-none opacity-50"
      />
    );
  if (status === "blocked")
    return (
      <TrafficConeIcon
        size={size}
        strokeWidth={strokeWidth}
        className="flex-none"
      />
    );
  if (status === "failed")
    return (
      <Angry size={size} strokeWidth={strokeWidth} className="flex-none" />
    );
  if (status === "running") {
    return (
      <LoaderIcon
        size={size}
        strokeWidth={strokeWidth}
        className="animate-spin flex-none"
      />
    );
  }

  return <Ghost size={size} strokeWidth={strokeWidth} className="flex-none" />;
};
