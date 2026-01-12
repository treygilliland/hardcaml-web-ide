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

export interface CompileRequest {
  files: Record<string, string>;
  timeout_seconds?: number;
}
