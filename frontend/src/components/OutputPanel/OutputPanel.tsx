import { useState, useCallback } from "react";
import type { CompileResult } from "../../types/types";
import styles from "./OutputPanel.module.scss";

interface OutputPanelProps {
  result: CompileResult | null;
}

export function OutputPanel({ result }: OutputPanelProps) {
  const [copiedOutput, setCopiedOutput] = useState(false);
  const [copiedWaveform, setCopiedWaveform] = useState(false);

  const copyToClipboard = useCallback(
    async (text: string, type: "output" | "waveform") => {
      try {
        await navigator.clipboard.writeText(text);
        if (type === "output") {
          setCopiedOutput(true);
          setTimeout(() => setCopiedOutput(false), 2000);
        } else {
          setCopiedWaveform(true);
          setTimeout(() => setCopiedWaveform(false), 2000);
        }
      } catch (err) {
        console.error("Failed to copy:", err);
      }
    },
    []
  );

  const handleDownloadVcd = () => {
    if (!result?.waveform_vcd) return;
    const blob = new Blob([result.waveform_vcd], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "waveform.vcd";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const formatTiming = () => {
    if (!result?.compile_time_ms) return null;
    let text = `${result.compile_time_ms}ms compile`;
    if (result.run_time_ms) text += ` + ${result.run_time_ms}ms run`;
    return text;
  };

  const getStatusBadge = () => {
    if (!result) return null;

    if (
      result.tests_passed !== undefined ||
      result.tests_failed !== undefined
    ) {
      const passed = result.tests_passed ?? 0;
      const failed = result.tests_failed ?? 0;
      const total = passed + failed;

      if (failed > 0) {
        return (
          <span className={`${styles.statusBadge} ${styles.error}`}>
            ✗ {failed}/{total} tests failed
          </span>
        );
      } else if (passed > 0) {
        return (
          <span className={`${styles.statusBadge} ${styles.success}`}>
            ✓ {passed}/{total} tests passed
          </span>
        );
      }
    }

    if (result.success) {
      return <span className={`${styles.statusBadge} ${styles.success}`}>✓ Success</span>;
    } else if (result.stage === "compile") {
      return <span className={`${styles.statusBadge} ${styles.error}`}>✗ Compile Error</span>;
    } else {
      return <span className={`${styles.statusBadge} ${styles.error}`}>✗ Error</span>;
    }
  };

  const getOutputText = () => {
    if (result?.output) return result.output;
    if (result?.error_message) return result.error_message;
    return "";
  };

  return (
    <div className={styles.panel}>
      {/* Waveform section */}
      <div className={`${styles.section} ${styles.waveformSection}`}>
        <div className={styles.sectionHeader}>
          <span className={styles.sectionTitle}>📊 Waveform</span>
          <div className={styles.sectionActions}>
            {result?.waveform && (
              <button
                className={styles.iconBtn}
                onClick={() => copyToClipboard(result.waveform!, "waveform")}
                data-tooltip={copiedWaveform ? "Copied!" : "Copy"}
              >
                {copiedWaveform ? "✓" : "⧉"}
              </button>
            )}
            {result?.waveform_vcd && (
              <button className={styles.downloadBtn} onClick={handleDownloadVcd}>
                ⬇ Download VCD
              </button>
            )}
          </div>
        </div>
        <div className={styles.waveformContent}>
          {result?.waveform || (
            <span className={styles.placeholder}>
              Run your code to see the waveform...
            </span>
          )}
        </div>
      </div>

      {/* Output section */}
      <div className={`${styles.section} ${styles.outputSection}`}>
        <div className={styles.sectionHeader}>
          <span className={styles.sectionTitle}>📝 Output</span>
          <div className={styles.sectionStatus}>
            {getOutputText() && (
              <button
                className={styles.iconBtn}
                onClick={() => copyToClipboard(getOutputText(), "output")}
                data-tooltip={copiedOutput ? "Copied!" : "Copy"}
              >
                {copiedOutput ? "✓" : "⧉"}
              </button>
            )}
            {getStatusBadge()}
            {formatTiming() && (
              <span className={styles.timingBadge}>{formatTiming()}</span>
            )}
          </div>
        </div>
        <div className={styles.outputContent}>
          {result?.output && (
            <div className={styles.resultOutput}>{result.output}</div>
          )}
          {result &&
            !result.success &&
            result.error_message &&
            result.stage === "compile" && (
              <div className={styles.errorMessage}>{result.error_message}</div>
            )}
          {!result && (
            <span className={styles.placeholder}>
              Run your code to see the output...
            </span>
          )}
          {result?.success && !result?.output && !result?.error_message && (
            <span className={styles.placeholder}>
              Compilation successful. No additional output.
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
