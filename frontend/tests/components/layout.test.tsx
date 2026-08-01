import { Cols } from "@/components/cols";
import { Rows } from "@/components/rows";
import { renderToStaticMarkup } from "react-dom/server";
import { describe, expect, test } from "vitest";

describe("layout components", () => {
  test("renders columns with their gap and custom classes", () => {
    const html = renderToStaticMarkup(<Cols gap={2} className="custom" />);

    expect(html).toContain('data-slot="cols"');
    expect(html).toContain('class="flex flex-row items-center gap-2 custom"');
  });

  test("renders rows with their gap and children", () => {
    const html = renderToStaticMarkup(<Rows gap={8}>Content</Rows>);

    expect(html).toContain('data-slot="rows"');
    expect(html).toContain('class="flex flex-col gap-8"');
    expect(html).toContain("Content");
  });
});
