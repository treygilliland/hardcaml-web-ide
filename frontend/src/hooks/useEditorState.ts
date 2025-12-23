/**
 * Custom hook for managing editor state with localStorage persistence
 */

import { useState, useCallback, useEffect, useRef } from "react";
import type { TabType } from "../types/types";
import type {
  HardcamlExample,
  ExampleKey,
} from "../examples/hardcaml-examples";

const STORAGE_PREFIX = "hardcaml-ide";
const SAVE_DEBOUNCE_MS = 500;

export interface EditorFiles {
  circuit: string;
  interface: string;
  test: string;
  input: string;
}

export interface EditorFilenames {
  circuit: string;
  interface: string;
}

export interface UseEditorStateReturn {
  activeTab: TabType;
  setActiveTab: (tab: TabType) => void;
  files: EditorFiles;
  filenames: EditorFilenames;
  currentValue: string;
  updateCurrentFile: (value: string) => void;
  loadExample: (example: HardcamlExample, key: ExampleKey) => void;
  hasInput: boolean;
  hasChanges: boolean;
  resetToTemplate: () => void;
  resetAll: () => void;
}

function getStorageKey(exampleKey: ExampleKey): string {
  return `${STORAGE_PREFIX}:${exampleKey}`;
}

function getSavedFiles(exampleKey: ExampleKey): EditorFiles | null {
  try {
    const stored = localStorage.getItem(getStorageKey(exampleKey));
    return stored ? JSON.parse(stored) : null;
  } catch {
    return null;
  }
}

function saveFiles(exampleKey: ExampleKey, files: EditorFiles): void {
  try {
    localStorage.setItem(getStorageKey(exampleKey), JSON.stringify(files));
  } catch {
    // localStorage full or unavailable
  }
}

function clearSavedFiles(exampleKey: ExampleKey): void {
  localStorage.removeItem(getStorageKey(exampleKey));
}

function clearAllSavedFiles(): void {
  Object.keys(localStorage)
    .filter((k) => k.startsWith(STORAGE_PREFIX))
    .forEach((k) => localStorage.removeItem(k));
}

function filesEqual(a: EditorFiles, b: EditorFiles): boolean {
  return (
    a.circuit === b.circuit &&
    a.interface === b.interface &&
    a.test === b.test &&
    a.input === b.input
  );
}

function getTemplateFiles(example: HardcamlExample): EditorFiles {
  return {
    circuit: example.circuit,
    interface: example.interface,
    test: example.test,
    input: example.input ?? "",
  };
}

export function useEditorState(
  initialExample: HardcamlExample,
  initialKey: ExampleKey
): UseEditorStateReturn {
  const [exampleKey, setExampleKey] = useState<ExampleKey>(initialKey);
  const [template, setTemplate] = useState<EditorFiles>(() =>
    getTemplateFiles(initialExample)
  );
  const [activeTab, setActiveTab] = useState<TabType>("circuit");
  const [files, setFiles] = useState<EditorFiles>(() => {
    const saved = getSavedFiles(initialKey);
    return saved ?? getTemplateFiles(initialExample);
  });
  const [filenames, setFilenames] = useState<EditorFilenames>({
    circuit: initialExample.circuitFilename ?? "circuit.ml",
    interface: initialExample.interfaceFilename ?? "circuit.mli",
  });
  const [hasInput, setHasInput] = useState<boolean>(!!initialExample.input);

  const saveTimeoutRef = useRef<number | null>(null);

  // Debounced save to localStorage
  useEffect(() => {
    if (saveTimeoutRef.current) {
      clearTimeout(saveTimeoutRef.current);
    }
    saveTimeoutRef.current = window.setTimeout(() => {
      if (!filesEqual(files, template)) {
        saveFiles(exampleKey, files);
      } else {
        clearSavedFiles(exampleKey);
      }
    }, SAVE_DEBOUNCE_MS);

    return () => {
      if (saveTimeoutRef.current) {
        clearTimeout(saveTimeoutRef.current);
      }
    };
  }, [files, exampleKey, template]);

  const hasChanges = !filesEqual(files, template);

  const getFileKey = (tab: TabType): keyof EditorFiles => {
    if (tab === "interface") return "interface";
    return tab;
  };

  const currentValue = files[getFileKey(activeTab)];

  const updateCurrentFile = useCallback(
    (value: string) => {
      setFiles((prev) => ({
        ...prev,
        [getFileKey(activeTab)]: value,
      }));
    },
    [activeTab]
  );

  const loadExample = useCallback(
    (example: HardcamlExample, key: ExampleKey) => {
      const templateFiles = getTemplateFiles(example);
      const saved = getSavedFiles(key);

      setExampleKey(key);
      setTemplate(templateFiles);
      setFiles(saved ?? templateFiles);
      setFilenames({
        circuit: example.circuitFilename ?? "circuit.ml",
        interface: example.interfaceFilename ?? "circuit.mli",
      });
      setHasInput(!!example.input);
      setActiveTab("circuit");
    },
    []
  );

  const resetToTemplate = useCallback(() => {
    clearSavedFiles(exampleKey);
    setFiles(template);
  }, [exampleKey, template]);

  const resetAll = useCallback(() => {
    clearAllSavedFiles();
    setFiles(template);
  }, [template]);

  return {
    activeTab,
    setActiveTab,
    files,
    filenames,
    currentValue,
    updateCurrentFile,
    loadExample,
    hasInput,
    hasChanges,
    resetToTemplate,
    resetAll,
  };
}
