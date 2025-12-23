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

// N2T Project 1: Boolean Logic
import n2tNotCircuit from "@hardcaml/examples/n2t/not/Not.ml?raw";
import n2tNotInterface from "@hardcaml/examples/n2t/not/Not.mli?raw";
import n2tNotTest from "@hardcaml/examples/n2t/not/test.ml?raw";

import n2tAndCircuit from "@hardcaml/examples/n2t/and/And.ml?raw";
import n2tAndInterface from "@hardcaml/examples/n2t/and/And.mli?raw";
import n2tAndTest from "@hardcaml/examples/n2t/and/test.ml?raw";

import n2tOrCircuit from "@hardcaml/examples/n2t/or/Or.ml?raw";
import n2tOrInterface from "@hardcaml/examples/n2t/or/Or.mli?raw";
import n2tOrTest from "@hardcaml/examples/n2t/or/test.ml?raw";

import n2tXorCircuit from "@hardcaml/examples/n2t/xor/Xor.ml?raw";
import n2tXorInterface from "@hardcaml/examples/n2t/xor/Xor.mli?raw";
import n2tXorTest from "@hardcaml/examples/n2t/xor/test.ml?raw";

import n2tMuxCircuit from "@hardcaml/examples/n2t/mux/Mux.ml?raw";
import n2tMuxInterface from "@hardcaml/examples/n2t/mux/Mux.mli?raw";
import n2tMuxTest from "@hardcaml/examples/n2t/mux/test.ml?raw";

import n2tDmuxCircuit from "@hardcaml/examples/n2t/dmux/Dmux.ml?raw";
import n2tDmuxInterface from "@hardcaml/examples/n2t/dmux/Dmux.mli?raw";
import n2tDmuxTest from "@hardcaml/examples/n2t/dmux/test.ml?raw";

// Types

export type ExampleCategory = "hardcaml" | "advent" | "n2t";

export const categoryLabels: Record<ExampleCategory, string> = {
  hardcaml: "Hardcaml Examples",
  advent: "Advent of FPGA",
  n2t: "Nand2Tetris",
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
  /** Main circuit implementation - loaded into Circuit tab */
  circuit: string;
  /** Filename for circuit (defaults to "circuit.ml") */
  circuitFilename?: string;
  /** Module interface - loaded into Interface tab */
  interface: string;
  /** Filename for interface (defaults to "circuit.mli") */
  interfaceFilename?: string;
  /** Test harness (test.ml) - loaded into Test tab */
  test: string;
  /** Optional input data - loaded into Input tab, replaces INPUT_DATA in test.ml */
  input?: string;
}

export type ExampleKey =
  | "counter"
  | "fibonacci"
  | "day1_part1"
  | "day1_part2"
  | "n2t_not"
  | "n2t_and"
  | "n2t_or"
  | "n2t_xor"
  | "n2t_mux"
  | "n2t_dmux";

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

// N2T Project 1 Examples

const n2tNotExample: HardcamlExample = {
  name: "Not Gate",
  description: "Build a NOT gate using only NAND gates",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tNotCircuit,
  circuitFilename: "Not.ml",
  interface: n2tNotInterface,
  interfaceFilename: "Not.mli",
  test: n2tNotTest,
};

const n2tAndExample: HardcamlExample = {
  name: "And Gate",
  description: "Build an AND gate using only NAND gates",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tAndCircuit,
  circuitFilename: "And.ml",
  interface: n2tAndInterface,
  interfaceFilename: "And.mli",
  test: n2tAndTest,
};

const n2tOrExample: HardcamlExample = {
  name: "Or Gate",
  description: "Build an OR gate using only NAND gates (hint: De Morgan's law)",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tOrCircuit,
  circuitFilename: "Or.ml",
  interface: n2tOrInterface,
  interfaceFilename: "Or.mli",
  test: n2tOrTest,
};

const n2tXorExample: HardcamlExample = {
  name: "Xor Gate",
  description: "Build an XOR gate using only NAND gates",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tXorCircuit,
  circuitFilename: "Xor.ml",
  interface: n2tXorInterface,
  interfaceFilename: "Xor.mli",
  test: n2tXorTest,
};

const n2tMuxExample: HardcamlExample = {
  name: "Multiplexor",
  description: "Build a 2-to-1 multiplexor using only NAND gates",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tMuxCircuit,
  circuitFilename: "Mux.ml",
  interface: n2tMuxInterface,
  interfaceFilename: "Mux.mli",
  test: n2tMuxTest,
};

const n2tDmuxExample: HardcamlExample = {
  name: "Demultiplexor",
  description: "Build a 1-to-2 demultiplexor using only NAND gates",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tDmuxCircuit,
  circuitFilename: "Dmux.ml",
  interface: n2tDmuxInterface,
  interfaceFilename: "Dmux.mli",
  test: n2tDmuxTest,
};

// Registry and helpers

export const examples: Record<ExampleKey, HardcamlExample> = {
  counter: counterExample,
  fibonacci: fibonacciExample,
  day1_part1: day1Part1Example,
  day1_part2: day1Part2Example,
  n2t_not: n2tNotExample,
  n2t_and: n2tAndExample,
  n2t_or: n2tOrExample,
  n2t_xor: n2tXorExample,
  n2t_mux: n2tMuxExample,
  n2t_dmux: n2tDmuxExample,
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
    n2t: [],
  };

  for (const key of getExampleKeys()) {
    const example = examples[key];
    grouped[example.category].push({ key, example });
  }

  return grouped;
};
