#!/usr/bin/env python3
"""
Fast iteration helper for OCaml/Hardcaml development.

Stages a selected example into a dune project (default: /opt/build-cache) and
optionally runs `dune build @runtest --auto-promote`.

This is meant for OCaml programmers iterating locally inside the dev container.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Example:
    id: str
    files: dict[str, str]  # filename -> content (as staged into dune project)
    src_module_files: list[
        str
    ]  # which files belong in build/src (for cleanup/reporting)


def _read_text(path: Path) -> str:
    return path.read_text()


def _hardcaml_root() -> Path:
    # repo: hardcaml-web-ide/hardcaml/dev_runner.py
    # docker: /hardcaml/dev_runner.py
    return Path(__file__).resolve().parent


def _default_build_dir() -> Path:
    opt = Path("/opt/build-cache")
    if opt.exists():
        return opt
    # fallback for running outside the container
    return _hardcaml_root() / "build-cache"


def _build_cache_root() -> Path:
    # The "authoritative" build-cache sources live in the repo under hardcaml/build-cache.
    return _hardcaml_root() / "build-cache"


def _n2t_chips_dir() -> Path:
    return _build_cache_root() / "lib" / "n2t_chips"


def _standard_example_ids() -> list[str]:
    examples_dir = _hardcaml_root() / "examples"
    ids: list[str] = []
    for p in sorted(examples_dir.iterdir()):
        if not p.is_dir():
            continue
        if (p / "circuit.ml").exists() and (p / "test.ml").exists():
            ids.append(p.name)
    return ids


def _n2t_chip_names() -> list[str]:
    chips_dir = _hardcaml_root() / "examples" / "n2t_solutions"
    if not chips_dir.exists():
        return []
    names: list[str] = []
    for p in sorted(chips_dir.glob("*.ml")):
        names.append(p.stem)
    return names


def load_standard_example(example_id: str) -> Example:
    ex_dir = _hardcaml_root() / "examples" / example_id
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
        src_module_files=["circuit.ml", "circuit.mli"],
    )


def load_n2t_example(chip: str, *, use_stub: bool) -> Example:
    ex_root = _hardcaml_root() / "examples"
    impl_dir = ex_root / ("n2t" if use_stub else "n2t_solutions")
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
    return Example(
        id=f"n2t_{chip}" if not use_stub else f"n2t_stub_{chip}",
        files=files,
        src_module_files=[f"{chip}.ml", f"{chip}.mli"],
    )


def stage_into_build_dir(example: Example, build_dir: Path) -> None:
    src_dir = build_dir / "src"
    test_dir = build_dir / "test"
    src_dir.mkdir(parents=True, exist_ok=True)
    test_dir.mkdir(parents=True, exist_ok=True)

    # Clean up prior staged OCaml files (keep dune config files, etc).
    for p in src_dir.iterdir():
        if p.suffix in {".ml", ".mli"}:
            p.unlink()
    test_ml = test_dir / "test.ml"
    if test_ml.exists():
        test_ml.unlink()

    # Write staged files.
    for filename, content in example.files.items():
        if filename == "test.ml":
            (test_dir / "test.ml").write_text(content)
        elif filename.endswith(".ml") or filename.endswith(".mli"):
            (src_dir / filename).write_text(content)
        else:
            # Non-OCaml files (e.g., input.txt) are not needed by dune project; ignore.
            pass


def run_dune(build_dir: Path) -> int:
    cmd = ["dune", "build", "@runtest", "--auto-promote"]
    proc = subprocess.run(cmd, cwd=build_dir)
    return proc.returncode


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Stage Hardcaml examples into /opt/build-cache (or a specified dune project) for fast iteration."
    )
    parser.add_argument(
        "-l",
        "--list",
        action="store_true",
        help="List available example ids",
    )
    parser.add_argument(
        "--build-dir",
        type=Path,
        default=_default_build_dir(),
        help="Target dune project directory (default: /opt/build-cache if present, else ./build-cache)",
    )
    parser.add_argument(
        "--no-run",
        action="store_true",
        help="Only stage files; do not run dune",
    )
    parser.add_argument(
        "--use-stub",
        action="store_true",
        help="For N2T chips, stage from examples/n2t (student stubs) instead of examples/n2t_solutions",
    )
    parser.add_argument(
        "example_id",
        nargs="?",
        help="Example id to stage (e.g. counter, day1_part1, n2t_alu)",
    )
    args = parser.parse_args(argv)

    if args.list:
        print("Standard examples:")
        for ex in _standard_example_ids():
            print(f"  - {ex}")
        chips = _n2t_chip_names()
        if chips:
            print("\nN2T chips (use ids like n2t_<chip>):")
            for chip in chips:
                print(f"  - n2t_{chip}")
        return 0

    if not args.example_id:
        parser.error("missing example_id (or pass --list)")

    build_dir: Path = args.build_dir
    if not (build_dir / "dune-project").exists():
        raise SystemExit(
            f"{build_dir} doesn't look like a dune project (missing dune-project). "
            "Run inside the dev container (so /opt/build-cache exists) or pass --build-dir."
        )

    if args.example_id.startswith("n2t_"):
        chip = args.example_id[len("n2t_") :]
        example = load_n2t_example(chip, use_stub=args.use_stub)
    else:
        example = load_standard_example(args.example_id)

    stage_into_build_dir(example, build_dir)
    print(f"Staged {example.id} into {build_dir}")

    if args.no_run:
        return 0

    return run_dune(build_dir)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
