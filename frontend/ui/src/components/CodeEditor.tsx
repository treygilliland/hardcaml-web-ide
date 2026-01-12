import { useRef } from "react";
import Editor from "@monaco-editor/react";
import type { editor } from "monaco-editor";

export interface CodeEditorProps {
  value: string;
  onChange: (value: string) => void;
  language: string;
  readOnly?: boolean;
  height?: string;
  fontSize?: number;
  showMinimap?: boolean;
  theme?: "vs-dark" | "vs-light" | "hc-black";
  onMount?: (editor: editor.IStandaloneCodeEditor) => void;
  options?: editor.IStandaloneEditorConstructionOptions;
}

export function CodeEditor({
  value,
  onChange,
  language,
  readOnly = false,
  height = "100%",
  fontSize = 14,
  showMinimap = false,
  theme = "vs-dark",
  onMount,
  options,
}: CodeEditorProps) {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);

  const handleEditorChange = (newValue: string | undefined) => {
    if (newValue !== undefined) {
      onChange(newValue);
    }
  };

  const handleEditorMount = (editor: editor.IStandaloneCodeEditor) => {
    editorRef.current = editor;
    onMount?.(editor);
  };

  return (
    <Editor
      height={height}
      defaultLanguage={language}
      theme={theme}
      value={value}
      onChange={handleEditorChange}
      onMount={handleEditorMount}
      options={{
        minimap: { enabled: showMinimap },
        fontSize,
        lineNumbers: "on",
        scrollBeyondLastLine: false,
        wordWrap: "on",
        automaticLayout: true,
        readOnly,
        tabSize: 2,
        insertSpaces: true,
        renderWhitespace: "selection",
        bracketPairColorization: { enabled: true },
        guides: { bracketPairs: true, indentation: true },
        ...options,
      }}
    />
  );
}
