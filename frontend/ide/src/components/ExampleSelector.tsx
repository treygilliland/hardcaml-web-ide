import { useState, useRef, useEffect, useMemo } from "react";
import {
  categoryLabels,
  type ExampleCategory,
  type ExampleKey,
  type HardcamlExample,
} from "@ide/examples/hardcaml-examples";
import styles from "./ExampleSelector.module.scss";

const DIFFICULTY_CLASS_MAP: Record<
  "beginner" | "intermediate" | "advanced",
  string
> = {
  beginner: styles.itemDifficultyBeginner,
  intermediate: styles.itemDifficultyIntermediate,
  advanced: styles.itemDifficultyAdvanced,
};

interface ExampleSelectorProps {
  value: ExampleKey;
  examplesByCategory: Record<
    ExampleCategory,
    { key: ExampleKey; example: HardcamlExample }[]
  >;
  onChange: (key: ExampleKey) => void;
}

export function ExampleSelector({
  value,
  examplesByCategory,
  onChange,
}: ExampleSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [search, setSearch] = useState("");
  const containerRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const allExamples = useMemo(() => {
    const items: { key: ExampleKey; example: HardcamlExample }[] = [];
    for (const category of Object.keys(categoryLabels) as ExampleCategory[]) {
      items.push(...examplesByCategory[category]);
    }
    return items;
  }, [examplesByCategory]);

  const currentExample = allExamples.find((e) => e.key === value);

  const filteredByCategory = useMemo(() => {
    const searchLower = search.toLowerCase();
    const result: Record<
      ExampleCategory,
      { key: ExampleKey; example: HardcamlExample }[]
    > = {
      hardcaml: [],
      advent: [],
      n2t: [],
      n2t_solutions: [],
    };

    for (const category of Object.keys(categoryLabels) as ExampleCategory[]) {
      result[category] = examplesByCategory[category].filter(
        ({ example }) =>
          example.name.toLowerCase().includes(searchLower) ||
          example.description?.toLowerCase().includes(searchLower) ||
          categoryLabels[category].toLowerCase().includes(searchLower)
      );
    }

    return result;
  }, [examplesByCategory, search]);

  const hasResults = Object.values(filteredByCategory).some(
    (items) => items.length > 0
  );

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (
        containerRef.current &&
        !containerRef.current.contains(e.target as Node)
      ) {
        setIsOpen(false);
        setSearch("");
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    if (isOpen && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isOpen]);

  const handleSelect = (key: ExampleKey) => {
    onChange(key);
    setIsOpen(false);
    setSearch("");
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Escape") {
      setIsOpen(false);
      setSearch("");
    }
  };

  return (
    <div className={styles.container} ref={containerRef}>
      <button
        className={styles.trigger}
        onClick={() => setIsOpen(!isOpen)}
        type="button"
      >
        <span className={styles.value}>
          {currentExample?.example.name ?? "Select example..."}
        </span>
        <span className={styles.arrow}>{isOpen ? "▲" : "▼"}</span>
      </button>

      {isOpen && (
        <div className={styles.dropdown}>
          <div className={styles.searchWrapper}>
            <input
              ref={inputRef}
              type="text"
              className={styles.search}
              placeholder="Search examples..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              onKeyDown={handleKeyDown}
            />
          </div>
          <div className={styles.list}>
            {!hasResults && (
              <div className={styles.empty}>No examples found</div>
            )}
            {(Object.keys(categoryLabels) as ExampleCategory[]).map(
              (category) => {
                const items = filteredByCategory[category];
                if (items.length === 0) return null;

                return (
                  <div key={category} className={styles.group}>
                    <div className={styles.groupLabel}>
                      {categoryLabels[category]}
                    </div>
                    {items.map(({ key, example }) => (
                      <button
                        key={key}
                        className={`${styles.item} ${
                          key === value ? styles.selected : ""
                        }`}
                        onClick={() => handleSelect(key)}
                        type="button"
                      >
                        <span className={styles.itemName}>
                          {example.name}
                        </span>
                        {example.difficulty && (
                          <span className={DIFFICULTY_CLASS_MAP[example.difficulty]}>
                            {example.difficulty}
                          </span>
                        )}
                      </button>
                    ))}
                  </div>
                );
              }
            )}
          </div>
        </div>
      )}
    </div>
  );
}
