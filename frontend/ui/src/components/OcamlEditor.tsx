import { loader } from "@monaco-editor/react";
import { initializeOcamlLanguage } from "@ui/languages/ocaml";
import { CodeEditor, type CodeEditorProps } from "@ui/components/CodeEditor";

if (typeof window !== 'undefined') {
  loader.init().then(initializeOcamlLanguage);
}

export interface OcamlEditorProps extends Omit<CodeEditorProps, "language"> {}

export function OcamlEditor(props: OcamlEditorProps) {
  return <CodeEditor {...props} language="ocaml" />;
}
