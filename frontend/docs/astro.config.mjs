import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import mdx from "@astrojs/mdx";
import react from "@astrojs/react";
import { fileURLToPath } from "url";
import path from "path";
import { existsSync } from "fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Resolve hardcaml path - consistent across all environments
// From frontend/docs, go up two levels to repo root, then into hardcaml
// Local dev: <repo-root>/frontend/docs -> <repo-root>/hardcaml
// Docker dev: /workspace/frontend/docs -> /workspace/hardcaml
// Docker prod build: /app/docs -> /app/hardcaml
const hardcamlExamplesPath = path.resolve(__dirname, "../../hardcaml");

// Validate that the hardcaml directory exists
if (!existsSync(hardcamlExamplesPath)) {
  throw new Error(
    `hardcaml directory not found at ${hardcamlExamplesPath}. ` +
      `Ensure hardcaml repo is cloned or mounted correctly.`
  );
}

// Debug: Log the resolved path (only in debug mode)
if (process.env.DEBUG_PATHS) {
  console.log("[astro.config] hardcamlExamplesPath:", hardcamlExamplesPath);
  console.log("[astro.config] __dirname:", __dirname);
  console.log("[astro.config] process.cwd():", process.cwd());
  console.log("[astro.config] Environment variables:", {
    VITE_PUBLIC_POSTHOG_KEY: process.env.VITE_PUBLIC_POSTHOG_KEY ? process.env.VITE_PUBLIC_POSTHOG_KEY.substring(0, 15) + "..." : "<not set>",
    VITE_PUBLIC_POSTHOG_HOST: process.env.VITE_PUBLIC_POSTHOG_HOST || "<not set>",
    VITE_POSTHOG_ENABLED: process.env.VITE_POSTHOG_ENABLED || "<not set>",
  });
}

export default defineConfig({
  site: "https://hardcaml.tg3.dev",
  integrations: [
    react(),
    starlight({
      title: "Hardcaml Web IDE",
      description: "Learn hardware design with Hardcaml in your browser",
      favicon: "/favicon.png",
      logo: {
        src: "./src/assets/hardcaml-logo.png",
        alt: "Hardcaml Logo",
      },
      components: {
        SocialIcons: "./src/components/SocialIcons.astro",
      },
      customCss: ["./src/styles/custom.css"],
      expressiveCode: {
        themes: ["starlight-dark"],
      },
      sidebar: [
        {
          label: "Getting Started",
          items: [
            { label: "Introduction", slug: "getting-started/introduction" },
            { label: "Quick Start", slug: "getting-started/quick-start" },
            { label: "Motivation", slug: "getting-started/motivation" },
          ],
        },
        {
          label: "Tutorials",
          items: [
            {
              label: "Ocaml Introduction",
              slug: "tutorials/ocaml-introduction",
            },
            { label: "Your First Circuit", slug: "tutorials/first-circuit" },
            { label: "Waveforms", slug: "tutorials/waveforms" },
          ],
        },
        {
          label: "Advent of Code",
          items: [
            { label: "Overview", slug: "advent-of-code/overview" },
            { label: "Day 1: Dial Rotation", slug: "advent-of-code/day-1" },
            { label: "Day 2: Mirror Numbers", slug: "advent-of-code/day-2" },
            { label: "Day 3: Digit Processing", slug: "advent-of-code/day-3" },
            { label: "Day 12: Shape Counting", slug: "advent-of-code/day-12" },
          ],
        },
        {
          label: "Nand2Tetris",
          items: [
            { label: "Overview", slug: "nand2tetris/overview" },
            { label: "Project 1: Logic Gates", slug: "nand2tetris/project-1" },
            { label: "Project 2: ALU", slug: "nand2tetris/project-2" },
            { label: "Project 3: Memory", slug: "nand2tetris/project-3" },
            {
              label: "Project 5: CPU and Computer",
              slug: "nand2tetris/project-5",
            },
          ],
        },
        {
          label: "Reference",
          items: [
            { label: "Deployment", slug: "reference/deploy" },
            { label: "API", slug: "reference/api" },
          ],
        },
      ],
    }),
    mdx(),
  ],
  vite: {
    // Explicitly define environment variables for Vite
    // This ensures they're available in client-side code
    // process.env is available in astro.config.mjs (see Astro docs)
    // Vite will also automatically read .env files during build
    // See: https://docs.astro.build/en/guides/environment-variables/#in-the-astro-config-file
    define: {
      "import.meta.env.VITE_PUBLIC_POSTHOG_KEY": JSON.stringify(process.env.VITE_PUBLIC_POSTHOG_KEY || ""),
      "import.meta.env.VITE_PUBLIC_POSTHOG_HOST": JSON.stringify(process.env.VITE_PUBLIC_POSTHOG_HOST || "https://us.i.posthog.com"),
      "import.meta.env.VITE_POSTHOG_ENABLED": JSON.stringify(process.env.VITE_POSTHOG_ENABLED || ""),
    },
    resolve: {
      alias: [
        { find: /^@\/(.+)$/, replacement: path.resolve(__dirname, "src/$1") },
        { find: "@", replacement: path.resolve(__dirname, "src") },
        {
          find: /^@components\/(.+)$/,
          replacement: path.resolve(__dirname, "src/components/$1"),
        },
        {
          find: "@components",
          replacement: path.resolve(__dirname, "src/components"),
        },
        // IDE aliases - use array format like IDE's vite.config for consistency
        {
          find: /^@ide\/(.+)$/,
          replacement: path.resolve(__dirname, "../ide/src/$1"),
        },
        { find: "@ide", replacement: path.resolve(__dirname, "../ide/src") },
        {
          find: /^@ui\/(.+)$/,
          replacement: path.resolve(__dirname, "../ui/src/$1"),
        },
        { find: "@ui", replacement: path.resolve(__dirname, "../ui/src") },
        // Hardcaml examples - use explicit absolute path
        // Vite processes $1 as a regex replacement, so we use string concatenation
        // The path should be /app/hardcaml in Docker context
        {
          find: /^@hardcaml-examples\/(.+)$/,
          replacement: hardcamlExamplesPath + "/$1",
        },
        { find: "@hardcaml-examples", replacement: hardcamlExamplesPath },
      ],
      extensions: [".mjs", ".js", ".ts", ".jsx", ".tsx", ".json"],
    },
    // Allow Vite to access files outside the project root (needed for hardcaml examples)
    // This is needed for both dev server and build
    // Be explicit about what we need access to
    server: {
      fs: {
        allow: [
          path.resolve(__dirname, ".."), // Frontend workspace root
          hardcamlExamplesPath, // Hardcaml examples
        ],
      },
    },
    ssr: {
      noExternal: [],
    },
    build: {
      rollupOptions: {
        // Ensure Vite can resolve paths correctly during build
        external: [],
      },
    },
    // Ensure Vite can access files during build (not just dev server)
    // Note: Raw file imports (?raw) are handled automatically by Vite
    // and don't need to be excluded from optimization
  },
});
