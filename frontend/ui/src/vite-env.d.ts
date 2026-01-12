/// <reference types="vite/client" />

// Type declarations for Vite-specific features and module imports.
// This file is required for TypeScript to understand:
// - Vite's client-side types (import.meta.env, etc.)
// - SCSS module imports (CSS modules)
// - Monaco editor type exports

declare module "*.module.scss" {
  const classes: { readonly [key: string]: string };
  export default classes;
}

declare module "monaco-editor" {
  export * from "monaco-editor/esm/vs/editor/editor.api";
}
