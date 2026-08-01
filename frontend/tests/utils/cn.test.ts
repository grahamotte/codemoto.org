import { cn } from "@/utils/cn";
import { expect, test } from "vitest";

test("merges conditional and conflicting classes", () => {
  expect(cn("px-2", false && "hidden", [ "block", "px-4" ])).toBe("block px-4");
});
