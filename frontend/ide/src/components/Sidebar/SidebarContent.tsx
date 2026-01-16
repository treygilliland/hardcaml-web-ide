import { useState, useEffect, useCallback, useMemo } from "react";
import {
  categoryLabels,
  type ExampleCategory,
  type ExampleKey,
  type HardcamlExample,
} from "@ide/examples/hardcaml-examples";
import { getSectionConfig } from "./sidebarConfig";
import styles from "./SidebarContent.module.scss";

const FOLDER_STATE_KEY = "hardcaml-folder-states";
const SUBSECTION_STATE_KEY = "hardcaml-subsection-states";

type ExampleItem = { key: ExampleKey; example: HardcamlExample };
type OrganizedExamples = Record<
  ExampleCategory,
  ExampleItem[] | Record<string, ExampleItem[]>
>;

interface SidebarContentProps {
  value: ExampleKey;
  examplesByCategory: Record<ExampleCategory, ExampleItem[]>;
  onChange: (key: ExampleKey) => void;
}

export function SidebarContent({
  value,
  examplesByCategory,
  onChange,
}: SidebarContentProps) {
  const [folderStates, setFolderStates] = useState<
    Record<ExampleCategory, boolean>
  >(() => {
    const saved = localStorage.getItem(FOLDER_STATE_KEY);
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // Fallback to default
      }
    }
    // Default: all folders expanded
    return {
      ocaml_basics: true,
      hardcaml: true,
      advent: true,
      n2t: true,
      n2t_solutions: true,
    };
  });

  const [subsectionStates, setSubsectionStates] = useState<
    Record<string, boolean>
  >(() => {
    const saved = localStorage.getItem(SUBSECTION_STATE_KEY);
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // Fallback to default
      }
    }
    // Default: all subsections expanded
    return {};
  });

  // Persist folder states
  useEffect(() => {
    localStorage.setItem(FOLDER_STATE_KEY, JSON.stringify(folderStates));
  }, [folderStates]);

  // Persist subsection states
  useEffect(() => {
    localStorage.setItem(
      SUBSECTION_STATE_KEY,
      JSON.stringify(subsectionStates)
    );
  }, [subsectionStates]);

  const toggleFolder = useCallback((category: ExampleCategory) => {
    setFolderStates((prev) => ({
      ...prev,
      [category]: !prev[category],
    }));
  }, []);

  const toggleSubsection = useCallback((subsectionKey: string) => {
    setSubsectionStates((prev) => ({
      ...prev,
      [subsectionKey]: !prev[subsectionKey],
    }));
  }, []);

  // Get section configuration
  const sectionConfig = useMemo(
    () => getSectionConfig(examplesByCategory),
    [examplesByCategory]
  );

  // Organize examples by subsection
  const organizedExamples = useMemo((): OrganizedExamples => {
    const organized: OrganizedExamples = {} as OrganizedExamples;

    const categories = Object.keys(categoryLabels) as ExampleCategory[];

    for (const category of categories) {
      const items = examplesByCategory[category];
      const config = sectionConfig[category];

      if (!config.subsections) {
        // No subsections, just use items directly
        organized[category] = items;
      } else {
        // Organize by subsections - match examples by key
        const bySubsection: Record<string, ExampleItem[]> = {};

        // Create a map for quick lookup
        const itemsMap = new Map<ExampleKey, HardcamlExample>();
        for (const item of items) {
          itemsMap.set(item.key, item.example);
        }

        for (const subsection of config.subsections) {
          // Find examples that match the subsection's example keys
          bySubsection[subsection.label] = subsection.examples
            .map((key) => {
              const example = itemsMap.get(key);
              return example ? { key, example } : null;
            })
            .filter((item): item is ExampleItem => item !== null);
        }

        organized[category] = bySubsection;
      }
    }

    return organized;
  }, [examplesByCategory, sectionConfig]);

  const handleExampleClick = useCallback(
    (key: ExampleKey) => {
      onChange(key);
    },
    [onChange]
  );

  const categories = Object.keys(categoryLabels) as ExampleCategory[];

  return (
    <div className={styles.content}>
      {categories.map((category) => {
        // Hide n2t stubs section (keep n2t_solutions visible)
        if (category === "n2t") return null;

        const organized = organizedExamples[category];
        if (!organized) return null;

        const config = sectionConfig[category];
        const isExpanded = folderStates[category];
        const hasSubsections = !!config.subsections;

        // Check if category has any items
        const hasItems = hasSubsections
          ? Object.values(organized as Record<string, ExampleItem[]>).some(
              (items) => items.length > 0
            )
          : (organized as ExampleItem[]).length > 0;

        if (!hasItems) return null;

        return (
          <div key={category} className={styles.folder}>
            <button
              className={styles.folderHeader}
              onClick={() => toggleFolder(category)}
              type="button"
              aria-expanded={isExpanded}
            >
              <span className={styles.folderIcon}>
                {isExpanded ? "▼" : "▶"}
              </span>
              <span className={styles.folderName}>{config.label}</span>
            </button>
            {isExpanded && (
              <div className={styles.folderContent}>
                {hasSubsections
                  ? // Render subsections
                    config.subsections?.map((subsection) => {
                      const subsectionItems =
                        (organized as Record<string, ExampleItem[]>)[
                          subsection.label
                        ] || [];
                      if (subsectionItems.length === 0) return null;

                      const subsectionKey = `${category}-${subsection.label}`;
                      const isSubsectionExpanded =
                        subsectionStates[subsectionKey] ?? true; // Default to true

                      return (
                        <div
                          key={subsection.label}
                          className={styles.subsection}
                        >
                          <button
                            className={styles.subsectionHeader}
                            onClick={() => toggleSubsection(subsectionKey)}
                            type="button"
                            aria-expanded={isSubsectionExpanded}
                          >
                            <span className={styles.folderIcon}>
                              {isSubsectionExpanded ? "▼" : "▶"}
                            </span>
                            <span className={styles.subsectionName}>
                              {subsection.label}
                            </span>
                          </button>
                          {isSubsectionExpanded && (
                            <div className={styles.subsectionContent}>
                              {subsectionItems.map(({ key, example }) => (
                                <button
                                  key={key}
                                  className={`${styles.exampleItem} ${
                                    key === value ? styles.selected : ""
                                  }`}
                                  onClick={() => handleExampleClick(key)}
                                  type="button"
                                  title={example.description || example.name}
                                >
                                  <span className={styles.fileIcon}>📄</span>
                                  <span className={styles.exampleName}>
                                    {example.name}
                                  </span>
                                </button>
                              ))}
                            </div>
                          )}
                        </div>
                      );
                    })
                  : // Render items directly (no subsections)
                    (organized as ExampleItem[]).map(({ key, example }) => (
                      <button
                        key={key}
                        className={`${styles.exampleItem} ${
                          key === value ? styles.selected : ""
                        }`}
                        onClick={() => handleExampleClick(key)}
                        type="button"
                        title={example.description || example.name}
                      >
                        <span className={styles.fileIcon}>📄</span>
                        <span className={styles.exampleName}>
                          {example.name}
                        </span>
                      </button>
                    ))}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
