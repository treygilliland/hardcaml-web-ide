/**
 * Example circuits loaded from hardcaml/ at build time via Vite's ?raw imports.
 * Each example needs: circuit.ml, circuit.mli, test.ml, and optionally input.txt.
 */

// Counter
import counterCircuit from "@hardcaml-examples/examples/counter/circuit.ml?raw";
import counterInterface from "@hardcaml-examples/examples/counter/circuit.mli?raw";
import counterTest from "@hardcaml-examples/examples/counter/test.ml?raw";

// Fibonacci
import fibonacciCircuit from "@hardcaml-examples/examples/fibonacci/circuit.ml?raw";
import fibonacciInterface from "@hardcaml-examples/examples/fibonacci/circuit.mli?raw";
import fibonacciTest from "@hardcaml-examples/examples/fibonacci/test.ml?raw";

// OCaml Basics - Hello Nand Gate
import helloNandCircuit from "@hardcaml-examples/examples/ocaml_basics/nand/circuit.ml?raw";
import helloNandInterface from "@hardcaml-examples/examples/ocaml_basics/nand/circuit.mli?raw";
import helloNandTest from "@hardcaml-examples/examples/ocaml_basics/nand/test.ml?raw";

// OCaml Basics - Types
import helloTypesCircuit from "@hardcaml-examples/examples/ocaml_basics/types/circuit.ml?raw";
import helloTypesInterface from "@hardcaml-examples/examples/ocaml_basics/types/circuit.mli?raw";
import helloTypesTest from "@hardcaml-examples/examples/ocaml_basics/types/test.ml?raw";

// OCaml Basics - Modules
import helloModulesCircuit from "@hardcaml-examples/examples/ocaml_basics/modules/circuit.ml?raw";
import helloModulesInterface from "@hardcaml-examples/examples/ocaml_basics/modules/circuit.mli?raw";
import helloModulesTest from "@hardcaml-examples/examples/ocaml_basics/modules/test.ml?raw";

// OCaml Basics - Patterns
import helloPatternsCircuit from "@hardcaml-examples/examples/ocaml_basics/patterns/circuit.ml?raw";
import helloPatternsInterface from "@hardcaml-examples/examples/ocaml_basics/patterns/circuit.mli?raw";
import helloPatternsTest from "@hardcaml-examples/examples/ocaml_basics/patterns/test.ml?raw";

// OCaml Basics - Operators
import helloOperatorsCircuit from "@hardcaml-examples/examples/ocaml_basics/operators/circuit.ml?raw";
import helloOperatorsInterface from "@hardcaml-examples/examples/ocaml_basics/operators/circuit.mli?raw";
import helloOperatorsTest from "@hardcaml-examples/examples/ocaml_basics/operators/test.ml?raw";

// Playground - Oxcaml Playground
import oxcamlPlaygroundMain from "@hardcaml-examples/examples/oxcaml_playground/main.ml?raw";
import oxcamlPlaygroundInterface from "@hardcaml-examples/examples/oxcaml_playground/main.mli?raw";
import oxcamlPlaygroundTest from "@hardcaml-examples/examples/oxcaml_playground/test.ml?raw";

// Playground - Hardcaml Playground
import hardcamlPlaygroundCircuit from "@hardcaml-examples/examples/hardcaml_playground/circuit.ml?raw";
import hardcamlPlaygroundInterface from "@hardcaml-examples/examples/hardcaml_playground/circuit.mli?raw";
import hardcamlPlaygroundTest from "@hardcaml-examples/examples/hardcaml_playground/test.ml?raw";

// Day 1 Part 1
import day1Part1Circuit from "@hardcaml-examples/aoc/day1_part1/circuit.ml?raw";
import day1Part1Interface from "@hardcaml-examples/aoc/day1_part1/circuit.mli?raw";
import day1Part1Test from "@hardcaml-examples/aoc/day1_part1/test.ml?raw";
import day1Part1Input from "@hardcaml-examples/aoc/day1_part1/input.txt?raw";

// Day 1 Part 2
import day1Part2Circuit from "@hardcaml-examples/aoc/day1_part2/circuit.ml?raw";
import day1Part2Interface from "@hardcaml-examples/aoc/day1_part2/circuit.mli?raw";
import day1Part2Test from "@hardcaml-examples/aoc/day1_part2/test.ml?raw";
import day1Part2Input from "@hardcaml-examples/aoc/day1_part2/input.txt?raw";

// Day 2 Part 1
import day2Part1Circuit from "@hardcaml-examples/aoc/day2_part1/circuit.ml?raw";
import day2Part1Interface from "@hardcaml-examples/aoc/day2_part1/circuit.mli?raw";
import day2Part1Test from "@hardcaml-examples/aoc/day2_part1/test.ml?raw";
import day2Part1Input from "@hardcaml-examples/aoc/day2_part1/input.txt?raw";

// Day 2 Part 2
import day2Part2Circuit from "@hardcaml-examples/aoc/day2_part2/circuit.ml?raw";
import day2Part2Interface from "@hardcaml-examples/aoc/day2_part2/circuit.mli?raw";
import day2Part2Test from "@hardcaml-examples/aoc/day2_part2/test.ml?raw";
import day2Part2Input from "@hardcaml-examples/aoc/day2_part2/input.txt?raw";

// Day 3 Part 1
import day3Part1Circuit from "@hardcaml-examples/aoc/day3_part1/circuit.ml?raw";
import day3Part1Interface from "@hardcaml-examples/aoc/day3_part1/circuit.mli?raw";
import day3Part1Test from "@hardcaml-examples/aoc/day3_part1/test.ml?raw";
import day3Part1Input from "@hardcaml-examples/aoc/day3_part1/input.txt?raw";

// Day 3 Part 2
import day3Part2Circuit from "@hardcaml-examples/aoc/day3_part2/circuit.ml?raw";
import day3Part2Interface from "@hardcaml-examples/aoc/day3_part2/circuit.mli?raw";
import day3Part2Test from "@hardcaml-examples/aoc/day3_part2/test.ml?raw";
import day3Part2Input from "@hardcaml-examples/aoc/day3_part2/input.txt?raw";

// Day 4 Part 1
import day4Part1Circuit from "@hardcaml-examples/aoc/day4_part1/circuit.ml?raw";
import day4Part1Interface from "@hardcaml-examples/aoc/day4_part1/circuit.mli?raw";
import day4Part1Test from "@hardcaml-examples/aoc/day4_part1/test.ml?raw";
import day4Part1Input from "@hardcaml-examples/aoc/day4_part1/input.txt?raw";

// Day 4 Part 2
import day4Part2Circuit from "@hardcaml-examples/aoc/day4_part2/circuit.ml?raw";
import day4Part2Interface from "@hardcaml-examples/aoc/day4_part2/circuit.mli?raw";
import day4Part2Test from "@hardcaml-examples/aoc/day4_part2/test.ml?raw";
import day4Part2Input from "@hardcaml-examples/aoc/day4_part2/input.txt?raw";

// Day 5 Part 1
import day5Part1Circuit from "@hardcaml-examples/aoc/day5_part1/circuit.ml?raw";
import day5Part1Interface from "@hardcaml-examples/aoc/day5_part1/circuit.mli?raw";
import day5Part1Test from "@hardcaml-examples/aoc/day5_part1/test.ml?raw";
import day5Part1Input from "@hardcaml-examples/aoc/day5_part1/input.txt?raw";

// Day 5 Part 2
import day5Part2Circuit from "@hardcaml-examples/aoc/day5_part2/circuit.ml?raw";
import day5Part2Interface from "@hardcaml-examples/aoc/day5_part2/circuit.mli?raw";
import day5Part2Test from "@hardcaml-examples/aoc/day5_part2/test.ml?raw";
import day5Part2Input from "@hardcaml-examples/aoc/day5_part2/input.txt?raw";

// Day 6 Part 1
import day6Part1Circuit from "@hardcaml-examples/aoc/day6_part1/circuit.ml?raw";
import day6Part1Interface from "@hardcaml-examples/aoc/day6_part1/circuit.mli?raw";
import day6Part1Test from "@hardcaml-examples/aoc/day6_part1/test.ml?raw";
import day6Part1Input from "@hardcaml-examples/aoc/day6_part1/input.txt?raw";

// Day 6 Part 2
import day6Part2Circuit from "@hardcaml-examples/aoc/day6_part2/circuit.ml?raw";
import day6Part2Interface from "@hardcaml-examples/aoc/day6_part2/circuit.mli?raw";
import day6Part2Test from "@hardcaml-examples/aoc/day6_part2/test.ml?raw";
import day6Part2Input from "@hardcaml-examples/aoc/day6_part2/input.txt?raw";

// Day 7 Part 1
import day7Part1Circuit from "@hardcaml-examples/aoc/day7_part1/circuit.ml?raw";
import day7Part1Interface from "@hardcaml-examples/aoc/day7_part1/circuit.mli?raw";
import day7Part1Test from "@hardcaml-examples/aoc/day7_part1/test.ml?raw";
import day7Part1Input from "@hardcaml-examples/aoc/day7_part1/input.txt?raw";

// Day 7 Part 2
import day7Part2Circuit from "@hardcaml-examples/aoc/day7_part2/circuit.ml?raw";
import day7Part2Interface from "@hardcaml-examples/aoc/day7_part2/circuit.mli?raw";
import day7Part2Test from "@hardcaml-examples/aoc/day7_part2/test.ml?raw";
import day7Part2Input from "@hardcaml-examples/aoc/day7_part2/input.txt?raw";

// Day 8 Part 1
import day8Part1Circuit from "@hardcaml-examples/aoc/day8_part1/circuit.ml?raw";
import day8Part1Interface from "@hardcaml-examples/aoc/day8_part1/circuit.mli?raw";
import day8Part1Test from "@hardcaml-examples/aoc/day8_part1/test.ml?raw";
import day8Part1Input from "@hardcaml-examples/aoc/day8_part1/input.txt?raw";

// Day 8 Part 2
import day8Part2Circuit from "@hardcaml-examples/aoc/day8_part2/circuit.ml?raw";
import day8Part2Interface from "@hardcaml-examples/aoc/day8_part2/circuit.mli?raw";
import day8Part2Test from "@hardcaml-examples/aoc/day8_part2/test.ml?raw";
import day8Part2Input from "@hardcaml-examples/aoc/day8_part2/input.txt?raw";

// Day 9 Part 1
import day9Part1Circuit from "@hardcaml-examples/aoc/day9_part1/circuit.ml?raw";
import day9Part1Interface from "@hardcaml-examples/aoc/day9_part1/circuit.mli?raw";
import day9Part1Test from "@hardcaml-examples/aoc/day9_part1/test.ml?raw";
import day9Part1Input from "@hardcaml-examples/aoc/day9_part1/input.txt?raw";

// Day 9 Part 2
import day9Part2Circuit from "@hardcaml-examples/aoc/day9_part2/circuit.ml?raw";
import day9Part2Interface from "@hardcaml-examples/aoc/day9_part2/circuit.mli?raw";
import day9Part2Test from "@hardcaml-examples/aoc/day9_part2/test.ml?raw";
import day9Part2Input from "@hardcaml-examples/aoc/day9_part2/input.txt?raw";

// Day 10 Part 1
import day10Part1Circuit from "@hardcaml-examples/aoc/day10_part1/circuit.ml?raw";
import day10Part1Interface from "@hardcaml-examples/aoc/day10_part1/circuit.mli?raw";
import day10Part1Test from "@hardcaml-examples/aoc/day10_part1/test.ml?raw";
import day10Part1Input from "@hardcaml-examples/aoc/day10_part1/input.txt?raw";

// Day 10 Part 2
import day10Part2Circuit from "@hardcaml-examples/aoc/day10_part2/circuit.ml?raw";
import day10Part2Interface from "@hardcaml-examples/aoc/day10_part2/circuit.mli?raw";
import day10Part2Test from "@hardcaml-examples/aoc/day10_part2/test.ml?raw";
import day10Part2Input from "@hardcaml-examples/aoc/day10_part2/input.txt?raw";

// Day 11 Part 1
import day11Part1Circuit from "@hardcaml-examples/aoc/day11_part1/circuit.ml?raw";
import day11Part1Interface from "@hardcaml-examples/aoc/day11_part1/circuit.mli?raw";
import day11Part1Test from "@hardcaml-examples/aoc/day11_part1/test.ml?raw";
import day11Part1Input from "@hardcaml-examples/aoc/day11_part1/input.txt?raw";

// Day 11 Part 2
import day11Part2Circuit from "@hardcaml-examples/aoc/day11_part2/circuit.ml?raw";
import day11Part2Interface from "@hardcaml-examples/aoc/day11_part2/circuit.mli?raw";
import day11Part2Test from "@hardcaml-examples/aoc/day11_part2/test.ml?raw";
import day11Part2Input from "@hardcaml-examples/aoc/day11_part2/input.txt?raw";

// Day 12 Part 1
import day12Part1Circuit from "@hardcaml-examples/aoc/day12_part1/circuit.ml?raw";
import day12Part1Interface from "@hardcaml-examples/aoc/day12_part1/circuit.mli?raw";
import day12Part1Test from "@hardcaml-examples/aoc/day12_part1/test.ml?raw";
import day12Part1Input from "@hardcaml-examples/aoc/day12_part1/input.txt?raw";

// N2T Stubs (exercises) from n2t/stubs/
import n2tNotStub from "@hardcaml-examples/n2t/stubs/not.ml?raw";
import n2tAndStub from "@hardcaml-examples/n2t/stubs/and.ml?raw";
import n2tOrStub from "@hardcaml-examples/n2t/stubs/or.ml?raw";
import n2tXorStub from "@hardcaml-examples/n2t/stubs/xor.ml?raw";
import n2tMuxStub from "@hardcaml-examples/n2t/stubs/mux.ml?raw";
import n2tDmuxStub from "@hardcaml-examples/n2t/stubs/dmux.ml?raw";
import n2tNot16Stub from "@hardcaml-examples/n2t/stubs/not16.ml?raw";
import n2tAnd16Stub from "@hardcaml-examples/n2t/stubs/and16.ml?raw";
import n2tOr16Stub from "@hardcaml-examples/n2t/stubs/or16.ml?raw";
import n2tMux16Stub from "@hardcaml-examples/n2t/stubs/mux16.ml?raw";
import n2tOr8wayStub from "@hardcaml-examples/n2t/stubs/or8way.ml?raw";
import n2tMux4way16Stub from "@hardcaml-examples/n2t/stubs/mux4way16.ml?raw";
import n2tMux8way16Stub from "@hardcaml-examples/n2t/stubs/mux8way16.ml?raw";
import n2tDmux4wayStub from "@hardcaml-examples/n2t/stubs/dmux4way.ml?raw";
import n2tDmux8wayStub from "@hardcaml-examples/n2t/stubs/dmux8way.ml?raw";
import n2tHalfadderStub from "@hardcaml-examples/n2t/stubs/halfadder.ml?raw";
import n2tFulladderStub from "@hardcaml-examples/n2t/stubs/fulladder.ml?raw";
import n2tAdd16Stub from "@hardcaml-examples/n2t/stubs/add16.ml?raw";
import n2tInc16Stub from "@hardcaml-examples/n2t/stubs/inc16.ml?raw";
import n2tAluStub from "@hardcaml-examples/n2t/stubs/alu.ml?raw";
import n2tDffStub from "@hardcaml-examples/n2t/stubs/dff.ml?raw";
import n2tBitStub from "@hardcaml-examples/n2t/stubs/bit.ml?raw";
import n2tRegisterStub from "@hardcaml-examples/n2t/stubs/register.ml?raw";
import n2tRam8Stub from "@hardcaml-examples/n2t/stubs/ram8.ml?raw";
import n2tPcStub from "@hardcaml-examples/n2t/stubs/pc.ml?raw";
import n2tRam64Stub from "@hardcaml-examples/n2t/stubs/ram64.ml?raw";
import n2tRam512Stub from "@hardcaml-examples/n2t/stubs/ram512.ml?raw";
import n2tRam4kStub from "@hardcaml-examples/n2t/stubs/ram4k.ml?raw";
import n2tRam16kStub from "@hardcaml-examples/n2t/stubs/ram16k.ml?raw";
import n2tMemoryStub from "@hardcaml-examples/n2t/stubs/memory.ml?raw";
import n2tCpuStub from "@hardcaml-examples/n2t/stubs/cpu.ml?raw";
import n2tComputerStub from "@hardcaml-examples/n2t/stubs/computer.ml?raw";

// N2T Reference implementations (user-runnable solutions)
import n2tNotImpl from "@hardcaml-examples/n2t/solutions/not.ml?raw";
import n2tAndImpl from "@hardcaml-examples/n2t/solutions/and.ml?raw";
import n2tOrImpl from "@hardcaml-examples/n2t/solutions/or.ml?raw";
import n2tXorImpl from "@hardcaml-examples/n2t/solutions/xor.ml?raw";
import n2tMuxImpl from "@hardcaml-examples/n2t/solutions/mux.ml?raw";
import n2tDmuxImpl from "@hardcaml-examples/n2t/solutions/dmux.ml?raw";
import n2tNot16Impl from "@hardcaml-examples/n2t/solutions/not16.ml?raw";
import n2tAnd16Impl from "@hardcaml-examples/n2t/solutions/and16.ml?raw";
import n2tOr16Impl from "@hardcaml-examples/n2t/solutions/or16.ml?raw";
import n2tMux16Impl from "@hardcaml-examples/n2t/solutions/mux16.ml?raw";
import n2tOr8wayImpl from "@hardcaml-examples/n2t/solutions/or8way.ml?raw";
import n2tMux4way16Impl from "@hardcaml-examples/n2t/solutions/mux4way16.ml?raw";
import n2tMux8way16Impl from "@hardcaml-examples/n2t/solutions/mux8way16.ml?raw";
import n2tDmux4wayImpl from "@hardcaml-examples/n2t/solutions/dmux4way.ml?raw";
import n2tDmux8wayImpl from "@hardcaml-examples/n2t/solutions/dmux8way.ml?raw";
import n2tHalfadderImpl from "@hardcaml-examples/n2t/solutions/halfadder.ml?raw";
import n2tFulladderImpl from "@hardcaml-examples/n2t/solutions/fulladder.ml?raw";
import n2tAdd16Impl from "@hardcaml-examples/n2t/solutions/add16.ml?raw";
import n2tInc16Impl from "@hardcaml-examples/n2t/solutions/inc16.ml?raw";
import n2tAluImpl from "@hardcaml-examples/n2t/solutions/alu.ml?raw";
import n2tDffImpl from "@hardcaml-examples/n2t/solutions/dff.ml?raw";
import n2tBitImpl from "@hardcaml-examples/n2t/solutions/bit.ml?raw";
import n2tRegisterImpl from "@hardcaml-examples/n2t/solutions/register.ml?raw";
import n2tRam8Impl from "@hardcaml-examples/n2t/solutions/ram8.ml?raw";
import n2tPcImpl from "@hardcaml-examples/n2t/solutions/pc.ml?raw";
import n2tRam64Impl from "@hardcaml-examples/n2t/solutions/ram64.ml?raw";
import n2tRam512Impl from "@hardcaml-examples/n2t/solutions/ram512.ml?raw";
import n2tRam4kImpl from "@hardcaml-examples/n2t/solutions/ram4k.ml?raw";
import n2tRam16kImpl from "@hardcaml-examples/n2t/solutions/ram16k.ml?raw";
import n2tMemoryImpl from "@hardcaml-examples/n2t/solutions/memory.ml?raw";
import n2tCpuImpl from "@hardcaml-examples/n2t/solutions/cpu.ml?raw";
import n2tComputerImpl from "@hardcaml-examples/n2t/solutions/computer.ml?raw";

// N2T interfaces and tests from lib/n2t_chips/
import n2tNotInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/not.mli?raw";
import n2tNotTest from "@hardcaml-examples/build-cache/lib/n2t_chips/not_test.ml?raw";
import n2tAndInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/and.mli?raw";
import n2tAndTest from "@hardcaml-examples/build-cache/lib/n2t_chips/and_test.ml?raw";
import n2tOrInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/or.mli?raw";
import n2tOrTest from "@hardcaml-examples/build-cache/lib/n2t_chips/or_test.ml?raw";
import n2tXorInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/xor.mli?raw";
import n2tXorTest from "@hardcaml-examples/build-cache/lib/n2t_chips/xor_test.ml?raw";
import n2tMuxInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/mux.mli?raw";
import n2tMuxTest from "@hardcaml-examples/build-cache/lib/n2t_chips/mux_test.ml?raw";
import n2tDmuxInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/dmux.mli?raw";
import n2tDmuxTest from "@hardcaml-examples/build-cache/lib/n2t_chips/dmux_test.ml?raw";
import n2tNot16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/not16.mli?raw";
import n2tNot16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/not16_test.ml?raw";
import n2tAnd16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/and16.mli?raw";
import n2tAnd16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/and16_test.ml?raw";
import n2tOr16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/or16.mli?raw";
import n2tOr16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/or16_test.ml?raw";
import n2tMux16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/mux16.mli?raw";
import n2tMux16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/mux16_test.ml?raw";
import n2tOr8wayInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/or8way.mli?raw";
import n2tOr8wayTest from "@hardcaml-examples/build-cache/lib/n2t_chips/or8way_test.ml?raw";
import n2tMux4way16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/mux4way16.mli?raw";
import n2tMux4way16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/mux4way16_test.ml?raw";
import n2tMux8way16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/mux8way16.mli?raw";
import n2tMux8way16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/mux8way16_test.ml?raw";
import n2tDmux4wayInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/dmux4way.mli?raw";
import n2tDmux4wayTest from "@hardcaml-examples/build-cache/lib/n2t_chips/dmux4way_test.ml?raw";
import n2tDmux8wayInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/dmux8way.mli?raw";
import n2tDmux8wayTest from "@hardcaml-examples/build-cache/lib/n2t_chips/dmux8way_test.ml?raw";
import n2tHalfadderInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/halfadder.mli?raw";
import n2tHalfadderTest from "@hardcaml-examples/build-cache/lib/n2t_chips/halfadder_test.ml?raw";
import n2tFulladderInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/fulladder.mli?raw";
import n2tFulladderTest from "@hardcaml-examples/build-cache/lib/n2t_chips/fulladder_test.ml?raw";
import n2tAdd16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/add16.mli?raw";
import n2tAdd16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/add16_test.ml?raw";
import n2tInc16Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/inc16.mli?raw";
import n2tInc16Test from "@hardcaml-examples/build-cache/lib/n2t_chips/inc16_test.ml?raw";
import n2tAluInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/alu.mli?raw";
import n2tAluTest from "@hardcaml-examples/build-cache/lib/n2t_chips/alu_test.ml?raw";
import n2tDffInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/dff.mli?raw";
import n2tDffTest from "@hardcaml-examples/build-cache/lib/n2t_chips/dff_test.ml?raw";
import n2tBitInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/bit.mli?raw";
import n2tBitTest from "@hardcaml-examples/build-cache/lib/n2t_chips/bit_test.ml?raw";
import n2tRegisterInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/register.mli?raw";
import n2tRegisterTest from "@hardcaml-examples/build-cache/lib/n2t_chips/register_test.ml?raw";
import n2tRam8Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/ram8.mli?raw";
import n2tRam8Test from "@hardcaml-examples/build-cache/lib/n2t_chips/ram8_test.ml?raw";
import n2tPcInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/pc.mli?raw";
import n2tPcTest from "@hardcaml-examples/build-cache/lib/n2t_chips/pc_test.ml?raw";
import n2tRam64Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/ram64.mli?raw";
import n2tRam64Test from "@hardcaml-examples/build-cache/lib/n2t_chips/ram64_test.ml?raw";
import n2tRam512Interface from "@hardcaml-examples/build-cache/lib/n2t_chips/ram512.mli?raw";
import n2tRam512Test from "@hardcaml-examples/build-cache/lib/n2t_chips/ram512_test.ml?raw";
import n2tRam4kInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/ram4k.mli?raw";
import n2tRam4kTest from "@hardcaml-examples/build-cache/lib/n2t_chips/ram4k_test.ml?raw";
import n2tRam16kInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/ram16k.mli?raw";
import n2tRam16kTest from "@hardcaml-examples/build-cache/lib/n2t_chips/ram16k_test.ml?raw";
import n2tMemoryInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/memory.mli?raw";
import n2tMemoryTest from "@hardcaml-examples/build-cache/lib/n2t_chips/memory_test.ml?raw";
import n2tCpuInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/cpu.mli?raw";
import n2tCpuTest from "@hardcaml-examples/build-cache/lib/n2t_chips/cpu_test.ml?raw";
import n2tComputerInterface from "@hardcaml-examples/build-cache/lib/n2t_chips/computer.mli?raw";
import n2tComputerTest from "@hardcaml-examples/build-cache/lib/n2t_chips/computer_test.ml?raw";

// Types

export type ExampleCategory = "ocaml_basics" | "hardcaml" | "playground" | "advent" | "n2t" | "n2t_solutions";

export const categoryLabels: Record<ExampleCategory, string> = {
  ocaml_basics: "Hardcaml Basics",
  hardcaml: "Hardcaml Examples",
  playground: "Playground",
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
  | "nand"
  | "types"
  | "modules"
  | "patterns"
  | "operators"
  | "day1_part1"
  | "day1_part2"
  | "day2_part1"
  | "day2_part2"
  | "day3_part1"
  | "day3_part2"
  | "day4_part1"
  | "day4_part2"
  | "day5_part1"
  | "day5_part2"
  | "day6_part1"
  | "day6_part2"
  | "day7_part1"
  | "day7_part2"
  | "day8_part1"
  | "day8_part2"
  | "day9_part1"
  | "day9_part2"
  | "day10_part1"
  | "day10_part2"
  | "day11_part1"
  | "day11_part2"
  | "day12_part1"
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
  | "n2t_dff"
  | "n2t_bit"
  | "n2t_register"
  | "n2t_ram8"
  | "n2t_pc"
  | "n2t_ram64"
  | "n2t_ram512"
  | "n2t_ram4k"
  | "n2t_ram16k"
  | "n2t_memory"
  | "n2t_cpu"
  | "n2t_computer"
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
  | "n2t_alu_solution"
  | "n2t_dff_solution"
  | "n2t_bit_solution"
  | "n2t_register_solution"
  | "n2t_ram8_solution"
  | "n2t_pc_solution"
  | "n2t_ram64_solution"
  | "n2t_ram512_solution"
  | "n2t_ram4k_solution"
  | "n2t_ram16k_solution"
  | "n2t_memory_solution"
  | "n2t_cpu_solution"
  | "n2t_computer_solution"
  | "oxcaml_playground"
  | "hardcaml_playground";

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

const helloNandExample: HardcamlExample = {
  name: "Hello Nand Gate",
  description:
    "Your first Hardcaml circuit! A simple NAND gate - the fundamental building block of digital logic",
  difficulty: "beginner",
  category: "ocaml_basics",
  circuit: helloNandCircuit,
  interface: helloNandInterface,
  test: helloNandTest,
};

const helloTypesExample: HardcamlExample = {
  name: "Types",
  description:
    "Learn basic OCaml types, functions, and records with a simple pass-through circuit",
  difficulty: "beginner",
  category: "ocaml_basics",
  circuit: helloTypesCircuit,
  interface: helloTypesInterface,
  test: helloTypesTest,
};

const helloModulesExample: HardcamlExample = {
  name: "Modules",
  description:
    "Learn OCaml modules, struct, sig, and open! with an AND gate circuit",
  difficulty: "beginner",
  category: "ocaml_basics",
  circuit: helloModulesCircuit,
  interface: helloModulesInterface,
  test: helloModulesTest,
};

const helloPatternsExample: HardcamlExample = {
  name: "Patterns",
  description:
    "Learn pattern matching and record destructuring with a multiplexer circuit",
  difficulty: "beginner",
  category: "ocaml_basics",
  circuit: helloPatternsCircuit,
  interface: helloPatternsInterface,
  test: helloPatternsTest,
};

const helloOperatorsExample: HardcamlExample = {
  name: "Operators",
  description:
    "Learn Hardcaml infix operators (AND, OR, XOR, NOT, addition, equality) with a combinational logic circuit",
  difficulty: "beginner",
  category: "ocaml_basics",
  circuit: helloOperatorsCircuit,
  interface: helloOperatorsInterface,
  test: helloOperatorsTest,
};

const oxcamlPlaygroundExample: HardcamlExample = {
  name: "Oxcaml Playground",
  description:
    "A simple OCaml playground where you can experiment with OCaml features, data structures, algorithms, and more",
  difficulty: "beginner",
  category: "playground",
  circuit: oxcamlPlaygroundMain,
  circuitFilename: "main.ml",
  interface: oxcamlPlaygroundInterface,
  interfaceFilename: "main.mli",
  test: oxcamlPlaygroundTest,
};

const hardcamlPlaygroundExample: HardcamlExample = {
  name: "Hardcaml Playground",
  description:
    "A Hardcaml playground with a circuit and test file. Experiment with different Hardcaml features and create your own circuits",
  difficulty: "beginner",
  category: "playground",
  circuit: hardcamlPlaygroundCircuit,
  interface: hardcamlPlaygroundInterface,
  test: hardcamlPlaygroundTest,
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

const day2Part1Example: HardcamlExample = {
  name: "AoC Day 2 Part 1",
  description:
    "Find numbers in ranges where the digit count is even and the first half equals the second half",
  difficulty: "intermediate",
  category: "advent",
  circuit: day2Part1Circuit,
  interface: day2Part1Interface,
  test: day2Part1Test,
  input: day2Part1Input,
};

const day2Part2Example: HardcamlExample = {
  name: "AoC Day 2 Part 2",
  description:
    "Find numbers in ranges where any repeating pattern of digits exists",
  difficulty: "advanced",
  category: "advent",
  circuit: day2Part2Circuit,
  interface: day2Part2Interface,
  test: day2Part2Test,
  input: day2Part2Input,
};

const day3Part1Example: HardcamlExample = {
  name: "AoC Day 3 Part 1",
  description: "TODO: Implement Day 3 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day3Part1Circuit,
  interface: day3Part1Interface,
  test: day3Part1Test,
  input: day3Part1Input,
};

const day3Part2Example: HardcamlExample = {
  name: "AoC Day 3 Part 2",
  description: "TODO: Implement Day 3 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day3Part2Circuit,
  interface: day3Part2Interface,
  test: day3Part2Test,
  input: day3Part2Input,
};

const day4Part1Example: HardcamlExample = {
  name: "AoC Day 4 Part 1",
  description: "TODO: Implement Day 4 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day4Part1Circuit,
  interface: day4Part1Interface,
  test: day4Part1Test,
  input: day4Part1Input,
};

const day4Part2Example: HardcamlExample = {
  name: "AoC Day 4 Part 2",
  description: "TODO: Implement Day 4 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day4Part2Circuit,
  interface: day4Part2Interface,
  test: day4Part2Test,
  input: day4Part2Input,
};

const day5Part1Example: HardcamlExample = {
  name: "AoC Day 5 Part 1",
  description: "TODO: Implement Day 5 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day5Part1Circuit,
  interface: day5Part1Interface,
  test: day5Part1Test,
  input: day5Part1Input,
};

const day5Part2Example: HardcamlExample = {
  name: "AoC Day 5 Part 2",
  description: "TODO: Implement Day 5 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day5Part2Circuit,
  interface: day5Part2Interface,
  test: day5Part2Test,
  input: day5Part2Input,
};

const day6Part1Example: HardcamlExample = {
  name: "AoC Day 6 Part 1",
  description: "TODO: Implement Day 6 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day6Part1Circuit,
  interface: day6Part1Interface,
  test: day6Part1Test,
  input: day6Part1Input,
};

const day6Part2Example: HardcamlExample = {
  name: "AoC Day 6 Part 2",
  description: "TODO: Implement Day 6 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day6Part2Circuit,
  interface: day6Part2Interface,
  test: day6Part2Test,
  input: day6Part2Input,
};

const day7Part1Example: HardcamlExample = {
  name: "AoC Day 7 Part 1",
  description: "TODO: Implement Day 7 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day7Part1Circuit,
  interface: day7Part1Interface,
  test: day7Part1Test,
  input: day7Part1Input,
};

const day7Part2Example: HardcamlExample = {
  name: "AoC Day 7 Part 2",
  description: "TODO: Implement Day 7 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day7Part2Circuit,
  interface: day7Part2Interface,
  test: day7Part2Test,
  input: day7Part2Input,
};

const day8Part1Example: HardcamlExample = {
  name: "AoC Day 8 Part 1",
  description: "TODO: Implement Day 8 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day8Part1Circuit,
  interface: day8Part1Interface,
  test: day8Part1Test,
  input: day8Part1Input,
};

const day8Part2Example: HardcamlExample = {
  name: "AoC Day 8 Part 2",
  description: "TODO: Implement Day 8 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day8Part2Circuit,
  interface: day8Part2Interface,
  test: day8Part2Test,
  input: day8Part2Input,
};

const day9Part1Example: HardcamlExample = {
  name: "AoC Day 9 Part 1",
  description: "TODO: Implement Day 9 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day9Part1Circuit,
  interface: day9Part1Interface,
  test: day9Part1Test,
  input: day9Part1Input,
};

const day9Part2Example: HardcamlExample = {
  name: "AoC Day 9 Part 2",
  description: "TODO: Implement Day 9 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day9Part2Circuit,
  interface: day9Part2Interface,
  test: day9Part2Test,
  input: day9Part2Input,
};

const day10Part1Example: HardcamlExample = {
  name: "AoC Day 10 Part 1",
  description: "TODO: Implement Day 10 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day10Part1Circuit,
  interface: day10Part1Interface,
  test: day10Part1Test,
  input: day10Part1Input,
};

const day10Part2Example: HardcamlExample = {
  name: "AoC Day 10 Part 2",
  description: "TODO: Implement Day 10 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day10Part2Circuit,
  interface: day10Part2Interface,
  test: day10Part2Test,
  input: day10Part2Input,
};

const day11Part1Example: HardcamlExample = {
  name: "AoC Day 11 Part 1",
  description: "TODO: Implement Day 11 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day11Part1Circuit,
  interface: day11Part1Interface,
  test: day11Part1Test,
  input: day11Part1Input,
};

const day11Part2Example: HardcamlExample = {
  name: "AoC Day 11 Part 2",
  description: "TODO: Implement Day 11 Part 2",
  difficulty: "intermediate",
  category: "advent",
  circuit: day11Part2Circuit,
  interface: day11Part2Interface,
  test: day11Part2Test,
  input: day11Part2Input,
};

const day12Part1Example: HardcamlExample = {
  name: "AoC Day 12 Part 1",
  description: "TODO: Implement Day 12 Part 1",
  difficulty: "intermediate",
  category: "advent",
  circuit: day12Part1Circuit,
  interface: day12Part1Interface,
  test: day12Part1Test,
  input: day12Part1Input,
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

const n2tDffExample: HardcamlExample = {
  name: "DFF",
  description: "D Flip-Flop - stores a single bit (out = previous in)",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tDffStub,
  circuitFilename: "dff.ml",
  interface: n2tDffInterface,
  interfaceFilename: "dff.mli",
  test: n2tDffTest,
};

const n2tBitExample: HardcamlExample = {
  name: "Bit",
  description: "1-bit register with load enable",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tBitStub,
  circuitFilename: "bit.ml",
  interface: n2tBitInterface,
  interfaceFilename: "bit.mli",
  test: n2tBitTest,
};

const n2tRegisterExample: HardcamlExample = {
  name: "Register",
  description: "16-bit register with load enable",
  difficulty: "beginner",
  category: "n2t",
  circuit: n2tRegisterStub,
  circuitFilename: "register.ml",
  interface: n2tRegisterInterface,
  interfaceFilename: "register.mli",
  test: n2tRegisterTest,
};

const n2tRam8Example: HardcamlExample = {
  name: "RAM8",
  description: "Memory of 8 16-bit registers",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tRam8Stub,
  circuitFilename: "ram8.ml",
  interface: n2tRam8Interface,
  interfaceFilename: "ram8.mli",
  test: n2tRam8Test,
};

const n2tPcExample: HardcamlExample = {
  name: "PC",
  description: "16-bit Program Counter with reset/load/inc",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tPcStub,
  circuitFilename: "pc.ml",
  interface: n2tPcInterface,
  interfaceFilename: "pc.mli",
  test: n2tPcTest,
};

const n2tRam64Example: HardcamlExample = {
  name: "RAM64",
  description: "Memory of 64 16-bit registers",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tRam64Stub,
  circuitFilename: "ram64.ml",
  interface: n2tRam64Interface,
  interfaceFilename: "ram64.mli",
  test: n2tRam64Test,
};

const n2tRam512Example: HardcamlExample = {
  name: "RAM512",
  description: "Memory of 512 16-bit registers",
  difficulty: "intermediate",
  category: "n2t",
  circuit: n2tRam512Stub,
  circuitFilename: "ram512.ml",
  interface: n2tRam512Interface,
  interfaceFilename: "ram512.mli",
  test: n2tRam512Test,
};

const n2tRam4kExample: HardcamlExample = {
  name: "RAM4K",
  description: "Memory of 4096 16-bit registers",
  difficulty: "advanced",
  category: "n2t",
  circuit: n2tRam4kStub,
  circuitFilename: "ram4k.ml",
  interface: n2tRam4kInterface,
  interfaceFilename: "ram4k.mli",
  test: n2tRam4kTest,
};

const n2tRam16kExample: HardcamlExample = {
  name: "RAM16K",
  description: "Memory of 16384 16-bit registers",
  difficulty: "advanced",
  category: "n2t",
  circuit: n2tRam16kStub,
  circuitFilename: "ram16k.ml",
  interface: n2tRam16kInterface,
  interfaceFilename: "ram16k.mli",
  test: n2tRam16kTest,
};

const n2tMemoryExample: HardcamlExample = {
  name: "Memory",
  description: "Complete Hack memory: RAM16K + Screen + Keyboard",
  difficulty: "advanced",
  category: "n2t",
  circuit: n2tMemoryStub,
  circuitFilename: "memory.ml",
  interface: n2tMemoryInterface,
  interfaceFilename: "memory.mli",
  test: n2tMemoryTest,
};

const n2tCpuExample: HardcamlExample = {
  name: "CPU",
  description: "The Hack Central Processing Unit",
  difficulty: "advanced",
  category: "n2t",
  circuit: n2tCpuStub,
  circuitFilename: "cpu.ml",
  interface: n2tCpuInterface,
  interfaceFilename: "cpu.mli",
  test: n2tCpuTest,
};

const n2tComputerExample: HardcamlExample = {
  name: "Computer",
  description: "The complete Hack computer: CPU + ROM + Memory",
  difficulty: "advanced",
  category: "n2t",
  circuit: n2tComputerStub,
  circuitFilename: "computer.ml",
  interface: n2tComputerInterface,
  interfaceFilename: "computer.mli",
  test: n2tComputerTest,
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

const n2tDffSolutionExample: HardcamlExample = {
  name: "DFF",
  description: "Reference implementation of D Flip-Flop",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tDffImpl,
  circuitFilename: "dff.ml",
  interface: n2tDffInterface,
  interfaceFilename: "dff.mli",
  test: n2tDffTest,
};

const n2tBitSolutionExample: HardcamlExample = {
  name: "Bit",
  description: "Reference implementation of 1-bit register",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tBitImpl,
  circuitFilename: "bit.ml",
  interface: n2tBitInterface,
  interfaceFilename: "bit.mli",
  test: n2tBitTest,
};

const n2tRegisterSolutionExample: HardcamlExample = {
  name: "Register",
  description: "Reference implementation of 16-bit register",
  difficulty: "beginner",
  category: "n2t_solutions",
  circuit: n2tRegisterImpl,
  circuitFilename: "register.ml",
  interface: n2tRegisterInterface,
  interfaceFilename: "register.mli",
  test: n2tRegisterTest,
};

const n2tRam8SolutionExample: HardcamlExample = {
  name: "RAM8",
  description: "Reference implementation of RAM8",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tRam8Impl,
  circuitFilename: "ram8.ml",
  interface: n2tRam8Interface,
  interfaceFilename: "ram8.mli",
  test: n2tRam8Test,
};

const n2tPcSolutionExample: HardcamlExample = {
  name: "PC",
  description: "Reference implementation of Program Counter",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tPcImpl,
  circuitFilename: "pc.ml",
  interface: n2tPcInterface,
  interfaceFilename: "pc.mli",
  test: n2tPcTest,
};

const n2tRam64SolutionExample: HardcamlExample = {
  name: "RAM64",
  description: "Reference implementation of RAM64",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tRam64Impl,
  circuitFilename: "ram64.ml",
  interface: n2tRam64Interface,
  interfaceFilename: "ram64.mli",
  test: n2tRam64Test,
};

const n2tRam512SolutionExample: HardcamlExample = {
  name: "RAM512",
  description: "Reference implementation of RAM512",
  difficulty: "intermediate",
  category: "n2t_solutions",
  circuit: n2tRam512Impl,
  circuitFilename: "ram512.ml",
  interface: n2tRam512Interface,
  interfaceFilename: "ram512.mli",
  test: n2tRam512Test,
};

const n2tRam4kSolutionExample: HardcamlExample = {
  name: "RAM4K",
  description: "Reference implementation of RAM4K",
  difficulty: "advanced",
  category: "n2t_solutions",
  circuit: n2tRam4kImpl,
  circuitFilename: "ram4k.ml",
  interface: n2tRam4kInterface,
  interfaceFilename: "ram4k.mli",
  test: n2tRam4kTest,
};

const n2tRam16kSolutionExample: HardcamlExample = {
  name: "RAM16K",
  description: "Reference implementation of RAM16K",
  difficulty: "advanced",
  category: "n2t_solutions",
  circuit: n2tRam16kImpl,
  circuitFilename: "ram16k.ml",
  interface: n2tRam16kInterface,
  interfaceFilename: "ram16k.mli",
  test: n2tRam16kTest,
};

const n2tMemorySolutionExample: HardcamlExample = {
  name: "Memory",
  description: "Reference implementation of Hack Memory",
  difficulty: "advanced",
  category: "n2t_solutions",
  circuit: n2tMemoryImpl,
  circuitFilename: "memory.ml",
  interface: n2tMemoryInterface,
  interfaceFilename: "memory.mli",
  test: n2tMemoryTest,
};

const n2tCpuSolutionExample: HardcamlExample = {
  name: "CPU",
  description: "Reference implementation of Hack CPU",
  difficulty: "advanced",
  category: "n2t_solutions",
  circuit: n2tCpuImpl,
  circuitFilename: "cpu.ml",
  interface: n2tCpuInterface,
  interfaceFilename: "cpu.mli",
  test: n2tCpuTest,
};

const n2tComputerSolutionExample: HardcamlExample = {
  name: "Computer",
  description: "Reference implementation of Hack Computer",
  difficulty: "advanced",
  category: "n2t_solutions",
  circuit: n2tComputerImpl,
  circuitFilename: "computer.ml",
  interface: n2tComputerInterface,
  interfaceFilename: "computer.mli",
  test: n2tComputerTest,
};

// Registry and helpers

export const examples: Record<ExampleKey, HardcamlExample> = {
  counter: counterExample,
  fibonacci: fibonacciExample,
  nand: helloNandExample,
  types: helloTypesExample,
  modules: helloModulesExample,
  patterns: helloPatternsExample,
  operators: helloOperatorsExample,
  oxcaml_playground: oxcamlPlaygroundExample,
  hardcaml_playground: hardcamlPlaygroundExample,
  day1_part1: day1Part1Example,
  day1_part2: day1Part2Example,
  day2_part1: day2Part1Example,
  day2_part2: day2Part2Example,
  day3_part1: day3Part1Example,
  day3_part2: day3Part2Example,
  day4_part1: day4Part1Example,
  day4_part2: day4Part2Example,
  day5_part1: day5Part1Example,
  day5_part2: day5Part2Example,
  day6_part1: day6Part1Example,
  day6_part2: day6Part2Example,
  day7_part1: day7Part1Example,
  day7_part2: day7Part2Example,
  day8_part1: day8Part1Example,
  day8_part2: day8Part2Example,
  day9_part1: day9Part1Example,
  day9_part2: day9Part2Example,
  day10_part1: day10Part1Example,
  day10_part2: day10Part2Example,
  day11_part1: day11Part1Example,
  day11_part2: day11Part2Example,
  day12_part1: day12Part1Example,
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
  n2t_dff: n2tDffExample,
  n2t_bit: n2tBitExample,
  n2t_register: n2tRegisterExample,
  n2t_ram8: n2tRam8Example,
  n2t_pc: n2tPcExample,
  n2t_ram64: n2tRam64Example,
  n2t_ram512: n2tRam512Example,
  n2t_ram4k: n2tRam4kExample,
  n2t_ram16k: n2tRam16kExample,
  n2t_memory: n2tMemoryExample,
  n2t_cpu: n2tCpuExample,
  n2t_computer: n2tComputerExample,
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
  n2t_dff_solution: n2tDffSolutionExample,
  n2t_bit_solution: n2tBitSolutionExample,
  n2t_register_solution: n2tRegisterSolutionExample,
  n2t_ram8_solution: n2tRam8SolutionExample,
  n2t_pc_solution: n2tPcSolutionExample,
  n2t_ram64_solution: n2tRam64SolutionExample,
  n2t_ram512_solution: n2tRam512SolutionExample,
  n2t_ram4k_solution: n2tRam4kSolutionExample,
  n2t_ram16k_solution: n2tRam16kSolutionExample,
  n2t_memory_solution: n2tMemorySolutionExample,
  n2t_cpu_solution: n2tCpuSolutionExample,
  n2t_computer_solution: n2tComputerSolutionExample,
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
    ocaml_basics: [],
    hardcaml: [],
    advent: [],
    n2t: [],
    n2t_solutions: [],
    playground: [],
  };

  for (const key of getExampleKeys()) {
    const example = examples[key];
    grouped[example.category].push({ key, example });
  }

  return grouped;
};
