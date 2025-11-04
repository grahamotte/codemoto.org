import { Star } from "lucide-react";
import {
  Drawer,
  DrawerContent,
  DrawerDescription,
  DrawerHeader,
  DrawerTitle,
} from "./ui/drawer";

type Props = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  restaurant: { id: string; name: string; address: string };
  reviewG: number | null;
  reviewB: number | null;
  ignored: boolean;
  onScore: (type: "G" | "B", value: number) => void;
  onIgnore: () => void;
};

function StarRow({
  value,
  onChange,
}: {
  value: number | null;
  onChange: (v: number) => void;
}) {
  // 5 stars, click left half = .5, right half = 1
  return (
    <div className="flex gap-1">
      {[1, 2, 3, 4, 5].map((i) => (
        <div
          key={i}
          className="relative cursor-pointer"
          style={{ width: 32, height: 32 }}
          onClick={(e) => {
            const rect = (e.target as HTMLElement).getBoundingClientRect();
            const x =
              e.nativeEvent instanceof MouseEvent
                ? e.nativeEvent.clientX - rect.left
                : 0;
            if (x < rect.width / 2) onChange(i - 0.5);
            else onChange(i);
          }}
        >
          <Star
            fill={
              value && value >= i
                ? "#f59e42"
                : value && value >= i - 0.5
                ? "url(#half)"
                : "none"
            }
            stroke="#f59e42"
            className="w-8 h-8"
          />
          {value && value >= i - 0.5 && value < i && (
            <div className="absolute left-0 top-0 w-1/2 h-full overflow-hidden pointer-events-none">
              <Star fill="#f59e42" stroke="#f59e42" className="w-8 h-8" />
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

export function RestaurantDrawer({
  open,
  onOpenChange,
  restaurant,
  reviewG,
  reviewB,
  ignored,
  onScore,
  onIgnore,
}: Props) {
  return (
    <Drawer open={open} onOpenChange={onOpenChange}>
      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>{restaurant.name}</DrawerTitle>
          <DrawerDescription>{restaurant.address}</DrawerDescription>
        </DrawerHeader>
        <div className="flex flex-col gap-6 p-4">
          <div>
            <div className="font-bold mb-1 text-foreground">G Score</div>
            <StarRow value={reviewG} onChange={(v) => onScore("G", v)} />
          </div>
          <div>
            <div className="font-bold mb-1 text-foreground">B Score</div>
            <StarRow value={reviewB} onChange={(v) => onScore("B", v)} />
          </div>
          <button
            className={`mt-4 px-4 py-2 rounded bg-gray-200 text-gray-700 font-semibold ${
              ignored ? "bg-red-200 text-red-700" : ""
            }`}
            onClick={onIgnore}
          >
            {ignored ? "Ignored" : "Ignore"}
          </button>
        </div>
      </DrawerContent>
    </Drawer>
  );
}
