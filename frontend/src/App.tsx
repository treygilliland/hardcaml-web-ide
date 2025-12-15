import { useState } from "react";
import { OcamlEditor } from "./components/OcamlEditor";
import { examples, getExample, type ExampleKey } from "./examples";
import "./App.css";

interface CompileResult {
  success: boolean;
  output?: string;
  waveform?: string;
  error_type?: string;
  error_message?: string;
  compile_time_ms?: number;
  run_time_ms?: number;
}

type TabType = "circuit" | "interface" | "test";

function App() {
  const [activeTab, setActiveTab] = useState<TabType>("circuit");
  const [circuit, setCircuit] = useState(examples.counter.circuit);
  const [interface_, setInterface] = useState(examples.counter.interface);
  const [test, setTest] = useState(examples.counter.test);
  const [result, setResult] = useState<CompileResult | null>(null);
  const [loading, setLoading] = useState(false);

  const loadExample = (key: string) => {
    const example = getExample(key);
    if (example) {
      setCircuit(example.circuit);
      setInterface(example.interface);
      setTest(example.test);
      setResult(null);
    }
  };

  const compile = async () => {
    setLoading(true);
    setResult(null);

    try {
      const response = await fetch("/compile", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          files: {
            "circuit.ml": circuit,
            "circuit.mli": interface_,
            "test.ml": test,
          },
          timeout_seconds: 60,
        }),
      });

      const data: CompileResult = await response.json();
      setResult(data);
    } catch (error) {
      setResult({
        success: false,
        error_type: "network_error",
        error_message: error instanceof Error ? error.message : "Unknown error",
      });
    }

    setLoading(false);
  };

  const getCurrentValue = () => {
    switch (activeTab) {
      case "circuit":
        return circuit;
      case "interface":
        return interface_;
      case "test":
        return test;
    }
  };

  const handleEditorChange = (value: string) => {
    switch (activeTab) {
      case "circuit":
        setCircuit(value);
        break;
      case "interface":
        setInterface(value);
        break;
      case "test":
        setTest(value);
        break;
    }
  };

  return (
    <div className="app">
      {/* Header */}
      <header className="header">
        <h1>🔧 Hardcaml Web IDE</h1>
        <div className="header-actions">
          <select
            className="example-selector"
            onChange={(e) => loadExample(e.target.value)}
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
          <button
            className="btn btn-primary"
            onClick={compile}
            disabled={loading}
          >
            {loading ? "⏳ Compiling..." : "▶ Run"}
          </button>
          {result && (
            <span className={`status ${result.success ? "success" : "error"}`}>
              {result.success ? "✓ Success" : "✗ Error"}
            </span>
          )}
          {result?.compile_time_ms && (
            <span className="timing">
              {result.compile_time_ms}ms compile
              {result.run_time_ms && ` + ${result.run_time_ms}ms run`}
            </span>
          )}
        </div>
      </header>

      {/* Main content */}
      <main className="main-content">
        {/* Editor panel */}
        <div className="editor-panel">
          <div className="tabs">
            <button
              className={`tab ${activeTab === "circuit" ? "active" : ""}`}
              onClick={() => setActiveTab("circuit")}
            >
              circuit.ml
            </button>
            <button
              className={`tab ${activeTab === "interface" ? "active" : ""}`}
              onClick={() => setActiveTab("interface")}
            >
              circuit.mli
            </button>
            <button
              className={`tab ${activeTab === "test" ? "active" : ""}`}
              onClick={() => setActiveTab("test")}
            >
              test.ml
            </button>
          </div>
          <div className="editor-container">
            <OcamlEditor
              key={activeTab}
              value={getCurrentValue()}
              onChange={handleEditorChange}
            />
          </div>
        </div>

        {/* Output panel - split into two rows */}
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
