/**
 * Example circuits loaded from hardcaml/examples/ at build time via Vite's ?raw imports.
 * Each example needs: circuit.ml, circuit.mli, test.ml, and optionally input.txt.
 */

// Counter
import counterCircuit from "@hardcaml/examples/counter/circuit.ml?raw";
import counterInterface from "@hardcaml/examples/counter/circuit.mli?raw";
import counterTest from "@hardcaml/examples/counter/test.ml?raw";

// Fibonacci
import fibonacciCircuit from "@hardcaml/examples/fibonacci/circuit.ml?raw";
import fibonacciInterface from "@hardcaml/examples/fibonacci/circuit.mli?raw";
import fibonacciTest from "@hardcaml/examples/fibonacci/test.ml?raw";

// Day 1 Part 1
import day1Part1Circuit from "@hardcaml/examples/day1_part1/circuit.ml?raw";
import day1Part1Interface from "@hardcaml/examples/day1_part1/circuit.mli?raw";
import day1Part1Test from "@hardcaml/examples/day1_part1/test.ml?raw";
import day1Part1Input from "@hardcaml/examples/day1_part1/input.txt?raw";

// Day 1 Part 2
import day1Part2Circuit from "@hardcaml/examples/day1_part2/circuit.ml?raw";
import day1Part2Interface from "@hardcaml/examples/day1_part2/circuit.mli?raw";
import day1Part2Test from "@hardcaml/examples/day1_part2/test.ml?raw";
import day1Part2Input from "@hardcaml/examples/day1_part2/input.txt?raw";

// Types

export type ExampleCategory = "hardcaml" | "advent";

export const categoryLabels: Record<ExampleCategory, string> = {
  hardcaml: "Hardcaml Examples",
  advent: "Advent of FPGA",
};

export interface HardcamlExample {
  /** Display name shown in the example dropdown */
  name: string;
  /** Short description of what the example demonstrates */
  description?: string;
  /** Difficulty level for UI hints */
  difficulty?: "beginner" | "intermediate" | "advanced";
  /** Category for grouping in the dropdown */
  category: ExampleCategory;
  /** Main circuit implementation (circuit.ml) - loaded into Circuit tab */
  circuit: string;
  /** Module interface (circuit.mli) - loaded into Interface tab */
  interface: string;
  /** Test harness (test.ml) - loaded into Test tab */
  test: string;
  /** Optional input data - loaded into Input tab, replaces INPUT_DATA in test.ml */
  input?: string;
}

export type ExampleKey = "counter" | "fibonacci" | "day1_part1" | "day1_part2";

// Example definitions

const counterExample: HardcamlExample = {
  name: "Simple Counter",
  description:
    "An 8-bit counter that increments on each clock cycle when enabled",
  difficulty: "beginner",
  category: "hardcaml",
  circuit: counterCircuit,
  interface: counterInterface,
  test: counterTest,
};

const fibonacciExample: HardcamlExample = {
  name: "Fibonacci",
  description:
    "A state machine that computes the n-th Fibonacci number over multiple clock cycles",
  difficulty: "intermediate",
  category: "hardcaml",
  circuit: fibonacciCircuit,
  interface: fibonacciInterface,
  test: fibonacciTest,
};

const day1Part1Example: HardcamlExample = {
  name: "AoC Day 1 Part 1",
  description:
    "Count how many times a circular dial lands on position 0 after processing rotation commands",
  difficulty: "intermediate",
  category: "advent",
  circuit: day1Part1Circuit,
  interface: day1Part1Interface,
  test: day1Part1Test,
  input: day1Part1Input,
};

const day1Part2Example: HardcamlExample = {
  name: "AoC Day 1 Part 2",
  description:
    "Count how many times a circular dial crosses position 0 during rotations (including full laps)",
  difficulty: "advanced",
  category: "advent",
  circuit: day1Part2Circuit,
  interface: day1Part2Interface,
  test: day1Part2Test,
  input: day1Part2Input,
};

// Registry and helpers

export const examples: Record<ExampleKey, HardcamlExample> = {
  counter: counterExample,
  fibonacci: fibonacciExample,
  day1_part1: day1Part1Example,
  day1_part2: day1Part2Example,
};

export const getExampleKeys = (): ExampleKey[] => {
  return Object.keys(examples) as ExampleKey[];
};

export const getExample = (key: string): HardcamlExample | undefined => {
  return examples[key as ExampleKey];
};

export const getExamplesByCategory = (): Record<
  ExampleCategory,
  { key: ExampleKey; example: HardcamlExample }[]
> => {
  const grouped: Record<
    ExampleCategory,
    { key: ExampleKey; example: HardcamlExample }[]
  > = {
    hardcaml: [],
    advent: [],
  };

  for (const key of getExampleKeys()) {
    const example = examples[key];
    grouped[example.category].push({ key, example });
  }

  return grouped;
};
