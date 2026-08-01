import { parsedToken, req } from "@/utils/req";
import { afterEach, beforeEach, describe, expect, test, vi } from "vitest";
import { z } from "zod";

const values = new Map<string, string>();
const storage: Storage = {
  get length() {
    return values.size;
  },
  clear: () => values.clear(),
  getItem: (key) => values.get(key) ?? null,
  key: (index) => [ ...values.keys() ][index] ?? null,
  removeItem: (key) => values.delete(key),
  setItem: (key, value) => values.set(key, value),
};

beforeEach(() => {
  storage.clear();
  vi.stubGlobal("localStorage", storage);
  vi.stubGlobal("window", { location: { origin: "https://example.com" } });
  vi.spyOn(console, "log").mockImplementation(() => undefined);
});

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

describe("parsedToken", () => {
  test("returns a current token payload", () => {
    const payload = { exp: Math.floor(Date.now() / 1000) + 60, userId: 7 };
    localStorage.setItem("jwt", `header.${btoa(JSON.stringify(payload))}.signature`);

    expect(parsedToken()).toEqual(payload);
  });

  test("rejects expired and malformed tokens", () => {
    localStorage.setItem("jwt", `header.${btoa(JSON.stringify({ exp: 0 }))}.signature`);
    expect(parsedToken()).toBeNull();

    localStorage.setItem("jwt", "invalid");
    expect(parsedToken()).toBeNull();
  });
});

describe("req", () => {
  test("serializes requests and parses responses", async () => {
    localStorage.setItem("jwt", "token");
    const fetchMock = vi.fn<typeof fetch>().mockResolvedValue(
      new Response(JSON.stringify({ item_id: 4 }), {
        headers: { "refresh-token": "refreshed" },
      }),
    );
    vi.stubGlobal("fetch", fetchMock);

    await expect(
      req({
        method: "post",
        url: "/api/items",
        params: { pageNumber: 2, ignored: null },
        data: { itemName: "Example" },
        schema: z.object({ itemId: z.number() }),
      }),
    ).resolves.toEqual({ itemId: 4 });

    const [ url, request ] = fetchMock.mock.calls[0]!;
    expect(url.toString()).toBe("https://example.com/api/items?page_number=2");
    expect(request?.method).toBe("post");
    expect(request?.body).toBe('{"item_name":"Example"}');
    expect(new Headers(request?.headers).get("Authorization")).toBe("Bearer token");
    expect(localStorage.getItem("jwt")).toBe("refreshed");
  });
});
