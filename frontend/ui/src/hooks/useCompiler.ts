import { useState, useCallback } from "react";
import { compileCode, type CompileOptions } from "@ui/api/compileCode";
import type { CompileResult } from "@ui/shared-types/compiler";
import { apiConfig } from "@ui/config";

export interface UseCompilerOptions {
  apiBase?: string;
}

export interface UseCompilerReturn {
  result: CompileResult | null;
  loading: boolean;
  compile: (options: Omit<CompileOptions, "apiBase">) => Promise<void>;
  clearResult: () => void;
}

export function useCompiler(options: UseCompilerOptions = {}): UseCompilerReturn {
  // Use centralized config if apiBase is not provided
  const apiBase = options.apiBase ?? apiConfig.baseUrl;
  const [result, setResult] = useState<CompileResult | null>(null);
  const [loading, setLoading] = useState(false);

  const compile = useCallback(async (compileOptions: Omit<CompileOptions, "apiBase">) => {
    setLoading(true);
    setResult(null);
    const data = await compileCode({ ...compileOptions, apiBase });
    setResult(data);
    setLoading(false);
  }, [apiBase]);

  const clearResult = useCallback(() => {
    setResult(null);
  }, []);

  return { result, loading, compile, clearResult };
}
