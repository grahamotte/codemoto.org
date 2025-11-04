import {
  ALargeSmall,
  AlignRight,
  ArrowDownNarrowWide,
  ArrowDownWideNarrow,
  Asterisk,
  Ban,
  Check,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  ChevronUp,
  CircleCheck,
  CircleHelp,
  Clock,
  Cookie,
  Dot,
  Download,
  Eye,
  EyeOff,
  File,
  Folder,
  Image,
  LayoutGrid,
  LayoutList,
  Minus,
  MoveDown,
  MoveLeft,
  MoveRight,
  MoveUp,
  Music,
  Pause,
  Play,
  Plus,
  Search,
  Shell,
  Shuffle,
  Sparkles,
  Square,
  Star,
  StarOff,
  ToggleLeft,
  ToggleRight,
  Video,
  VideoOff,
  X,
} from "lucide-react";

export const Icon = ({
  icon,
  className,
  style,
  size,
}: {
  icon: string;
  className?: string;
  style?: { [x: string]: string };
  size?: number;
}) => {
  size ||= 16;
  const params = { className, style, size };

  if (icon === "a-large-small") return <ALargeSmall {...params} />;
  if (icon === "asterisk") return <Asterisk {...params} />;
  if (icon === "check") return <Check {...params} />;
  if (icon === "clock") return <Clock {...params} />;
  if (icon === "cookie") return <Cookie {...params} />;
  if (icon === "down") return <MoveDown {...params} />;
  if (icon === "eye-off") return <EyeOff {...params} />;
  if (icon === "eye") return <Eye {...params} />;
  if (icon === "file") return <File {...params} />;
  if (icon === "folder") return <Folder {...params} />;
  if (icon === "image") return <Image {...params} />;
  if (icon === "left") return <MoveLeft {...params} />;
  if (icon === "magnifying-glass") return <Search {...params} />;
  if (icon === "minus") return <Minus {...params} />;
  if (icon === "move-down") return <MoveDown {...params} />;
  if (icon === "move-left") return <MoveLeft {...params} />;
  if (icon === "move-right") return <MoveRight {...params} />;
  if (icon === "move-up") return <MoveUp {...params} />;
  if (icon === "music") return <Music {...params} />;
  if (icon === "pause") return <Pause {...params} />;
  if (icon === "play") return <Play {...params} />;
  if (icon === "plus") return <Plus {...params} />;
  if (icon === "right") return <MoveRight {...params} />;
  if (icon === "shell") return <Shell {...params} />;
  if (icon === "shuffle") return <Shuffle {...params} />;
  if (icon === "sort-nw") return <ArrowDownNarrowWide {...params} />;
  if (icon === "sort-wn") return <ArrowDownWideNarrow {...params} />;
  if (icon === "square") return <Square {...params} />;
  if (icon === "star") return <Star {...params} />;
  if (icon === "toggle-off") return <ToggleLeft {...params} />;
  if (icon === "toggle-on") return <ToggleRight {...params} />;
  if (icon === "up") return <MoveUp {...params} />;
  if (icon === "video-off") return <VideoOff {...params} />;
  if (icon === "video") return <Video {...params} />;
  if (icon === "ban") return <Ban {...params} />;
  if (icon === "circle-check") return <CircleCheck {...params} />;
  if (icon === "star-off") return <StarOff {...params} />;
  if (icon === "download") return <Download {...params} />;
  if (icon === "layout-list") return <LayoutList {...params} />;
  if (icon === "layout-grid") return <LayoutGrid {...params} />;
  if (icon === "chevron-right") return <ChevronRight {...params} />;
  if (icon === "chevron-left") return <ChevronLeft {...params} />;
  if (icon === "chevron-down") return <ChevronDown {...params} />;
  if (icon === "chevron-up") return <ChevronUp {...params} />;
  if (icon === "dot") return <Dot {...params} />;
  if (icon === "align-right") return <AlignRight {...params} />;
  if (icon === "toggle-off") return <ToggleLeft {...params} />;
  if (icon === "toggle-on") return <ToggleRight {...params} />;
  if (icon === "sparkles") return <Sparkles {...params} />;
  if (icon === "x") return <X {...params} />;

  return <CircleHelp {...params} />;
};

export const FileIcon = ({
  mime,
  className,
  style,
  size,
}: {
  mime: string;
  className?: string;
  style?: { [x: string]: string };
  size?: number;
}) => {
  size ||= 16;
  mime = mime.split("/")[0];
  let icon = "file";
  if (mime === "inode") icon = "folder";
  if (mime === "image") icon = "image";
  if (mime === "video") icon = "video";
  if (mime === "audio") icon = "music";

  return <Icon icon={icon} className={className} style={style} size={size} />;
};
