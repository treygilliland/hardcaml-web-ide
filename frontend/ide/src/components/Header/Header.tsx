import { ExampleSelector } from "@ide/components/ExampleSelector";
import { getExamplesByCategory, type ExampleKey } from "@ide/examples/hardcaml-examples";
import styles from "./Header.module.scss";

interface HeaderProps {
  exampleKey: ExampleKey;
  onExampleChange: (key: ExampleKey) => void;
  onResetAll: () => void;
}

const examplesByCategory = getExamplesByCategory();

export function Header({ exampleKey, onExampleChange, onResetAll }: HeaderProps) {
  const handleResetAll = () => {
    if (confirm("Reset all examples to their original state? This cannot be undone.")) {
      onResetAll();
    }
  };

  return (
    <header className={styles.header}>
      <h1>🔧 Hardcaml Web IDE</h1>
      <div className={styles.actions}>
        <button
          className={styles.resetAllBtn}
          onClick={handleResetAll}
          title="Reset all examples to original state"
        >
          Reset All
        </button>
        <ExampleSelector
          value={exampleKey}
          examplesByCategory={examplesByCategory}
          onChange={onExampleChange}
        />
      </div>
    </header>
  );
}
