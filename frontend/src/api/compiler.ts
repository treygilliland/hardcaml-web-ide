/**
 * API client for the HardCaml compiler service
 */

import type { CompileResult, CompileRequest } from "../types/types";

const API_BASE = "";

/**
 * Inject input data into the test file by replacing the INPUT_DATA placeholder
 * The placeholder {|INPUT_DATA|} uses OCaml's quoted string syntax, so we need
 * to preserve the delimiters and only replace the inner content.
 */
function injectInputData(test: string, input: string): string {
  // Replace only INPUT_DATA, keeping the {| and |} delimiters intact
  return test.replace("INPUT_DATA", input);
}

/**
 * Compile and run HardCaml code
 */
export async function compileCode(
  circuit: string,
  interface_: string,
  test: string,
  input?: string,
  timeoutSeconds = 60
): Promise<CompileResult> {
  // Inject input data into the test file if provided
  const processedTest = input ? injectInputData(test, input) : test;

  const request: CompileRequest = {
    files: {
      "circuit.ml": circuit,
      "circuit.mli": interface_,
      "test.ml": processedTest,
    },
    timeout_seconds: timeoutSeconds,
  };

  // Add input.txt if provided
  if (input) {
    request.files["input.txt"] = input;
  }

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
