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
| `@hardcaml/ide` | Main IDE application | docs (integrated) |
| `@hardcaml/docs` | Astro Starlight documentation with integrated IDE | standalone |

## Current Architecture

**The IDE is integrated into the docs site** and served from a single container. This simplifies deployment and maintenance while keeping the codebase organized for potential future separation.

### Integration Details

- The IDE React app is mounted in `docs/src/components/IDE.tsx` using React's `createRoot`
- IDE code is imported via path aliases (`@ide/*`) configured in `docs/astro.config.mjs`
- CSS files are imported using path aliases for maintainability
- The IDE is accessible at `/ide` route in the docs site

### Splitting Out the IDE (Future)

The IDE package (`frontend/ide/`) is structured to be easily split out if needed:

1. **Standalone configs are preserved:**
   - `ide/vite.config.ts` - Vite configuration for standalone dev server
   - `ide/index.html` - Standalone entry point
   - `ide/package.json` - Already has build scripts configured

2. **To run IDE standalone:**
   ```bash
   pnpm --filter ide dev
   ```

3. **To split out completely:**
   - Create a separate Dockerfile for the IDE
   - Update deployment configs to serve IDE separately
   - The IDE already has its own build output (`ide/dist/`)
   - Path aliases in `ide/vite.config.ts` are already configured

The current integration approach keeps things simple while maintaining separation of concerns.

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
# Docs site (includes integrated IDE at /ide) - primary development workflow
pnpm dev:docs

# IDE standalone (for testing standalone deployment)
pnpm --filter ide dev
```

**Note:** The primary development workflow uses `pnpm dev:docs` which serves both docs and IDE. The standalone IDE dev server is available for testing but not used in production.

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

The IDE is integrated into the docs site and accessible at the `/ide` route. The IDE makes API calls to the backend using the `PUBLIC_API_BASE_URL` environment variable.

### Analytics (PostHog)

PostHog analytics is configured via environment variables. During Docker builds:
1. Root `.env` file → Docker build args (via `docker-compose.yml`)
2. Dockerfile creates `.env` in `frontend/docs/` from build args
3. Vite reads `.env` during build + `astro.config.mjs` injects via `define`
4. Values are baked into the client bundle at build time

Set `VITE_PUBLIC_POSTHOG_KEY`, `VITE_PUBLIC_POSTHOG_HOST`, and `VITE_POSTHOG_ENABLED` in the root `.env` file.

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
