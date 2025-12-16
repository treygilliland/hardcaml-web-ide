/**
 * Example/Exercise type definitions for HardCaml Web IDE
 *
 * Examples are organized as exercises that students can work through.
 * Each example contains:
 * - circuit: The main implementation file (circuit.ml)
 * - interface: The module interface (circuit.mli)
 * - test: The test harness (test.ml)
 * - input: Optional input data for examples that process input
 */

import { counterExample } from "./counter";
import { fibonacciExample } from "./fibonacci";
import { day1Part1Example } from "./day1_part1";
import { day1Part2Example } from "./day1_part2";

/** Category for grouping examples in the dropdown */
export type ExampleCategory = "hardcaml" | "advent";

/** Category display configuration */
export const categoryLabels: Record<ExampleCategory, string> = {
  hardcaml: "Hardcaml Examples",
  advent: "Advent of FPGA",
};

export interface HardcamlExample {
  /** Display name for the example */
  name: string;
  /** Short description of what the exercise teaches */
  description?: string;
  /** Difficulty level for students */
  difficulty?: "beginner" | "intermediate" | "advanced";
  /** Category for grouping in the dropdown */
  category: ExampleCategory;
  /** The main circuit implementation (circuit.ml) */
  circuit: string;
  /** The module interface (circuit.mli) */
  interface: string;
  /** The test harness (test.ml) */
  test: string;
  /** Optional input data for examples that process input */
  input?: string;
}

export type ExampleKey = "counter" | "fibonacci" | "day1_part1" | "day1_part2";

/**
 * All available examples in the IDE
 */
export const examples: Record<ExampleKey, HardcamlExample> = {
  counter: counterExample,
  fibonacci: fibonacciExample,
  day1_part1: day1Part1Example,
  day1_part2: day1Part2Example,
};

/**
 * Get list of available example keys for UI dropdowns
 */
export const getExampleKeys = (): ExampleKey[] => {
  return Object.keys(examples) as ExampleKey[];
};

/**
 * Get an example by key, or undefined if not found
 */
export const getExample = (key: string): HardcamlExample | undefined => {
  return examples[key as ExampleKey];
};

/**
 * Get examples grouped by category for optgroup rendering
 */
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
