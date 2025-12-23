import { useState, useEffect, useCallback } from "react";
import { OcamlEditor } from "./components/OcamlEditor";
import { ExampleSelector } from "./components/ExampleSelector";
import {
  examples,
  getExample,
  getExamplesByCategory,
  type ExampleKey,
} from "./examples/hardcaml-examples";
import { useEditorState } from "./hooks/useEditorState";
import { compileCode } from "./api/compiler";
import { TABS, INPUT_TAB, type CompileResult } from "./types/types";
import "./App.css";

const DEFAULT_EXAMPLE: ExampleKey = "counter";

function getExampleFromHash(): ExampleKey {
  const hash = window.location.hash.slice(1);
  if (hash && examples[hash as ExampleKey]) {
    return hash as ExampleKey;
  }
  return DEFAULT_EXAMPLE;
}

function App() {
  const initialExample = getExampleFromHash();

  const {
    activeTab,
    setActiveTab,
    files,
    filenames,
    currentValue,
    updateCurrentFile,
    loadExample,
    hasInput,
  } = useEditorState(examples[initialExample]);

  const examplesByCategory = getExamplesByCategory();

  const [currentExampleKey, setCurrentExampleKey] =
    useState<ExampleKey>(initialExample);
  const [result, setResult] = useState<CompileResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [copiedOutput, setCopiedOutput] = useState(false);
  const [copiedWaveform, setCopiedWaveform] = useState(false);

  // Sync URL hash with current example
  useEffect(() => {
    window.location.hash = currentExampleKey;
  }, [currentExampleKey]);

  // Handle browser back/forward
  useEffect(() => {
    const handleHashChange = () => {
      const key = getExampleFromHash();
      if (key !== currentExampleKey) {
        const example = getExample(key);
        if (example) {
          setCurrentExampleKey(key);
          loadExample(example);
          setResult(null);
        }
      }
    };

    window.addEventListener("hashchange", handleHashChange);
    return () => window.removeEventListener("hashchange", handleHashChange);
  }, [currentExampleKey, loadExample]);

  const handleLoadExample = (key: ExampleKey) => {
    const example = getExample(key);
    if (example) {
      setCurrentExampleKey(key);
      loadExample(example);
      setResult(null);
    }
  };

  const handleCompile = async () => {
    setLoading(true);
    setResult(null);

    const data = await compileCode({
      circuit: files.circuit,
      interface: files.interface,
      test: files.test,
      input: hasInput ? files.input : undefined,
      circuitFilename: filenames.circuit,
      interfaceFilename: filenames.interface,
    });
    setResult(data);

    setLoading(false);
  };

  const getTabLabel = (tabId: string): string => {
    if (tabId === "circuit") return filenames.circuit;
    if (tabId === "interface") return filenames.interface;
    if (tabId === "test") return "test.ml";
    if (tabId === "input") return "input.txt";
    return tabId;
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
          <span className="status-badge error">
            ✗ {failed}/{total} tests failed
          </span>
        );
      } else if (passed > 0) {
        return (
          <span className="status-badge success">
            ✓ {passed}/{total} tests passed
          </span>
        );
      }
    }

    if (result.success) {
      return <span className="status-badge success">✓ Success</span>;
    } else if (result.stage === "compile") {
      return <span className="status-badge error">✗ Compile Error</span>;
    } else {
      return <span className="status-badge error">✗ Error</span>;
    }
  };

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

  const getOutputText = () => {
    if (result?.output) return result.output;
    if (result?.error_message) return result.error_message;
    return "";
  };

  return (
    <div className="app">
      {/* Header */}
      <header className="header">
        <h1>🔧 Hardcaml Web IDE</h1>
        <div className="header-actions">
          <ExampleSelector
            value={currentExampleKey}
            examplesByCategory={examplesByCategory}
            onChange={handleLoadExample}
          />
        </div>
      </header>

      {/* Main content */}
      <main className="main-content">
        {/* Editor panel */}
        <div className="editor-panel">
          <div className="tabs">
            {TABS.map((tab) => (
              <button
                key={tab.id}
                className={`tab ${activeTab === tab.id ? "active" : ""}`}
                onClick={() => setActiveTab(tab.id)}
              >
                {getTabLabel(tab.id)}
              </button>
            ))}
            {hasInput && (
              <button
                key={INPUT_TAB.id}
                className={`tab ${activeTab === INPUT_TAB.id ? "active" : ""}`}
                onClick={() => setActiveTab(INPUT_TAB.id)}
              >
                {getTabLabel(INPUT_TAB.id)}
              </button>
            )}
          </div>
          <div className="editor-container">
            <OcamlEditor
              key={activeTab}
              value={currentValue}
              onChange={updateCurrentFile}
            />
          </div>
          <div className="editor-toolbar">
            <button
              className="btn btn-run"
              onClick={handleCompile}
              disabled={loading}
            >
              {loading ? "⏳ Compiling..." : "▶ Run"}
            </button>
          </div>
        </div>

        {/* Output panel */}
        <div className="output-panel">
          {/* Waveform section */}
          <div className="output-section waveform-section">
            <div className="section-header">
              <span className="section-title">📊 Waveform</span>
              <div className="section-actions">
                {result?.waveform && (
                  <button
                    className="btn btn-icon"
                    onClick={() =>
                      copyToClipboard(result.waveform!, "waveform")
                    }
                    data-tooltip={copiedWaveform ? "Copied!" : "Copy"}
                  >
                    {copiedWaveform ? "✓" : "⧉"}
                  </button>
                )}
                {result?.waveform_vcd && (
                  <button
                    className="btn btn-download"
                    onClick={handleDownloadVcd}
                  >
                    ⬇ Download VCD
                  </button>
                )}
              </div>
            </div>
            <div className="waveform-content">
              {result?.waveform || (
                <span className="placeholder">
                  Run your code to see the waveform...
                </span>
              )}
            </div>
          </div>

          {/* Output section */}
          <div className="output-section output-log-section">
            <div className="section-header">
              <span className="section-title">📝 Output</span>
              <div className="section-status">
                {getOutputText() && (
                  <button
                    className="btn btn-icon"
                    onClick={() => copyToClipboard(getOutputText(), "output")}
                    data-tooltip={copiedOutput ? "Copied!" : "Copy"}
                  >
                    {copiedOutput ? "✓" : "⧉"}
                  </button>
                )}
                {getStatusBadge()}
                {formatTiming() && (
                  <span className="timing-badge">{formatTiming()}</span>
                )}
              </div>
            </div>
            <div className="output-content">
              {result?.output && (
                <div className="result-output">{result.output}</div>
              )}
              {result &&
                !result.success &&
                result.error_message &&
                result.stage === "compile" && (
                  <div className="error-message">{result.error_message}</div>
                )}
              {!result && (
                <span className="placeholder">
                  Run your code to see the output...
                </span>
              )}
              {result?.success && !result?.output && !result?.error_message && (
                <span className="placeholder">
                  Compilation successful. No additional output.
                </span>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;
