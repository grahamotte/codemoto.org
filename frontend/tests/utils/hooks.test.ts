import { useInterval, useLocalStorageState } from "@/utils/hooks";
import { act, renderHook } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, test, vi } from "vitest";

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
  vi.stubGlobal("localStorage", storage);
  localStorage.clear();
});

afterEach(() => {
  vi.useRealTimers();
  vi.unstubAllGlobals();
});

describe("useInterval", () => {
  test("runs immediately, repeats with the latest callback, and clears on unmount", () => {
    vi.useFakeTimers();
    const first = vi.fn();
    const second = vi.fn();
    const { rerender, unmount } = renderHook(
      ({ callback }) => useInterval(callback, 10),
      { initialProps: { callback: first } },
    );

    expect(first).toHaveBeenCalledTimes(1);
    act(() => vi.advanceTimersByTime(20));
    expect(first).toHaveBeenCalledTimes(3);

    rerender({ callback: second });
    act(() => vi.advanceTimersByTime(10));
    expect(second).toHaveBeenCalledTimes(1);

    unmount();
    act(() => vi.advanceTimersByTime(10));
    expect(second).toHaveBeenCalledTimes(1);
  });

  test("does not schedule without a numeric delay", () => {
    vi.useFakeTimers();
    const callback = vi.fn();

    renderHook(() => useInterval(callback, undefined as unknown as number));
    act(() => vi.runAllTimers());

    expect(callback).not.toHaveBeenCalled();
  });
});

describe("useLocalStorageState", () => {
  test("uses and persists the default value", () => {
    const { result } = renderHook(() => useLocalStorageState("state", { count: 1 }));

    expect(result.current[0]).toEqual({ count: 1 });
    expect(localStorage.getItem("state")).toBe('{"count":1}');

    act(() => result.current[1]((state) => ({ count: state.count + 1 })));

    expect(result.current[0]).toEqual({ count: 2 });
    expect(localStorage.getItem("state")).toBe('{"count":2}');
  });

  test("loads an existing value", () => {
    localStorage.setItem("state", '{"count":3}');

    const { result } = renderHook(() => useLocalStorageState("state", { count: 1 }));

    expect(result.current[0]).toEqual({ count: 3 });
  });
});
