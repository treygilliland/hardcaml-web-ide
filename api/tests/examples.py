"""
Manifest of testable HardCaml examples.

Loads example files from disk for use in both dune tests and API tests.
Only includes "solution" examples that should pass - excludes incomplete stubs.
"""

from dataclasses import dataclass
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
HARDCAML_DIR = PROJECT_ROOT / "hardcaml"
EXAMPLES_DIR = HARDCAML_DIR / "examples"
AOC_DIR = HARDCAML_DIR / "aoc"
N2T_DIR = HARDCAML_DIR / "n2t"
BUILD_CACHE_DIR = HARDCAML_DIR / "build-cache"
N2T_CHIPS_DIR = BUILD_CACHE_DIR / "lib" / "n2t_chips"


@dataclass
class Example:
    id: str
    name: str
    files: dict[str, str]
    circuit_filename: str = "circuit.ml"
    interface_filename: str = "circuit.mli"


def load_file(path: Path) -> str:
    return path.read_text()


def load_standard_example(example_id: str) -> Example:
    """Load a standard example with circuit.ml, circuit.mli, test.ml structure."""
    example_dir = EXAMPLES_DIR / example_id
    if not example_dir.exists():
        example_dir = AOC_DIR / example_id
    files = {
        "circuit.ml": load_file(example_dir / "circuit.ml"),
        "circuit.mli": load_file(example_dir / "circuit.mli"),
        "test.ml": load_file(example_dir / "test.ml"),
    }
    input_file = example_dir / "input.txt"
    if input_file.exists():
        input_data = load_file(input_file)
        files["input.txt"] = input_data
        files["test.ml"] = files["test.ml"].replace("INPUT_DATA", input_data)

    return Example(id=example_id, name=example_id, files=files)


def load_n2t_solution(chip_name: str) -> Example:
    """Load an N2T solution example with its test from build-cache."""
    solution_file = N2T_DIR / "solutions" / f"{chip_name}.ml"
    interface_file = N2T_CHIPS_DIR / f"{chip_name}.mli"
    test_file = N2T_CHIPS_DIR / f"{chip_name}_test.ml"

    files = {
        f"{chip_name}.ml": load_file(solution_file),
        f"{chip_name}.mli": load_file(interface_file),
        "test.ml": load_file(test_file),
    }

    return Example(
        id=f"n2t_{chip_name}",
        name=f"N2T {chip_name}",
        files=files,
        circuit_filename=f"{chip_name}.ml",
        interface_filename=f"{chip_name}.mli",
    )


N2T_CHIPS = [
    # Project 1: Boolean Logic
    "not",
    "and",
    "or",
    "xor",
    "mux",
    "dmux",
    "not16",
    "and16",
    "or16",
    "mux16",
    "or8way",
    "mux4way16",
    "mux8way16",
    "dmux4way",
    "dmux8way",
    # Project 2: Boolean Arithmetic
    "halfadder",
    "fulladder",
    "add16",
    "inc16",
    "alu",
    # Project 3: Sequential Logic
    "dff",
    "bit",
    "register",
    "ram8",
    "ram64",
    "ram512",
    "ram4k",
    "ram16k",
    "pc",
    # Project 5: Computer Architecture
    "memory",
    "cpu",
    "computer",
]

STANDARD_EXAMPLES = [
    "counter",
    "fibonacci",
    "day1_part1",
    "day1_part2",
    "day2_part1",
    "day2_part2",
]


def get_all_testable_examples() -> list[Example]:
    """Get all examples that should pass tests."""
    examples = []

    for example_id in STANDARD_EXAMPLES:
        examples.append(load_standard_example(example_id))

    for chip_name in N2T_CHIPS:
        examples.append(load_n2t_solution(chip_name))

    return examples


def get_example_ids() -> list[str]:
    """Get list of all testable example IDs for pytest parametrization."""
    return STANDARD_EXAMPLES + [f"n2t_{chip}" for chip in N2T_CHIPS]


def get_example_by_id(example_id: str) -> Example:
    """Get a specific example by ID."""
    if example_id in STANDARD_EXAMPLES:
        return load_standard_example(example_id)
    elif example_id.startswith("n2t_"):
        chip_name = example_id[4:]
        return load_n2t_solution(chip_name)
    else:
        raise ValueError(f"Unknown example: {example_id}")
