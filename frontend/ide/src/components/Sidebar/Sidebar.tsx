import { useState, useEffect, useCallback } from "react";
import {
  type ExampleCategory,
  type ExampleKey,
  type HardcamlExample,
} from "@ide/examples/hardcaml-examples";
import { SidebarContent } from "./SidebarContent";
import styles from "./Sidebar.module.scss";

const SIDEBAR_COLLAPSED_KEY = "hardcaml-sidebar-collapsed";

interface SidebarProps {
  value: ExampleKey;
  examplesByCategory: Record<
    ExampleCategory,
    { key: ExampleKey; example: HardcamlExample }[]
  >;
  onChange: (key: ExampleKey) => void;
}

export function Sidebar({ value, examplesByCategory, onChange }: SidebarProps) {
  const [isCollapsed, setIsCollapsed] = useState(() => {
    const saved = localStorage.getItem(SIDEBAR_COLLAPSED_KEY);
    return saved ? JSON.parse(saved) : false;
  });

  // Persist sidebar collapsed state
  useEffect(() => {
    localStorage.setItem(SIDEBAR_COLLAPSED_KEY, JSON.stringify(isCollapsed));
  }, [isCollapsed]);

  const toggleSidebar = useCallback(() => {
    setIsCollapsed((prev: boolean) => !prev);
  }, []);

  return (
    <div className={`${styles.sidebar} ${isCollapsed ? styles.collapsed : ""}`}>
      <div
        className={styles.header}
        onClick={toggleSidebar}
        role="button"
        tabIndex={0}
        aria-label={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
        title={isCollapsed ? "Expand sidebar" : "Collapse sidebar"}
        onKeyDown={(e) => {
          if (e.key === "Enter" || e.key === " ") {
            e.preventDefault();
            toggleSidebar();
          }
        }}
      >
        <span className={styles.toggleButton}>{isCollapsed ? "▶" : "◀"}</span>
        {!isCollapsed && <span className={styles.title}>Circuits</span>}
      </div>
      {!isCollapsed && (
        <SidebarContent
          value={value}
          examplesByCategory={examplesByCategory}
          onChange={onChange}
        />
      )}
    </div>
  );
}
