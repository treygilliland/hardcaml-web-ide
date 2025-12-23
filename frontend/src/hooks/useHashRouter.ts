import { useState, useEffect, useCallback } from "react";
import { examples, getExample, type ExampleKey } from "../examples/hardcaml-examples";

const DEFAULT_EXAMPLE: ExampleKey = "counter";

export function getInitialExampleKey(): ExampleKey {
  const hash = window.location.hash.slice(1);
  if (hash && examples[hash as ExampleKey]) {
    return hash as ExampleKey;
  }
  return DEFAULT_EXAMPLE;
}

export interface UseHashRouterReturn {
  exampleKey: ExampleKey;
  setExampleKey: (key: ExampleKey) => void;
}

export function useHashRouter(
  onExampleChange?: (key: ExampleKey) => void
): UseHashRouterReturn {
  const [exampleKey, setExampleKeyState] = useState<ExampleKey>(getInitialExampleKey);

  useEffect(() => {
    window.location.hash = exampleKey;
  }, [exampleKey]);

  useEffect(() => {
    const handleHashChange = () => {
      const key = getInitialExampleKey();
      if (key !== exampleKey) {
        const example = getExample(key);
        if (example) {
          setExampleKeyState(key);
          onExampleChange?.(key);
        }
      }
    };

    window.addEventListener("hashchange", handleHashChange);
    return () => window.removeEventListener("hashchange", handleHashChange);
  }, [exampleKey, onExampleChange]);

  const setExampleKey = useCallback((key: ExampleKey) => {
    setExampleKeyState(key);
    onExampleChange?.(key);
  }, [onExampleChange]);

  return { exampleKey, setExampleKey };
}

