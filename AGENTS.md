# Agent Instructions

See [README.md](README.md) for project overview and setup.

See [docs/](docs/) for additional documentation:
- [DEPLOY.md](docs/DEPLOY.md) - Deployment guide
- [Nand2Tetris.md](docs/Nand2Tetris.md) - Nand2Tetris integration

## Code Style Preferences

### Imports
- Use path aliases (`@components/`, `@hooks/`, `@examples/`, etc.) instead of relative imports
- Co-located files (like `.module.scss` next to their component) may use relative imports

### File Organization
- No barrel files (`index.ts` that just re-export) - use descriptive filenames instead
- `index.ts` should only be used as an actual index when needed (e.g., package entry points)
- Prefer aptly named files: `useCompiler.ts` over `hooks/index.ts`

### Environment Variables
- When adding or changing environment variables, update **both** `README.md` and `.env.example`
