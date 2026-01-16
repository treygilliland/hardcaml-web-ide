# Advent of FPGA

This repo contains my submission for [Jane Street's Advent of FPGA](https://blog.janestreet.com/advent-of-fpga-challenge-2025/).

As someone relatively new to FPGAs/HDLs and Ocaml, this was super fun to try and work through.

I was able to implement solutions for Day 1, 2, and 12, and instructions for running them can be found in this guide.

## Solutions

Each solution is a standalone dune project in `hardcaml/aoc/`:

- `hardcaml/aoc/day1_part1/`
- `hardcaml/aoc/day1_part2/`
- `hardcaml/aoc/day2_part1/`
- `hardcaml/aoc/day2_part2/`
- `hardcaml/aoc/day12_part1/`

Each directory contains:

- **circuit.ml**: The main circuit implementation
- **circuit.mli**: The module interface defining I/O
- **test.ml**: The test harness with expect tests
- **input.txt**: The puzzle input data
- **harness_utils.ml**: Test utilities
- **dune-project**: Dune project configuration
- **dune**: Dune build configuration

> NOTE: The solutions for other days are currently placeholders for future implementation.

## Method 1: Web IDE

The easiest way to view and run the solutions is through the Hardcaml Web IDE.

You can use the production version at `ide.hardcaml.tg3.dev/ide` OR run it yourself from this directory with `make dev` / `make up`.

### Running a Solution

1. In the IDE sidebar, expand the **"Advent of Code/FPGA"** section to see the solutions.

2. Select one of the solutions in the **"Completed"** section.

3. Click the **"Run"** button to compile and simulate the circuit.

4. View the results:

   - **Waveform**: ASCII visualization of signal values over time
   - **Output**: Test results showing passed/failed tests and the final answer

5. You can try out other inputs by editing `input.txt` and updating the expected answer in `test.ml`!

## Method 2: Direct OCaml (Local)

If you have OCaml, opam, and dune installed locally, you can run the solutions directly.
You can also use the `Dockerfile.backend.base` for the toolchain if you don't want to install on your local.

> I followed the installation instructions [here](https://github.com/janestreet/hardcaml_template_project/tree/with-extensions).

### Prerequisites

- OCaml (5.x recommended)
- opam package manager
- dune build system
- Hardcaml and dependencies installed via opam

### Install Dependencies

```bash
opam install hardcaml hardcaml-waveterm hardcaml-test-harness core
```

### Running a Solution

Each solution directory is a standalone dune project. Simply navigate to the directory and run dune:

```bash
# Run day1_part1
cd hardcaml/aoc/day1_part1
dune build @runtest

# Run day1_part2
cd hardcaml/aoc/day1_part2
dune build @runtest

# Run day2_part1
cd hardcaml/aoc/day2_part1
dune build @runtest

# Run day2_part2
cd hardcaml/aoc/day2_part2
dune build @runtest

# Run day12_part1
cd hardcaml/aoc/day12_part1
dune build @runtest
```

The test harness reads `input.txt` automatically, so you can modify the input file and re-run tests without changing any code.

### Project Structure

Each solution uses a flat directory structure:

```
day1_part1/
├── circuit.ml          # Circuit implementation
├── circuit.mli         # Circuit interface
├── test.ml             # Test harness (reads input.txt)
├── generate_verilog.ml # Verilog generation script
├── input.txt           # Input data
├── harness_utils.ml    # Test utilities
├── dune-project        # Dune project file
└── dune                # Dune build configuration
```

All files for a solution are in the root directory. The test harness automatically reads `input.txt` from the same directory.

**Note**: Dune automatically wraps `circuit.ml` into `User_circuit.Circuit` module, so `test.ml` can use `module Circuit = User_circuit.Circuit` without any wrapper code in `circuit.ml`.

## Understanding the Output

All methods produce similar output:

- **Waveform**: ASCII visualization between `===WAVEFORM_START===` and `===WAVEFORM_END===`
- **Test Summary**: Final count of passed/failed tests after `===TEST_SUMMARY===`
- **Final Answer**: The solution to the Advent of Code puzzle (displayed in test output)

> For all of the AoC solutions, the waveform will be too narrow to show anything meaningful. You can modify the tests to make it wider as needed.

## Generating Verilog (Optional)

Each solution can generate Verilog RTL. For example, to generate Verilog for day1_part1:

```bash
cd hardcaml/aoc/day1_part1
dune build generate_verilog.exe
dune exec ./generate_verilog.exe
```

This generates `day1_part1.v` containing the Verilog code.

I have not tested this code or synthesized it myself, but would love to at some point!

## Troubleshooting

### Web IDE Issues

- Ensure services are running: `make dev`
- Check browser console for errors
- Verify backend is accessible at `localhost:8000`

### Dune Issues

- Ensure you're in the correct solution directory (e.g., `hardcaml/aoc/day1_part1`)
- Check that dependencies are installed: `opam install hardcaml hardcaml-waveterm hardcaml-test-harness core`
- Check dune output for compilation errors

### Verilog Generation Issues

- Ensure the circuit library builds successfully: `dune build`
- Verify `generate_verilog.ml` exists in the solution directory
- Check that the generated `.v` file is created in the current directory (not `_build/`)

## Additional Resources

- **Project README**: See [`README.md`](README.md) for project overview
- **Hardcaml README**: See [`hardcaml/README.md`](hardcaml/README.md) for OCaml development details
- **Hardcaml Documentation**: [Jane Street Hardcaml](https://github.com/janestreet/hardcaml)
