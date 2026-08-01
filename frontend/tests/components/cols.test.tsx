import { Cols } from "@/components/cols";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, test } from "vitest";

describe("Cols", () => {
  test.each([ 0, 1, 2, 3, 4, 5, 6, 7, 8 ])("renders gap %i", (gap) => {
    expect(renderToStaticMarkup(<Cols gap={gap} />)).toContain(`gap-${gap}`);
  });

  test("renders defaults, children, classes, and HTML props", () => {
    const html = renderToStaticMarkup(<Cols className="custom" id="cols">Columns</Cols>);

    expect(html).toContain('data-slot="cols"');
    expect(html).toContain('class="flex flex-row items-center gap-4 custom"');
    expect(html).toContain('id="cols">Columns');
  });
});
