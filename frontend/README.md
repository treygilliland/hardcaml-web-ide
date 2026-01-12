# Frontend Workspace

pnpm workspace containing shared components and applications for the Hardcaml Web IDE project.

## Structure

```
frontend/
├── pnpm-workspace.yaml    # Workspace definition
├── package.json           # Root scripts
├── tsconfig.base.json     # Shared TypeScript config
├── ui/                    # @hardcaml/ui - shared components
├── ide/                   # @hardcaml/ide - main application
└── docs/                  # @hardcaml/docs - Starlight docs site
```

## Packages

| Package | Purpose | Consumers |
|---------|---------|-----------|
| `@hardcaml/ui` | Shared React components, hooks, API client | ide, docs |
| `@hardcaml/ide` | Main IDE application | standalone |
| `@hardcaml/docs` | Astro Starlight documentation | standalone |

## Workspace-Only Usage

**Important:** The `@hardcaml/ui` package is designed for workspace-only use and is not intended for publication to npm. It:

- Points directly to TypeScript source (`main: "./src/index.ts"`)
- Relies on consuming applications (IDE and docs) to transpile code via Vite/Astro
- Does not include a build step or generate distribution files
- Uses pnpm's `workspace:*` protocol for internal dependencies

This approach simplifies development by avoiding build steps while maintaining type safety and proper module resolution within the workspace.

## Development

### Install dependencies

```bash
pnpm install
```

### Run applications

```bash
# IDE
pnpm dev

# Docs site
pnpm dev:docs
```

### Lint all packages

```bash
pnpm lint
```

## TypeScript Configuration

All packages extend from `tsconfig.base.json` which defines shared compiler options. Package-specific configs add:

- Type definitions (e.g., `vite/client` for IDE)
- Path aliases
- Include/exclude patterns

## CSS Variables

The workspace uses a standardized CSS variable namespace:

- **IDE**: Defines `--color-*` variables and maps them to `--hardcaml-*` for UI components
- **UI Components**: Use `--hardcaml-*` variables with fallbacks
- **Docs**: Defines `--hardcaml-*` variables in `custom.css`

This ensures consistent theming across all consumers of the UI package.

## Documentation Site

The docs site uses [Astro Starlight](https://starlight.astro.build/) for documentation. Content files are located in `docs/src/content/docs/`.

### Adding a New Page

1. **Create the content file** in `docs/src/content/docs/` following the directory structure:
   ```
   docs/src/content/docs/
   ├── getting-started/
   │   └── introduction.mdx
   └── tutorials/
       └── first-circuit.mdx
   ```

2. **Add frontmatter** to your `.mdx` file:
   ```mdx
   ---
   title: Your Page Title
   description: Brief description
   ---
   ```

3. **Update the sidebar** in `docs/astro.config.mjs`:
   ```javascript
   sidebar: [
     {
       label: 'Your Section',
       items: [
         { label: 'Your Page', slug: 'your-section/your-page' },
       ],
     },
   ],
   ```

   **Note:** Astro Starlight requires manual sidebar configuration. The sidebar structure must match your content file paths (slugs). The slug should match the file path relative to `src/content/docs/` without the `.mdx` extension.

4. **Build and test**:
   ```bash
   pnpm dev:docs  # Development server
   pnpm build:docs  # Production build
   ```

### Sidebar Configuration

The sidebar in `astro.config.mjs` is manually configured because Starlight doesn't auto-generate navigation from file structure. This gives us control over:
- Section organization and ordering
- Custom labels (can differ from page titles)
- Collapsible sections
- External links

When adding new pages, always update the sidebar configuration to ensure they appear in navigation.
