import type { CompileResult, CompileRequest } from "@ui/shared-types/compiler";

const SESSION_ID_KEY = "hardcaml-session-id";

/**
 * Get or create a persistent session ID for this browser.
 * This enables the backend to cache build artifacts for faster incremental builds.
 */
function getSessionId(): string {
  let sessionId = localStorage.getItem(SESSION_ID_KEY);
  if (!sessionId) {
    sessionId = crypto.randomUUID();
    localStorage.setItem(SESSION_ID_KEY, sessionId);
  }
  return sessionId;
}

// Injects input data into test files that contain INPUT_DATA placeholder.
// This is necessary because Hardcaml test files need to read input from files,
// but we pass input data dynamically via the API.
function injectInputData(test: string, input: string): string {
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
  includeVcd?: boolean;
  apiBase?: string;
}

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
    includeVcd = true,
    apiBase = "",
  } = options;

  const processedTest = input ? injectInputData(test, input) : test;

  const request: CompileRequest = {
    files: {
      [circuitFilename]: circuit,
      [interfaceFilename]: interface_,
      "test.ml": processedTest,
    },
    timeout_seconds: timeoutSeconds,
    include_vcd: includeVcd,
    session_id: getSessionId(),
  };

  if (input) {
    request.files["input.txt"] = input;
  }

  try {
    const response = await fetch(`${apiBase}/compile`, {
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
