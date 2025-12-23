import { useState, useCallback } from "react";
import { compileCode, type CompileOptions } from "../api/compiler";
import type { CompileResult } from "../types/types";

export interface UseCompilerReturn {
  result: CompileResult | null;
  loading: boolean;
  compile: (options: CompileOptions) => Promise<void>;
  clearResult: () => void;
}

export function useCompiler(): UseCompilerReturn {
  const [result, setResult] = useState<CompileResult | null>(null);
  const [loading, setLoading] = useState(false);

  const compile = useCallback(async (options: CompileOptions) => {
    setLoading(true);
    setResult(null);
    const data = await compileCode(options);
    setResult(data);
    setLoading(false);
  }, []);

  const clearResult = useCallback(() => {
    setResult(null);
  }, []);

  return { result, loading, compile, clearResult };
}

