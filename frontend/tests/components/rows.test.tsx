import { Rows } from "@/components/rows";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, test } from "vitest";

describe("Rows", () => {
  test.each([ 0, 1, 2, 3, 4, 5, 6, 7, 8 ])("renders gap %i", (gap) => {
    expect(renderToStaticMarkup(<Rows gap={gap} />)).toContain(`gap-${gap}`);
  });

  test("renders defaults, children, classes, and HTML props", () => {
    const html = renderToStaticMarkup(<Rows className="custom" id="rows">Rows</Rows>);

    expect(html).toContain('data-slot="rows"');
    expect(html).toContain('class="flex flex-col gap-4 custom"');
    expect(html).toContain('id="rows">Rows');
  });
});
