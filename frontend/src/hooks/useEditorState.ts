/**
 * Custom hook for managing editor state
 */

import { useState, useCallback } from "react";
import type { TabType } from "../types/types";
import type { HardcamlExample } from "../examples/examples";

export interface EditorFiles {
  circuit: string;
  interface: string;
  test: string;
}

export interface UseEditorStateReturn {
  /** Currently active tab */
  activeTab: TabType;
  /** Set the active tab */
  setActiveTab: (tab: TabType) => void;
  /** All editor file contents */
  files: EditorFiles;
  /** Get the current file content based on active tab */
  currentValue: string;
  /** Update the current file content */
  updateCurrentFile: (value: string) => void;
  /** Load an example into the editor */
  loadExample: (example: HardcamlExample) => void;
}

/**
 * Hook to manage the multi-file editor state
 */
export function useEditorState(
  initialExample: HardcamlExample
): UseEditorStateReturn {
  const [activeTab, setActiveTab] = useState<TabType>("circuit");
  const [files, setFiles] = useState<EditorFiles>({
    circuit: initialExample.circuit,
    interface: initialExample.interface,
    test: initialExample.test,
  });

  const currentValue =
    files[activeTab === "interface" ? "interface" : activeTab];

  const updateCurrentFile = useCallback(
    (value: string) => {
      setFiles((prev) => ({
        ...prev,
        [activeTab === "interface" ? "interface" : activeTab]: value,
      }));
    },
    [activeTab]
  );

  const loadExample = useCallback((example: HardcamlExample) => {
    setFiles({
      circuit: example.circuit,
      interface: example.interface,
      test: example.test,
    });
  }, []);

  return {
    activeTab,
    setActiveTab,
    files,
    currentValue,
    updateCurrentFile,
    loadExample,
  };
}
