globalThis.fetch = () => {
  throw new Error("Network calls must be stubbed in tests");
};
