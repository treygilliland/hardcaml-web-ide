import { ExampleSelector } from "@ide/components/ExampleSelector";
import {
  getExamplesByCategory,
  type ExampleKey,
} from "@ide/examples/hardcaml-examples";
import styles from "./Header.module.scss";

interface HeaderProps {
  exampleKey: ExampleKey;
  onExampleChange: (key: ExampleKey) => void;
  onResetAll: () => void;
}

const examplesByCategory = getExamplesByCategory();
const DOCS_URL =
  import.meta.env.VITE_DOCS_URL || "https://docs.hardcaml.tg3.dev";

export function Header({
  exampleKey,
  onExampleChange,
  onResetAll,
}: HeaderProps) {
  const handleResetAll = () => {
    if (
      confirm(
        "Reset all examples to their original state? This cannot be undone."
      )
    ) {
      onResetAll();
    }
  };

  return (
    <header className={styles.header}>
      <a href="/" className={styles.siteTitle}>
        <img src="/favicon.png" alt="Hardcaml Logo" className={styles.logo} />
        <span>Hardcaml Web IDE</span>
      </a>
      <div className={styles.actions}>
        <a
          href={DOCS_URL}
          className={styles.docsLink}
          target="_blank"
          rel="noopener noreferrer"
        >
          📚 Docs
        </a>
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
