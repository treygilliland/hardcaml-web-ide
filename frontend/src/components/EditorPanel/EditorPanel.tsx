import { OcamlEditor } from "../OcamlEditor";
import { TABS, INPUT_TAB, type TabType } from "../../types/types";
import type { EditorFiles, EditorFilenames } from "../../hooks/useEditorState";
import styles from "./EditorPanel.module.scss";

interface EditorPanelProps {
  activeTab: TabType;
  onTabChange: (tab: TabType) => void;
  files: EditorFiles;
  filenames: EditorFilenames;
  currentValue: string;
  onFileChange: (value: string) => void;
  hasInput: boolean;
  hasChanges: boolean;
  onReset: () => void;
  onRun: () => void;
  loading: boolean;
}

export function EditorPanel({
  activeTab,
  onTabChange,
  filenames,
  currentValue,
  onFileChange,
  hasInput,
  hasChanges,
  onReset,
  onRun,
  loading,
}: EditorPanelProps) {
  const getTabLabel = (tabId: string): string => {
    if (tabId === "circuit") return filenames.circuit;
    if (tabId === "interface") return filenames.interface;
    if (tabId === "test") return "test.ml";
    if (tabId === "input") return "input.txt";
    return tabId;
  };

  return (
    <div className={styles.panel}>
      <div className={styles.tabs}>
        {TABS.map((tab) => (
          <button
            key={tab.id}
            className={`${styles.tab} ${activeTab === tab.id ? styles.active : ""}`}
            onClick={() => onTabChange(tab.id)}
          >
            {getTabLabel(tab.id)}
          </button>
        ))}
        {hasInput && (
          <button
            key={INPUT_TAB.id}
            className={`${styles.tab} ${activeTab === INPUT_TAB.id ? styles.active : ""}`}
            onClick={() => onTabChange(INPUT_TAB.id)}
          >
            {getTabLabel(INPUT_TAB.id)}
          </button>
        )}
      </div>
      <div className={styles.editorContainer}>
        <OcamlEditor
          key={activeTab}
          value={currentValue}
          onChange={onFileChange}
        />
      </div>
      <div className={styles.toolbar}>
        <button
          className={styles.resetBtn}
          onClick={onReset}
          disabled={!hasChanges}
        >
          ↺ Reset
        </button>
        <button
          className={styles.runBtn}
          onClick={onRun}
          disabled={loading}
        >
          {loading ? "⏳ Compiling..." : "▶ Run"}
        </button>
      </div>
    </div>
  );
}
