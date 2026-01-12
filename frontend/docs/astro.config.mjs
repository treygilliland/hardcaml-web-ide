import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import mdx from "@astrojs/mdx";
import { fileURLToPath } from "url";
import path from "path";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  site: "https://docs.hardcaml.tg3.dev",
  integrations: [
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
          ],
        },
        {
          label: "Tutorials",
          items: [
            { label: "Your First Circuit", slug: "tutorials/first-circuit" },
            { label: "Waveforms", slug: "tutorials/waveforms" },
          ],
        },
        {
          label: "Nand2Tetris",
          items: [
            { label: "Overview", slug: "nand2tetris/overview" },
            { label: "Project 1: Logic Gates", slug: "nand2tetris/project-1" },
            { label: "Project 2: ALU", slug: "nand2tetris/project-2" },
            { label: "Project 3: Memory", slug: "nand2tetris/project-3" },
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
      alias: {
        "@": path.resolve(__dirname, "src"),
        "@components": path.resolve(__dirname, "src/components"),
      },
      extensions: [".mjs", ".js", ".ts", ".jsx", ".tsx", ".json"],
    },
    ssr: {
      noExternal: [],
    },
  },
});
