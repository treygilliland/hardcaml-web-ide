/**
 * API client for the HardCaml compiler service
 */

import type { CompileResult, CompileRequest } from "../types/types";

const API_BASE = "";

/**
 * Compile and run HardCaml code
 */
export async function compileCode(
  circuit: string,
  interface_: string,
  test: string,
  timeoutSeconds = 60
): Promise<CompileResult> {
  const request: CompileRequest = {
    files: {
      "circuit.ml": circuit,
      "circuit.mli": interface_,
      "test.ml": test,
    },
    timeout_seconds: timeoutSeconds,
  };

  try {
    const response = await fetch(`${API_BASE}/compile`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(request),
    });

    if (!response.ok) {
      return {
        success: false,
        error_type: "http_error",
        error_message: `HTTP ${response.status}: ${response.statusText}`,
      };
    }

    return await response.json();
  } catch (error) {
    return {
      success: false,
      error_type: "network_error",
      error_message: error instanceof Error ? error.message : "Unknown error",
    };
  }
}
