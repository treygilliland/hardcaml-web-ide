import { useCallback, useState, useEffect } from "react";
import { Header } from "./components/Header/Header";
import { EditorPanel } from "./components/EditorPanel/EditorPanel";
import { OutputPanel } from "./components/OutputPanel/OutputPanel";
import { Toast } from "./components/Toast/Toast";
import {
  examples,
  getExample,
  type ExampleKey,
} from "./examples/hardcaml-examples";
import { useEditorState } from "./hooks/useEditorState";
import { useCompiler } from "./hooks/useCompiler";
import { useHashRouter, getInitialExampleKey } from "./hooks/useHashRouter";
import "./App.css";

const initialKey = getInitialExampleKey();

function App() {
  const editor = useEditorState(examples[initialKey], initialKey);
  const compiler = useCompiler();
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  useEffect(() => {
    if (compiler.result?.error_type === "rate_limit") {
      setToastMessage(
        compiler.result.error_message || "Rate limit exceeded. Please wait."
      );
    }
  }, [compiler.result]);

  const handleExampleChange = useCallback(
    (key: ExampleKey) => {
      const example = getExample(key);
      if (example) {
        editor.loadExample(example, key);
        compiler.clearResult();
      }
    },
    [editor, compiler]
  );

  const { exampleKey, setExampleKey } = useHashRouter(handleExampleChange);

  const handleRun = () => {
    compiler.compile({
      circuit: editor.files.circuit,
      interface: editor.files.interface,
      test: editor.files.test,
      input: editor.hasInput ? editor.files.input : undefined,
      circuitFilename: editor.filenames.circuit,
      interfaceFilename: editor.filenames.interface,
    });
  };

  const handleReset = () => {
    editor.resetToTemplate();
    compiler.clearResult();
  };

  const handleResetAll = () => {
    editor.resetAll();
    compiler.clearResult();
  };

  return (
    <div className="app">
      <Header
        exampleKey={exampleKey}
        onExampleChange={setExampleKey}
        onResetAll={handleResetAll}
      />
      <main className="main-content">
        <EditorPanel
          activeTab={editor.activeTab}
          onTabChange={editor.setActiveTab}
          files={editor.files}
          filenames={editor.filenames}
          currentValue={editor.currentValue}
          onFileChange={editor.updateCurrentFile}
          hasInput={editor.hasInput}
          hasChanges={editor.hasChanges}
          onReset={handleReset}
          onRun={handleRun}
          loading={compiler.loading}
        />
        <OutputPanel result={compiler.result} />
      </main>
      {toastMessage && (
        <Toast
          message={toastMessage}
          type="warning"
          onDismiss={() => setToastMessage(null)}
        />
      )}
    </div>
  );
}

export default App;
