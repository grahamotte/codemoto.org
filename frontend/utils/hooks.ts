import { Dispatch, SetStateAction, useEffect, useRef, useState } from "react";

export const useInterval = (callback: () => void, delay: number) => {
  const intervalRef = useRef(null);
  const savedCallback = useRef(callback);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    const tick = () => savedCallback.current();

    if (typeof delay === "number") {
      tick();
      intervalRef.current = window.setInterval(tick, delay) as any;
      return () => window.clearInterval(intervalRef.current as any);
    }
  }, [delay]);

  return intervalRef;
};

export function useLocalStorageState<T>(
  key: string,
  defaultValue: T
): [T, Dispatch<SetStateAction<T>>] {
  const [state, setState] = useState<T>(() => {
    const storedValue = localStorage.getItem(key);
    return !!storedValue ? (JSON.parse(storedValue) as T) : defaultValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(state));
  }, [key, state]);

  return [state, setState];
}
