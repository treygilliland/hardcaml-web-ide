import {
  type ExampleCategory,
  type ExampleKey,
  type HardcamlExample,
} from "@ide/examples/hardcaml-examples";

// Section configuration
export interface SectionConfig {
  label: string;
  subsections?: SubsectionConfig[];
}

export interface SubsectionConfig {
  label: string;
  examples: ExampleKey[];
}

// Advent of Code - explicitly list completed examples
const AOC_COMPLETED: ExampleKey[] = [
  "day1_part1",
  "day1_part2",
  "day2_part1",
  "day2_part2",
  "day3_part1",
  "day3_part2",
  "day12_part1",
];

// Nand2Tetris project groupings
const N2T_PROJECT_1: ExampleKey[] = [
  "n2t_not",
  "n2t_and",
  "n2t_or",
  "n2t_xor",
  "n2t_mux",
  "n2t_dmux",
  "n2t_not16",
  "n2t_and16",
  "n2t_or16",
  "n2t_mux16",
  "n2t_or8way",
  "n2t_mux4way16",
  "n2t_mux8way16",
  "n2t_dmux4way",
  "n2t_dmux8way",
];

const N2T_PROJECT_2: ExampleKey[] = [
  "n2t_halfadder",
  "n2t_fulladder",
  "n2t_add16",
  "n2t_inc16",
  "n2t_alu",
];

const N2T_PROJECT_3: ExampleKey[] = [
  "n2t_dff",
  "n2t_bit",
  "n2t_register",
  "n2t_ram8",
  "n2t_ram64",
  "n2t_ram512",
  "n2t_ram4k",
  "n2t_ram16k",
  "n2t_pc",
];

const N2T_PROJECT_5: ExampleKey[] = ["n2t_memory", "n2t_cpu", "n2t_computer"];

const N2T_SOLUTION_PROJECT_1: ExampleKey[] = N2T_PROJECT_1.map(
  (c) => `${c}_solution` as ExampleKey
);

const N2T_SOLUTION_PROJECT_2: ExampleKey[] = N2T_PROJECT_2.map(
  (c) => `${c}_solution` as ExampleKey
);

const N2T_SOLUTION_PROJECT_3: ExampleKey[] = N2T_PROJECT_3.map(
  (c) => `${c}_solution` as ExampleKey
);

const N2T_SOLUTION_PROJECT_5: ExampleKey[] = N2T_PROJECT_5.map(
  (c) => `${c}_solution` as ExampleKey
);

type ExampleItem = { key: ExampleKey; example: HardcamlExample };

// Helper to get all AoC examples from a category
function getAllAocExamples(
  examplesByCategory: Record<ExampleCategory, ExampleItem[]>
): ExampleKey[] {
  return examplesByCategory.advent.map(({ key }) => key);
}

// Helper to get AoC examples not in the completed list
function getAocTodoExamples(
  examplesByCategory: Record<ExampleCategory, ExampleItem[]>
): ExampleKey[] {
  const allAoc = getAllAocExamples(examplesByCategory);
  return allAoc.filter((key) => !AOC_COMPLETED.includes(key));
}

/**
 * Get the section configuration for organizing examples in the sidebar.
 * This function takes the examples by category and returns a structured
 * configuration that defines how examples should be organized.
 */
export function getSectionConfig(
  examplesByCategory: Record<ExampleCategory, ExampleItem[]>
): Record<ExampleCategory, SectionConfig> {
  return {
    ocaml_basics: {
      label: "Hardcaml Basics",
    },
    hardcaml: {
      label: "Hardcaml Examples",
    },
    advent: {
      label: "Advent of Code/FPGA",
      subsections: [
        {
          label: "Completed",
          examples: AOC_COMPLETED,
        },
        {
          label: "TODO",
          examples: getAocTodoExamples(examplesByCategory),
        },
      ],
    },
    n2t: {
      label: "Nand2Tetris",
      subsections: [
        {
          label: "Project 1: Boolean Logic",
          examples: N2T_PROJECT_1,
        },
        {
          label: "Project 2: Boolean Arithmetic",
          examples: N2T_PROJECT_2,
        },
        {
          label: "Project 3: Sequential Logic",
          examples: N2T_PROJECT_3,
        },
        {
          label: "Project 5: Computer Architecture",
          examples: N2T_PROJECT_5,
        },
      ],
    },
    n2t_solutions: {
      label: "Nand2Tetris Solutions",
      subsections: [
        {
          label: "Project 1: Boolean Logic",
          examples: N2T_SOLUTION_PROJECT_1,
        },
        {
          label: "Project 2: Boolean Arithmetic",
          examples: N2T_SOLUTION_PROJECT_2,
        },
        {
          label: "Project 3: Sequential Logic",
          examples: N2T_SOLUTION_PROJECT_3,
        },
        {
          label: "Project 5: Computer Architecture",
          examples: N2T_SOLUTION_PROJECT_5,
        },
      ],
    },
    playground: {
      label: "Playground",
    },
  };
}
