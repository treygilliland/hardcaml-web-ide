# Advent of FPGA

Advent of Code solutions implemented in Hardcaml (Day 1, Day 2, Day 12).

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

## Method 1: Web IDE

The easiest way to view and run the solutions is through the Hardcaml Web IDE.

You can view the production version at `ide.hardcaml.tg3.dev/ide` OR run it yourself from this directory with `make dev`.

### Running a Solution

1. In the IDE sidebar, expand the **"Advent of Code/FPGA"** section to see the solutions.

2. Select one of the solutions in the **"Completed"** section.

3. Click the **"Run"** button to compile and simulate the circuit.

4. View the results:

   - **Waveform**: ASCII visualization of signal values over time
   - **Output**: Test results showing passed/failed tests and the final answer

5. Try out other inputs by editing `input.txt` and updating the expected answer in `test.ml`!

## Method 2: Direct OCaml (Local)

If you have OCaml, opam, and dune installed locally, you can run the solutions directly.

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
├── input.txt           # Input data
├── harness_utils.ml    # Test utilities
├── dune-project        # Dune project file
└── dune                # Dune build configuration
```

All files for a solution are in the root directory. The test harness automatically reads `input.txt` from the same directory.

**Note**: Dune automatically wraps `circuit.ml` into `User_circuit.Circuit` module, so `test.ml` can use `module Circuit = User_circuit.Circuit` without any wrapper code in `circuit.ml`.

## Understanding the Output

All methods produce similar output:

- **PASS/FAIL lines**: Individual test assertions
- **Waveform**: ASCII visualization between `===WAVEFORM_START===` and `===WAVEFORM_END===`
- **Test Summary**: Final count of passed/failed tests after `===TEST_SUMMARY===`
- **Final Answer**: The solution to the Advent of Code puzzle (displayed in test output)

## Troubleshooting

### Web IDE Issues

- Ensure services are running: `make dev`
- Check browser console for errors
- Verify backend is accessible at `localhost:8000`

### Dune Issues

- Ensure you're in the correct solution directory (e.g., `hardcaml/aoc/day1_part1`)
- Check that dependencies are installed: `opam install hardcaml hardcaml-waveterm hardcaml-test-harness core`
- Check dune output for compilation errors
- Ensure `input.txt` exists in the solution directory (it's automatically copied to the test directory during build)

## Additional Resources

- **Project README**: See [`README.md`](README.md) for project overview
- **Hardcaml README**: See [`hardcaml/README.md`](hardcaml/README.md) for OCaml development details
- **Hardcaml Documentation**: [Jane Street Hardcaml](https://github.com/janestreet/hardcaml)
