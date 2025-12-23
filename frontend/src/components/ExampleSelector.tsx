import { useState, useRef, useEffect, useMemo } from "react";
import {
  categoryLabels,
  type ExampleCategory,
  type ExampleKey,
  type HardcamlExample,
} from "../examples/hardcaml-examples";

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
    <div className="example-selector-container" ref={containerRef}>
      <button
        className="example-selector-trigger"
        onClick={() => setIsOpen(!isOpen)}
        type="button"
      >
        <span className="example-selector-value">
          {currentExample?.example.name ?? "Select example..."}
        </span>
        <span className="example-selector-arrow">{isOpen ? "▲" : "▼"}</span>
      </button>

      {isOpen && (
        <div className="example-selector-dropdown">
          <div className="example-selector-search-wrapper">
            <input
              ref={inputRef}
              type="text"
              className="example-selector-search"
              placeholder="Search examples..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              onKeyDown={handleKeyDown}
            />
          </div>
          <div className="example-selector-list">
            {!hasResults && (
              <div className="example-selector-empty">No examples found</div>
            )}
            {(Object.keys(categoryLabels) as ExampleCategory[]).map(
              (category) => {
                const items = filteredByCategory[category];
                if (items.length === 0) return null;

                return (
                  <div key={category} className="example-selector-group">
                    <div className="example-selector-group-label">
                      {categoryLabels[category]}
                    </div>
                    {items.map(({ key, example }) => (
                      <button
                        key={key}
                        className={`example-selector-item ${
                          key === value ? "selected" : ""
                        }`}
                        onClick={() => handleSelect(key)}
                        type="button"
                      >
                        <span className="example-item-name">{example.name}</span>
                        {example.difficulty && (
                          <span
                            className={`example-item-difficulty ${example.difficulty}`}
                          >
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

