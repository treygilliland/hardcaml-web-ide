import { useState } from "react";
import { OcamlEditor } from "./components/OcamlEditor";
import {
  examples,
  getExample,
  getExamplesByCategory,
  categoryLabels,
  type ExampleCategory,
  type ExampleKey,
} from "./examples/examples";
import { useEditorState } from "./hooks/useEditorState";
import { compileCode } from "./api/compiler";
import { TABS, INPUT_TAB, type CompileResult } from "./types/types";
import "./App.css";

const DEFAULT_EXAMPLE: ExampleKey = "counter";

function App() {
  const {
    activeTab,
    setActiveTab,
    files,
    currentValue,
    updateCurrentFile,
    loadExample,
    hasInput,
  } = useEditorState(examples[DEFAULT_EXAMPLE]);

  const examplesByCategory = getExamplesByCategory();

  const [currentExampleKey, setCurrentExampleKey] =
    useState<ExampleKey>(DEFAULT_EXAMPLE);
  const [result, setResult] = useState<CompileResult | null>(null);
  const [loading, setLoading] = useState(false);

  const handleLoadExample = (key: string) => {
    const example = getExample(key);
    if (example) {
      setCurrentExampleKey(key as ExampleKey);
      loadExample(example);
      setResult(null);
    }
  };

  const handleCompile = async () => {
    setLoading(true);
    setResult(null);

    const data = await compileCode(
      files.circuit,
      files.interface,
      files.test,
      hasInput ? files.input : undefined
    );
    setResult(data);

    setLoading(false);
  };

  const formatTiming = () => {
    if (!result?.compile_time_ms) return null;
    let text = `${result.compile_time_ms}ms compile`;
    if (result.run_time_ms) text += ` + ${result.run_time_ms}ms run`;
    return text;
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

  return (
    <div className="app">
      {/* Header */}
      <header className="header">
        <h1>🔧 Hardcaml Web IDE</h1>
        <div className="header-actions">
          <select
            className="example-selector"
            onChange={(e) => handleLoadExample(e.target.value)}
            value={currentExampleKey}
          >
            {(Object.keys(categoryLabels) as ExampleCategory[]).map(
              (category) => (
                <optgroup key={category} label={categoryLabels[category]}>
                  {examplesByCategory[category].map(({ key, example }) => (
                    <option key={key} value={key}>
                      {example.name}
                    </option>
                  ))}
                </optgroup>
              )
            )}
          </select>
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
                {tab.label}
              </button>
            ))}
            {hasInput && (
              <button
                key={INPUT_TAB.id}
                className={`tab ${activeTab === INPUT_TAB.id ? "active" : ""}`}
                onClick={() => setActiveTab(INPUT_TAB.id)}
              >
                {INPUT_TAB.label}
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
              {result?.waveform_vcd && (
                <button
                  className="btn btn-download"
                  onClick={handleDownloadVcd}
                  title="Download VCD file for use in GTKWave or other waveform viewers"
                >
                  ⬇ Download VCD
                </button>
              )}
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
                {result && (
                  <span
                    className={`status-badge ${
                      result.success ? "success" : "error"
                    }`}
                  >
                    {result.success ? "✓ Success" : "✗ Error"}
                  </span>
                )}
                {formatTiming() && (
                  <span className="timing-badge">{formatTiming()}</span>
                )}
              </div>
            </div>
            <div className="output-content">
              {result?.success && result?.output && (
                <div className="result-output">{result.output}</div>
              )}
              {result && !result.success && result.error_message && (
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
