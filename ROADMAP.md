# Roadmap

Future work and technical debt items for the Hardcaml Web IDE project.

## Technical Debt

### Generate Type Declarations for Raw Imports

**File:** `frontend/ide/src/types/raw.d.ts`

Manually maintained type declarations for Vite's `?raw` imports. Generate from script or use `import.meta.glob` patterns.

### Generate Examples Registry

**File:** `frontend/ide/src/examples/hardcaml-examples.ts`

Large file (1188+ lines) with repetitive patterns. Generate from manifest or use `import.meta.glob` to dynamically load examples.

### Astro Config Package Resolution

Astro config directly aliases `@hardcaml/ui` to source, bypassing `package.json` entry point. Works but creates implicit coupling.

## Future Work

### OCaml LSP Integration

Integrate OCaml Language Server Protocol for type checking, code completion, navigation, and inline documentation.

### OxCaml Playground Integration

Explore integration with [OxCaml](https://github.com/oxcaml/oxcaml) playground for in-browser OCaml compilation and shared code snippets.

### Browser-Based Compilation

Move compilation to browser using WebAssembly to reduce server load, enable offline capabilities, and improve feedback loop.

### Multi-Language Support

Add support for other languages (Verilog, SystemVerilog) using the existing language initialization architecture in `frontend/ui/src/languages/`.

### Example Management

Automated example discovery, metadata (difficulty, tags, categories), and CI validation.

### Performance

Code splitting for Monaco editor, lazy loading of examples, bundle size optimization.

### Developer Experience

Better error messages, improved documentation, development tooling improvements.
