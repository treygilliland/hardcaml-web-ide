import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import mdx from "@astrojs/mdx";
import react from "@astrojs/react";
import { fileURLToPath } from "url";
import path from "path";
import { existsSync } from "fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Resolve hardcaml path - ensure absolute path resolution
// In Docker dev: volume mounts ./hardcaml:/hardcaml, so check /hardcaml first
// Otherwise: from /app/docs, go up one level to /app, then into hardcaml
// This gives us /app/hardcaml (not /hardcaml which would be wrong)
let hardcamlExamplesPath;
if (existsSync("/hardcaml")) {
  // Docker dev environment - hardcaml is mounted at /hardcaml
  hardcamlExamplesPath = "/hardcaml";
} else {
  // Local dev or build - use relative path
  hardcamlExamplesPath = path.resolve(__dirname, "../hardcaml");
  // Ensure it's an absolute, normalized path
  hardcamlExamplesPath = path.resolve(hardcamlExamplesPath);
}

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
          path.resolve(__dirname, ".."),  // Frontend workspace root
          hardcamlExamplesPath,            // Hardcaml examples
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
