import { useState } from "react";
import { OcamlEditor } from "./components/OcamlEditor";
import { examples, getExample, type ExampleKey } from "./examples/examples";
import { useEditorState } from "./hooks/useEditorState";
import { compileCode } from "./api/compiler";
import { TABS, type CompileResult } from "./types/types";
import "./App.css";

function App() {
  const {
    activeTab,
    setActiveTab,
    files,
    currentValue,
    updateCurrentFile,
    loadExample,
  } = useEditorState(examples.counter);

  const [result, setResult] = useState<CompileResult | null>(null);
  const [loading, setLoading] = useState(false);

  const handleLoadExample = (key: string) => {
    const example = getExample(key);
    if (example) {
      loadExample(example);
      setResult(null);
    }
  };

  const handleCompile = async () => {
    setLoading(true);
    setResult(null);

    const data = await compileCode(files.circuit, files.interface, files.test);
    setResult(data);

    setLoading(false);
  };

  const formatTiming = () => {
    if (!result?.compile_time_ms) return null;
    let text = `${result.compile_time_ms}ms compile`;
    if (result.run_time_ms) text += ` + ${result.run_time_ms}ms run`;
    return text;
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
            defaultValue=""
          >
            <option value="" disabled>
              Load Example...
            </option>
            {(Object.keys(examples) as ExampleKey[]).map((key) => (
              <option key={key} value={key}>
                {examples[key].name}
              </option>
            ))}
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
