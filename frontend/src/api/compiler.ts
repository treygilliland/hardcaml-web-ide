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

export interface CompileOptions {
  circuit: string;
  interface: string;
  test: string;
  input?: string;
  circuitFilename?: string;
  interfaceFilename?: string;
  timeoutSeconds?: number;
}

/**
 * Compile and run HardCaml code
 */
export async function compileCode(
  options: CompileOptions
): Promise<CompileResult> {
  const {
    circuit,
    interface: interface_,
    test,
    input,
    circuitFilename = "circuit.ml",
    interfaceFilename = "circuit.mli",
    timeoutSeconds = 60,
  } = options;

  // Inject input data into the test file if provided
  const processedTest = input ? injectInputData(test, input) : test;

  const request: CompileRequest = {
    files: {
      [circuitFilename]: circuit,
      [interfaceFilename]: interface_,
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

    if (response.status === 429) {
      return {
        success: false,
        error_type: "rate_limit",
        error_message:
          "Too many builds. Please wait a minute before trying again.",
      };
    }

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
