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
  waveform_vcd?: string;
  error_type?: string;
  error_message?: string;
  stage?: string;
  compile_time_ms?: number;
  run_time_ms?: number;
  tests_passed?: number;
  tests_failed?: number;
}

/**
 * Files sent to the compiler
 */
export interface CompileRequest {
  files: Record<string, string>;
  timeout_seconds?: number;
}

/**
 * Editor tab types
 */
export type TabType = "circuit" | "interface" | "test" | "input";

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

export const INPUT_TAB: TabConfig = {
  id: "input",
  label: "input.txt",
  filename: "input.txt",
};
