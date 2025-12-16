/**
 * Shared type definitions for the HardCaml Web IDE
 */

/**
 * Result from the compile API endpoint
 */
export interface CompileResult {
  success: boolean;
  output?: string;
  waveform?: string;
  error_type?: string;
  error_message?: string;
  compile_time_ms?: number;
  run_time_ms?: number;
}

/**
 * Files sent to the compiler
 */
export interface CompileRequest {
  files: {
    "circuit.ml": string;
    "circuit.mli": string;
    "test.ml": string;
  };
  timeout_seconds?: number;
}

/**
 * Editor tab types
 */
export type TabType = "circuit" | "interface" | "test";

/**
 * Tab configuration for the editor
 */
export interface TabConfig {
  id: TabType;
  label: string;
  filename: string;
}

export const TABS: TabConfig[] = [
  { id: "circuit", label: "circuit.ml", filename: "circuit.ml" },
  { id: "interface", label: "circuit.mli", filename: "circuit.mli" },
  { id: "test", label: "test.ml", filename: "test.ml" },
];
