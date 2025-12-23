/**
 * Example circuits loaded from hardcaml/ at build time via Vite's ?raw imports.
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

// N2T Stubs (exercises) from examples/n2t/
import n2tNotStub from "@hardcaml/examples/n2t/not.ml?raw";
import n2tAndStub from "@hardcaml/examples/n2t/and.ml?raw";
import n2tOrStub from "@hardcaml/examples/n2t/or.ml?raw";
import n2tXorStub from "@hardcaml/examples/n2t/xor.ml?raw";
import n2tMuxStub from "@hardcaml/examples/n2t/mux.ml?raw";
import n2tDmuxStub from "@hardcaml/examples/n2t/dmux.ml?raw";
import n2tNot16Stub from "@hardcaml/examples/n2t/not16.ml?raw";
import n2tAnd16Stub from "@hardcaml/examples/n2t/and16.ml?raw";
import n2tOr16Stub from "@hardcaml/examples/n2t/or16.ml?raw";
import n2tMux16Stub from "@hardcaml/examples/n2t/mux16.ml?raw";
import n2tOr8wayStub from "@hardcaml/examples/n2t/or8way.ml?raw";
import n2tMux4way16Stub from "@hardcaml/examples/n2t/mux4way16.ml?raw";
import n2tMux8way16Stub from "@hardcaml/examples/n2t/mux8way16.ml?raw";
import n2tDmux4wayStub from "@hardcaml/examples/n2t/dmux4way.ml?raw";
import n2tDmux8wayStub from "@hardcaml/examples/n2t/dmux8way.ml?raw";
import n2tHalfadderStub from "@hardcaml/examples/n2t/halfadder.ml?raw";
import n2tFulladderStub from "@hardcaml/examples/n2t/fulladder.ml?raw";
import n2tAdd16Stub from "@hardcaml/examples/n2t/add16.ml?raw";
import n2tInc16Stub from "@hardcaml/examples/n2t/inc16.ml?raw";
import n2tAluStub from "@hardcaml/examples/n2t/alu.ml?raw";

// N2T Reference implementations (user-runnable solutions)
import n2tNotImpl from "@hardcaml/examples/n2t_solutions/not.ml?raw";
import n2tAndImpl from "@hardcaml/examples/n2t_solutions/and.ml?raw";
import n2tOrImpl from "@hardcaml/examples/n2t_solutions/or.ml?raw";
import n2tXorImpl from "@hardcaml/examples/n2t_solutions/xor.ml?raw";
import n2tMuxImpl from "@hardcaml/examples/n2t_solutions/mux.ml?raw";
import n2tDmuxImpl from "@hardcaml/examples/n2t_solutions/dmux.ml?raw";
import n2tNot16Impl from "@hardcaml/examples/n2t_solutions/not16.ml?raw";
import n2tAnd16Impl from "@hardcaml/examples/n2t_solutions/and16.ml?raw";
import n2tOr16Impl from "@hardcaml/examples/n2t_solutions/or16.ml?raw";
import n2tMux16Impl from "@hardcaml/examples/n2t_solutions/mux16.ml?raw";
import n2tOr8wayImpl from "@hardcaml/examples/n2t_solutions/or8way.ml?raw";
import n2tMux4way16Impl from "@hardcaml/examples/n2t_solutions/mux4way16.ml?raw";
import n2tMux8way16Impl from "@hardcaml/examples/n2t_solutions/mux8way16.ml?raw";
import n2tDmux4wayImpl from "@hardcaml/examples/n2t_solutions/dmux4way.ml?raw";
import n2tDmux8wayImpl from "@hardcaml/examples/n2t_solutions/dmux8way.ml?raw";
import n2tHalfadderImpl from "@hardcaml/examples/n2t_solutions/halfadder.ml?raw";
import n2tFulladderImpl from "@hardcaml/examples/n2t_solutions/fulladder.ml?raw";
import n2tAdd16Impl from "@hardcaml/examples/n2t_solutions/add16.ml?raw";
import n2tInc16Impl from "@hardcaml/examples/n2t_solutions/inc16.ml?raw";
import n2tAluImpl from "@hardcaml/examples/n2t_solutions/alu.ml?raw";

// N2T interfaces and tests from lib/n2t_chips/
import n2tNotInterface from "@hardcaml/build-cache/lib/n2t_chips/not.mli?raw";
import n2tNotTest from "@hardcaml/build-cache/lib/n2t_chips/not_test.ml?raw";
import n2tAndInterface from "@hardcaml/build-cache/lib/n2t_chips/and.mli?raw";
import n2tAndTest from "@hardcaml/build-cache/lib/n2t_chips/and_test.ml?raw";
import n2tOrInterface from "@hardcaml/build-cache/lib/n2t_chips/or.mli?raw";
import n2tOrTest from "@hardcaml/build-cache/lib/n2t_chips/or_test.ml?raw";
import n2tXorInterface from "@hardcaml/build-cache/lib/n2t_chips/xor.mli?raw";
import n2tXorTest from "@hardcaml/build-cache/lib/n2t_chips/xor_test.ml?raw";
import n2tMuxInterface from "@hardcaml/build-cache/lib/n2t_chips/mux.mli?raw";
import n2tMuxTest from "@hardcaml/build-cache/lib/n2t_chips/mux_test.ml?raw";
import n2tDmuxInterface from "@hardcaml/build-cache/lib/n2t_chips/dmux.mli?raw";
import n2tDmuxTest from "@hardcaml/build-cache/lib/n2t_chips/dmux_test.ml?raw";
import n2tNot16Interface from "@hardcaml/build-cache/lib/n2t_chips/not16.mli?raw";
import n2tNot16Test from "@hardcaml/build-cache/lib/n2t_chips/not16_test.ml?raw";
import n2tAnd16Interface from "@hardcaml/build-cache/lib/n2t_chips/and16.mli?raw";
import n2tAnd16Test from "@hardcaml/build-cache/lib/n2t_chips/and16_test.ml?raw";
import n2tOr16Interface from "@hardcaml/build-cache/lib/n2t_chips/or16.mli?raw";
import n2tOr16Test from "@hardcaml/build-cache/lib/n2t_chips/or16_test.ml?raw";
import n2tMux16Interface from "@hardcaml/build-cache/lib/n2t_chips/mux16.mli?raw";
import n2tMux16Test from "@hardcaml/build-cache/lib/n2t_chips/mux16_test.ml?raw";
import n2tOr8wayInterface from "@hardcaml/build-cache/lib/n2t_chips/or8way.mli?raw";
import n2tOr8wayTest from "@hardcaml/build-cache/lib/n2t_chips/or8way_test.ml?raw";
import n2tMux4way16Interface from "@hardcaml/build-cache/lib/n2t_chips/mux4way16.mli?raw";
import n2tMux4way16Test from "@hardcaml/build-cache/lib/n2t_chips/mux4way16_test.ml?raw";
import n2tMux8way16Interface from "@hardcaml/build-cache/lib/n2t_chips/mux8way16.mli?raw";
import n2tMux8way16Test from "@hardcaml/build-cache/lib/n2t_chips/mux8way16_test.ml?raw";
import n2tDmux4wayInterface from "@hardcaml/build-cache/lib/n2t_chips/dmux4way.mli?raw";
import n2tDmux4wayTest from "@hardcaml/build-cache/lib/n2t_chips/dmux4way_test.ml?raw";
import n2tDmux8wayInterface from "@hardcaml/build-cache/lib/n2t_chips/dmux8way.mli?raw";
import n2tDmux8wayTest from "@hardcaml/build-cache/lib/n2t_chips/dmux8way_test.ml?raw";
import n2tHalfadderInterface from "@hardcaml/build-cache/lib/n2t_chips/halfadder.mli?raw";
import n2tHalfadderTest from "@hardcaml/build-cache/lib/n2t_chips/halfadder_test.ml?raw";
import n2tFulladderInterface from "@hardcaml/build-cache/lib/n2t_chips/fulladder.mli?raw";
import n2tFulladderTest from "@hardcaml/build-cache/lib/n2t_chips/fulladder_test.ml?raw";
import n2tAdd16Interface from "@hardcaml/build-cache/lib/n2t_chips/add16.mli?raw";
import n2tAdd16Test from "@hardcaml/build-cache/lib/n2t_chips/add16_test.ml?raw";
import n2tInc16Interface from "@hardcaml/build-cache/lib/n2t_chips/inc16.mli?raw";
import n2tInc16Test from "@hardcaml/build-cache/lib/n2t_chips/inc16_test.ml?raw";
import n2tAluInterface from "@hardcaml/build-cache/lib/n2t_chips/alu.mli?raw";
import n2tAluTest from "@hardcaml/build-cache/lib/n2t_chips/alu_test.ml?raw";

// Types

export type ExampleCategory = "hardcaml" | "advent" | "n2t" | "n2t_solutions";

export const categoryLabels: Record<ExampleCategory, string> = {
  hardcaml: "Hardcaml Examples",
  advent: "Advent of FPGA",
  n2t: "Nand2Tetris",
  n2t_solutions: "Nand2Tetris Solutions",
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
  | "n2t_dmux"
  | "n2t_not16"
  | "n2t_and16"
  | "n2t_or16"
  | "n2t_mux16"
  | "n2t_or8way"
  | "n2t_mux4way16"
  | "n2t_mux8way16"
  | "n2t_dmux4way"
  | "n2t_dmux8way"
  | "n2t_halfadder"
  | "n2t_fulladder"
  | "n2t_add16"
  | "n2t_inc16"
  | "n2t_alu"
  | "n2t_not_solution"
  | "n2t_and_solution"
  | "n2t_or_solution"
  | "n2t_xor_solution"
  | "n2t_mux_solution"
  | "n2t_dmux_solution"
  | "n2t_not16_solution"
  | "n2t_and16_solution"
  | "n2t_or16_solution"
  | "n2t_mux16_solution"
  | "n2t_or8way_solution"
  | "n2t_mux4way16_solution"
  | "n2t_mux8way16_solution"
  | "n2t_dmux4way_solution"
  | "n2t_dmux8way_solution"
  | "n2t_halfadder_solution"
  | "n2t_fulladder_solution"
  | "n2t_add16_solution"
  | "n2t_inc16_solution"
  | "n2t_alu_solution";

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

// N2T Exercises (stubs)

const n2tNotExample: HardcamlExample = {
  name: "Not Gate",
  description: "Build a NOT gate using only NAND gates",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tNotStub,
  circuitFilename: "not.ml",
  interface: n2tNotInterface,
  interfaceFilename: "not.mli",
  test: n2tNotTest,
};

const n2tAndExample: HardcamlExample = {
  name: "And Gate",
  description: "Build an AND gate using only NAND gates",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tAndStub,
  circuitFilename: "and.ml",
  interface: n2tAndInterface,
  interfaceFilename: "and.mli",
  test: n2tAndTest,
};

const n2tOrExample: HardcamlExample = {
  name: "Or Gate",
  description: "Build an OR gate using only NAND gates (hint: De Morgan's law)",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tOrStub,
  circuitFilename: "or.ml",
  interface: n2tOrInterface,
  interfaceFilename: "or.mli",
  test: n2tOrTest,
};

const n2tXorExample: HardcamlExample = {
  name: "Xor Gate",
  description: "Build an XOR gate using only NAND gates",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tXorStub,
  circuitFilename: "xor.ml",
  interface: n2tXorInterface,
  interfaceFilename: "xor.mli",
  test: n2tXorTest,
};

const n2tMuxExample: HardcamlExample = {
  name: "Multiplexor",
  description: "Build a 2-to-1 multiplexor using only NAND gates",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tMuxStub,
  circuitFilename: "mux.ml",
  interface: n2tMuxInterface,
  interfaceFilename: "mux.mli",
  test: n2tMuxTest,
};

const n2tDmuxExample: HardcamlExample = {
  name: "Demultiplexor",
  description: "Build a 1-to-2 demultiplexor using only NAND gates",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tDmuxStub,
  circuitFilename: "dmux.ml",
  interface: n2tDmuxInterface,
  interfaceFilename: "dmux.mli",
  test: n2tDmuxTest,
};

const n2tNot16Example: HardcamlExample = {
  name: "Not16",
  description: "16-bit bitwise NOT gate",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tNot16Stub,
  circuitFilename: "not16.ml",
  interface: n2tNot16Interface,
  interfaceFilename: "not16.mli",
  test: n2tNot16Test,
};

const n2tAnd16Example: HardcamlExample = {
  name: "And16",
  description: "16-bit bitwise AND gate",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tAnd16Stub,
  circuitFilename: "and16.ml",
  interface: n2tAnd16Interface,
  interfaceFilename: "and16.mli",
  test: n2tAnd16Test,
};

const n2tOr16Example: HardcamlExample = {
  name: "Or16",
  description: "16-bit bitwise OR gate",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tOr16Stub,
  circuitFilename: "or16.ml",
  interface: n2tOr16Interface,
  interfaceFilename: "or16.mli",
  test: n2tOr16Test,
};

const n2tMux16Example: HardcamlExample = {
  name: "Mux16",
  description: "16-bit multiplexor",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tMux16Stub,
  circuitFilename: "mux16.ml",
  interface: n2tMux16Interface,
  interfaceFilename: "mux16.mli",
  test: n2tMux16Test,
};

const n2tOr8wayExample: HardcamlExample = {
  name: "Or8Way",
  description: "8-way OR gate",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tOr8wayStub,
  circuitFilename: "or8way.ml",
  interface: n2tOr8wayInterface,
  interfaceFilename: "or8way.mli",
  test: n2tOr8wayTest,
};

const n2tMux4way16Example: HardcamlExample = {
  name: "Mux4Way16",
  description: "4-way 16-bit multiplexor",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tMux4way16Stub,
  circuitFilename: "mux4way16.ml",
  interface: n2tMux4way16Interface,
  interfaceFilename: "mux4way16.mli",
  test: n2tMux4way16Test,
};

const n2tMux8way16Example: HardcamlExample = {
  name: "Mux8Way16",
  description: "8-way 16-bit multiplexor",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tMux8way16Stub,
  circuitFilename: "mux8way16.ml",
  interface: n2tMux8way16Interface,
  interfaceFilename: "mux8way16.mli",
  test: n2tMux8way16Test,
};

const n2tDmux4wayExample: HardcamlExample = {
  name: "DMux4Way",
  description: "4-way demultiplexor",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tDmux4wayStub,
  circuitFilename: "dmux4way.ml",
  interface: n2tDmux4wayInterface,
  interfaceFilename: "dmux4way.mli",
  test: n2tDmux4wayTest,
};

const n2tDmux8wayExample: HardcamlExample = {
  name: "DMux8Way",
  description: "8-way demultiplexor",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tDmux8wayStub,
  circuitFilename: "dmux8way.ml",
  interface: n2tDmux8wayInterface,
  interfaceFilename: "dmux8way.mli",
  test: n2tDmux8wayTest,
};

const n2tHalfadderExample: HardcamlExample = {
  name: "Half Adder",
  description: "Computes sum and carry of two bits",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tHalfadderStub,
  circuitFilename: "halfadder.ml",
  interface: n2tHalfadderInterface,
  interfaceFilename: "halfadder.mli",
  test: n2tHalfadderTest,
};

const n2tFulladderExample: HardcamlExample = {
  name: "Full Adder",
  description: "Computes sum and carry of three bits",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tFulladderStub,
  circuitFilename: "fulladder.ml",
  interface: n2tFulladderInterface,
  interfaceFilename: "fulladder.mli",
  test: n2tFulladderTest,
};

const n2tAdd16Example: HardcamlExample = {
  name: "Add16",
  description: "16-bit adder",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tAdd16Stub,
  circuitFilename: "add16.ml",
  interface: n2tAdd16Interface,
  interfaceFilename: "add16.mli",
  test: n2tAdd16Test,
};

const n2tInc16Example: HardcamlExample = {
  name: "Inc16",
  description: "16-bit incrementer (out = in + 1)",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tInc16Stub,
  circuitFilename: "inc16.ml",
  interface: n2tInc16Interface,
  interfaceFilename: "inc16.mli",
  test: n2tInc16Test,
};

const n2tAluExample: HardcamlExample = {
  name: "ALU",
  description: "Arithmetic Logic Unit with 6 control bits",
  difficulty: "advanced",
  category: "n2t",
  circuit: n2tAluStub,
  circuitFilename: "alu.ml",
  interface: n2tAluInterface,
  interfaceFilename: "alu.mli",
  test: n2tAluTest,
};

// N2T Solutions (reference implementations)

const n2tNotSolutionExample: HardcamlExample = {
  name: "Not Gate",
  description: "Reference implementation of NOT gate",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tNotImpl,
  circuitFilename: "not.ml",
  interface: n2tNotInterface,
  interfaceFilename: "not.mli",
  test: n2tNotTest,
};

const n2tAndSolutionExample: HardcamlExample = {
  name: "And Gate",
  description: "Reference implementation of AND gate",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tAndImpl,
  circuitFilename: "and.ml",
  interface: n2tAndInterface,
  interfaceFilename: "and.mli",
  test: n2tAndTest,
};

const n2tOrSolutionExample: HardcamlExample = {
  name: "Or Gate",
  description: "Reference implementation of OR gate",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tOrImpl,
  circuitFilename: "or.ml",
  interface: n2tOrInterface,
  interfaceFilename: "or.mli",
  test: n2tOrTest,
};

const n2tXorSolutionExample: HardcamlExample = {
  name: "Xor Gate",
  description: "Reference implementation of XOR gate",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tXorImpl,
  circuitFilename: "xor.ml",
  interface: n2tXorInterface,
  interfaceFilename: "xor.mli",
  test: n2tXorTest,
};

const n2tMuxSolutionExample: HardcamlExample = {
  name: "Multiplexor",
  description: "Reference implementation of 2-to-1 multiplexor",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tMuxImpl,
  circuitFilename: "mux.ml",
  interface: n2tMuxInterface,
  interfaceFilename: "mux.mli",
  test: n2tMuxTest,
};

const n2tDmuxSolutionExample: HardcamlExample = {
  name: "Demultiplexor",
  description: "Reference implementation of 1-to-2 demultiplexor",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tDmuxImpl,
  circuitFilename: "dmux.ml",
  interface: n2tDmuxInterface,
  interfaceFilename: "dmux.mli",
  test: n2tDmuxTest,
};

const n2tNot16SolutionExample: HardcamlExample = {
  name: "Not16",
  description: "Reference implementation of 16-bit NOT gate",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tNot16Impl,
  circuitFilename: "not16.ml",
  interface: n2tNot16Interface,
  interfaceFilename: "not16.mli",
  test: n2tNot16Test,
};

const n2tAnd16SolutionExample: HardcamlExample = {
  name: "And16",
  description: "Reference implementation of 16-bit AND gate",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tAnd16Impl,
  circuitFilename: "and16.ml",
  interface: n2tAnd16Interface,
  interfaceFilename: "and16.mli",
  test: n2tAnd16Test,
};

const n2tOr16SolutionExample: HardcamlExample = {
  name: "Or16",
  description: "Reference implementation of 16-bit OR gate",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tOr16Impl,
  circuitFilename: "or16.ml",
  interface: n2tOr16Interface,
  interfaceFilename: "or16.mli",
  test: n2tOr16Test,
};

const n2tMux16SolutionExample: HardcamlExample = {
  name: "Mux16",
  description: "Reference implementation of 16-bit multiplexor",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tMux16Impl,
  circuitFilename: "mux16.ml",
  interface: n2tMux16Interface,
  interfaceFilename: "mux16.mli",
  test: n2tMux16Test,
};

const n2tOr8waySolutionExample: HardcamlExample = {
  name: "Or8Way",
  description: "Reference implementation of 8-way OR gate",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tOr8wayImpl,
  circuitFilename: "or8way.ml",
  interface: n2tOr8wayInterface,
  interfaceFilename: "or8way.mli",
  test: n2tOr8wayTest,
};

const n2tMux4way16SolutionExample: HardcamlExample = {
  name: "Mux4Way16",
  description: "Reference implementation of 4-way 16-bit multiplexor",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tMux4way16Impl,
  circuitFilename: "mux4way16.ml",
  interface: n2tMux4way16Interface,
  interfaceFilename: "mux4way16.mli",
  test: n2tMux4way16Test,
};

const n2tMux8way16SolutionExample: HardcamlExample = {
  name: "Mux8Way16",
  description: "Reference implementation of 8-way 16-bit multiplexor",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tMux8way16Impl,
  circuitFilename: "mux8way16.ml",
  interface: n2tMux8way16Interface,
  interfaceFilename: "mux8way16.mli",
  test: n2tMux8way16Test,
};

const n2tDmux4waySolutionExample: HardcamlExample = {
  name: "DMux4Way",
  description: "Reference implementation of 4-way demultiplexor",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tDmux4wayImpl,
  circuitFilename: "dmux4way.ml",
  interface: n2tDmux4wayInterface,
  interfaceFilename: "dmux4way.mli",
  test: n2tDmux4wayTest,
};

const n2tDmux8waySolutionExample: HardcamlExample = {
  name: "DMux8Way",
  description: "Reference implementation of 8-way demultiplexor",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tDmux8wayImpl,
  circuitFilename: "dmux8way.ml",
  interface: n2tDmux8wayInterface,
  interfaceFilename: "dmux8way.mli",
  test: n2tDmux8wayTest,
};

const n2tHalfadderSolutionExample: HardcamlExample = {
  name: "Half Adder",
  description: "Reference implementation of half adder",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tHalfadderImpl,
  circuitFilename: "halfadder.ml",
  interface: n2tHalfadderInterface,
  interfaceFilename: "halfadder.mli",
  test: n2tHalfadderTest,
};

const n2tFulladderSolutionExample: HardcamlExample = {
  name: "Full Adder",
  description: "Reference implementation of full adder",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tFulladderImpl,
  circuitFilename: "fulladder.ml",
  interface: n2tFulladderInterface,
  interfaceFilename: "fulladder.mli",
  test: n2tFulladderTest,
};

const n2tAdd16SolutionExample: HardcamlExample = {
  name: "Add16",
  description: "Reference implementation of 16-bit adder",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tAdd16Impl,
  circuitFilename: "add16.ml",
  interface: n2tAdd16Interface,
  interfaceFilename: "add16.mli",
  test: n2tAdd16Test,
};

const n2tInc16SolutionExample: HardcamlExample = {
  name: "Inc16",
  description: "Reference implementation of 16-bit incrementer",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tInc16Impl,
  circuitFilename: "inc16.ml",
  interface: n2tInc16Interface,
  interfaceFilename: "inc16.mli",
  test: n2tInc16Test,
};

const n2tAluSolutionExample: HardcamlExample = {
  name: "ALU",
  description: "Reference implementation of ALU",
  difficulty: "advanced",
  category: "n2t_solutions",
  circuit: n2tAluImpl,
  circuitFilename: "alu.ml",
  interface: n2tAluInterface,
  interfaceFilename: "alu.mli",
  test: n2tAluTest,
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
  n2t_not16: n2tNot16Example,
  n2t_and16: n2tAnd16Example,
  n2t_or16: n2tOr16Example,
  n2t_mux16: n2tMux16Example,
  n2t_or8way: n2tOr8wayExample,
  n2t_mux4way16: n2tMux4way16Example,
  n2t_mux8way16: n2tMux8way16Example,
  n2t_dmux4way: n2tDmux4wayExample,
  n2t_dmux8way: n2tDmux8wayExample,
  n2t_halfadder: n2tHalfadderExample,
  n2t_fulladder: n2tFulladderExample,
  n2t_add16: n2tAdd16Example,
  n2t_inc16: n2tInc16Example,
  n2t_alu: n2tAluExample,
  n2t_not_solution: n2tNotSolutionExample,
  n2t_and_solution: n2tAndSolutionExample,
  n2t_or_solution: n2tOrSolutionExample,
  n2t_xor_solution: n2tXorSolutionExample,
  n2t_mux_solution: n2tMuxSolutionExample,
  n2t_dmux_solution: n2tDmuxSolutionExample,
  n2t_not16_solution: n2tNot16SolutionExample,
  n2t_and16_solution: n2tAnd16SolutionExample,
  n2t_or16_solution: n2tOr16SolutionExample,
  n2t_mux16_solution: n2tMux16SolutionExample,
  n2t_or8way_solution: n2tOr8waySolutionExample,
  n2t_mux4way16_solution: n2tMux4way16SolutionExample,
  n2t_mux8way16_solution: n2tMux8way16SolutionExample,
  n2t_dmux4way_solution: n2tDmux4waySolutionExample,
  n2t_dmux8way_solution: n2tDmux8waySolutionExample,
  n2t_halfadder_solution: n2tHalfadderSolutionExample,
  n2t_fulladder_solution: n2tFulladderSolutionExample,
  n2t_add16_solution: n2tAdd16SolutionExample,
  n2t_inc16_solution: n2tInc16SolutionExample,
  n2t_alu_solution: n2tAluSolutionExample,
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
    n2t_solutions: [],
  };

  for (const key of getExampleKeys()) {
    const example = examples[key];
    grouped[example.category].push({ key, example });
  }

  return grouped;
};
