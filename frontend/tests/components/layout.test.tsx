import { Cols } from "@/components/cols";
import { Rows } from "@/components/rows";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, test } from "vitest";

describe("layout components", () => {
  test.each([ 0, 1, 2, 3, 4, 5, 6, 7, 8 ])("renders gap %i", (gap) => {
    const cols = renderToStaticMarkup(<Cols gap={gap} />);
    const rows = renderToStaticMarkup(<Rows gap={gap} />);

    expect(cols).toContain(`gap-${gap}`);
    expect(rows).toContain(`gap-${gap}`);
  });

  test("renders defaults, children, classes, and HTML props", () => {
    const cols = renderToStaticMarkup(<Cols className="custom" id="cols">Columns</Cols>);
    const rows = renderToStaticMarkup(<Rows className="custom" id="rows">Rows</Rows>);

    expect(cols).toContain('data-slot="cols"');
    expect(cols).toContain('class="flex flex-row items-center gap-4 custom"');
    expect(cols).toContain('id="cols">Columns');
    expect(rows).toContain('data-slot="rows"');
    expect(rows).toContain('class="flex flex-col gap-4 custom"');
    expect(rows).toContain('id="rows">Rows');
  });
});
