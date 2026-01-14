"""
Unified example manifest for HardCaml examples.

This module provides a single source of truth for loading and listing examples
used by both the dev runner and the API test runner.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Literal


@dataclass(frozen=True)
class Example:
    """Represents a HardCaml example with its files and metadata."""

    id: str
    files: dict[str, str]  # filename -> content
    project_type: Literal["standard", "n2t"]
    # Optional metadata for compatibility
    name: str | None = None
    circuit_filename: str | None = None
    interface_filename: str | None = None
    src_module_files: list[str] | None = None  # For dev_runner compatibility

    def __post_init__(self):
        """Set defaults based on project_type if not provided."""
        if self.name is None:
            object.__setattr__(self, "name", self.id)

        if self.project_type == "standard":
            if self.circuit_filename is None:
                object.__setattr__(self, "circuit_filename", "circuit.ml")
            if self.interface_filename is None:
                object.__setattr__(self, "interface_filename", "circuit.mli")
            if self.src_module_files is None:
                object.__setattr__(
                    self, "src_module_files", ["circuit.ml", "circuit.mli"]
                )
        else:  # n2t
            # Extract chip name from id (e.g., "n2t_alu" -> "alu")
            chip_name = self.id.replace("n2t_stub_", "").replace("n2t_", "")
            if self.circuit_filename is None:
                object.__setattr__(self, "circuit_filename", f"{chip_name}.ml")
            if self.interface_filename is None:
                object.__setattr__(self, "interface_filename", f"{chip_name}.mli")
            if self.src_module_files is None:
                object.__setattr__(
                    self, "src_module_files", [f"{chip_name}.ml", f"{chip_name}.mli"]
                )


def _hardcaml_root() -> Path:
    """Get the hardcaml directory root."""
    # Works whether running from repo root or from within hardcaml/
    script_path = Path(__file__).resolve()
    if (
        script_path.name == "examples_manifest.py"
        and script_path.parent.name == "hardcaml"
    ):
        return script_path.parent
    # Fallback: assume we're in hardcaml/ directory
    return Path(__file__).resolve().parent


def _read_text(path: Path) -> str:
    """Read a text file."""
    return path.read_text()


def _standard_example_roots() -> list[Path]:
    """Get directories where standard examples live."""
    root = _hardcaml_root()
    return [
        root / "examples",
        root / "aoc",
    ]


def _standard_example_dir(example_id: str) -> Path:
    """Find the directory for a standard example."""
    for root in _standard_example_roots():
        p = root / example_id
        if p.exists():
            return p
    raise FileNotFoundError(f"Unknown standard example id: {example_id}")


def _n2t_chips_dir() -> Path:
    """Get the directory containing N2T chip interfaces and tests."""
    return _hardcaml_root() / "build-cache" / "lib" / "n2t_chips"


def _standard_example_ids() -> list[str]:
    """List all available standard example IDs."""
    ids: list[str] = []
    for root in _standard_example_roots():
        if not root.exists():
            continue
        for p in sorted(root.iterdir()):
            if not p.is_dir():
                continue
            if (p / "circuit.ml").exists() and (p / "test.ml").exists():
                ids.append(p.name)
    return ids


def _n2t_chip_names() -> list[str]:
    """List all available N2T chip names."""
    chips_dir = _hardcaml_root() / "n2t" / "solutions"
    if not chips_dir.exists():
        return []
    names: list[str] = []
    for p in sorted(chips_dir.glob("*.ml")):
        names.append(p.stem)
    return names


# Hardcoded lists for API test compatibility (subset of all available)
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


def load_standard_example(example_id: str) -> Example:
    """Load a standard example (from examples/ or aoc/ directories)."""
    ex_dir = _standard_example_dir(example_id)
    files = {
        "circuit.ml": _read_text(ex_dir / "circuit.ml"),
        "circuit.mli": _read_text(ex_dir / "circuit.mli"),
        "test.ml": _read_text(ex_dir / "test.ml"),
    }
    input_file = ex_dir / "input.txt"
    if input_file.exists():
        inp = _read_text(input_file)
        files["input.txt"] = inp
        files["test.ml"] = files["test.ml"].replace("INPUT_DATA", inp)

    return Example(
        id=example_id,
        files=files,
        project_type="standard",
        name=example_id,
    )


def load_n2t_example(chip: str, *, use_stub: bool = False) -> Example:
    """Load an N2T chip example.

    Args:
        chip: Chip name (e.g., "alu", "register")
        use_stub: If True, load from n2t/stubs/ instead of n2t/solutions/
    """
    ex_root = _hardcaml_root() / "n2t"
    impl_dir = ex_root / ("stubs" if use_stub else "solutions")
    impl_file = impl_dir / f"{chip}.ml"
    if not impl_file.exists():
        raise FileNotFoundError(f"Missing implementation file: {impl_file}")

    chips_dir = _n2t_chips_dir()
    interface_file = chips_dir / f"{chip}.mli"
    test_file = chips_dir / f"{chip}_test.ml"

    if not interface_file.exists():
        raise FileNotFoundError(f"Missing interface file: {interface_file}")
    if not test_file.exists():
        raise FileNotFoundError(f"Missing test file: {test_file}")

    files = {
        f"{chip}.ml": _read_text(impl_file),
        f"{chip}.mli": _read_text(interface_file),
        "test.ml": _read_text(test_file),
    }

    example_id = f"n2t_stub_{chip}" if use_stub else f"n2t_{chip}"
    name = f"N2T {chip}" if not use_stub else f"N2T stub {chip}"

    return Example(
        id=example_id,
        files=files,
        project_type="n2t",
        name=name,
    )


def load_example(example_id: str, use_stub: bool = False) -> Example:
    """Load any example by ID.

    Handles standard examples, AOC examples, and N2T chips.
    For N2T chips, use_stub controls whether to load from stubs/ or solutions/.

    Args:
        example_id: Example ID (e.g., "counter", "day1_part1", "n2t_alu")
        use_stub: For N2T chips, load stub instead of solution (ignored for standard examples)

    Returns:
        Example object with files and metadata
    """
    if example_id.startswith("n2t_"):
        chip = example_id[len("n2t_") :]
        # Handle n2t_stub_ prefix
        if chip.startswith("stub_"):
            chip = chip[len("stub_") :]
            use_stub = True
        return load_n2t_example(chip, use_stub=use_stub)
    else:
        return load_standard_example(example_id)


def list_examples() -> list[str]:
    """List all available example IDs.

    Returns:
        List of example IDs (standard examples and n2t_<chip>)
    """
    ids: list[str] = []
    ids.extend(_standard_example_ids())
    for chip in _n2t_chip_names():
        ids.append(f"n2t_{chip}")
    return ids


def get_all_testable_examples() -> list[Example]:
    """Get all examples that should pass tests (solutions only, no stubs).

    This is used by the API test runner to get a curated list of examples.
    """
    examples = []

    # Use hardcoded STANDARD_EXAMPLES list for consistency with tests
    for example_id in STANDARD_EXAMPLES:
        try:
            examples.append(load_standard_example(example_id))
        except FileNotFoundError:
            # Skip if example doesn't exist
            pass

    # Use hardcoded N2T_CHIPS list for consistency with tests
    for chip_name in N2T_CHIPS:
        try:
            examples.append(load_n2t_example(chip_name, use_stub=False))
        except FileNotFoundError:
            # Skip if chip doesn't exist
            pass

    return examples


def get_example_by_id(example_id: str) -> Example:
    """Get a specific example by ID (for API test compatibility).

    This is a convenience wrapper around load_example() that matches
    the API used by api/tests/examples.py.
    """
    return load_example(example_id, use_stub=False)


def get_example_ids() -> list[str]:
    """Get list of all testable example IDs for pytest parametrization.

    Returns the hardcoded lists (STANDARD_EXAMPLES + n2t_<chip> for N2T_CHIPS).
    """
    return STANDARD_EXAMPLES + [f"n2t_{chip}" for chip in N2T_CHIPS]
