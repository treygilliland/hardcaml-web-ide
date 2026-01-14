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
from pathlib import Path

from examples_manifest import Example, load_example, list_examples


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


def stage_into_build_dir(example: Example, build_dir: Path) -> None:
    src_dir = build_dir / "src"
    test_dir = build_dir / "test"
    src_dir.mkdir(parents=True, exist_ok=True)
    test_dir.mkdir(parents=True, exist_ok=True)

    # Files that should never be deleted in test/ (shared infrastructure)
    preserved_test_files = {"harness_utils.ml"}

    # Clean up prior staged OCaml files (keep dune config files, etc).
    for p in src_dir.iterdir():
        if p.suffix in {".ml", ".mli"}:
            p.unlink()
    for p in test_dir.iterdir():
        if p.suffix in {".ml", ".mli"} and p.name not in preserved_test_files:
            p.unlink()

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
        help="For N2T chips, stage from n2t/stubs (student stubs) instead of n2t/solutions",
    )
    parser.add_argument(
        "example_id",
        nargs="?",
        help="Example id to stage (e.g. counter, day1_part1, n2t_alu)",
    )
    args = parser.parse_args(argv)

    if args.list:
        examples = list_examples()
        standard_examples = [eid for eid in examples if not eid.startswith("n2t_")]
        n2t_examples = [eid for eid in examples if eid.startswith("n2t_")]
        
        if standard_examples:
            print("Standard examples:")
            for ex_id in standard_examples:
                print(f"  - {ex_id}")
        
        if n2t_examples:
            print("\nN2T chips (use ids like n2t_<chip>):")
            for ex_id in n2t_examples:
                print(f"  - {ex_id}")
        return 0

    if not args.example_id:
        parser.error("missing example_id (or pass --list)")

    build_dir: Path = args.build_dir
    if not (build_dir / "dune-project").exists():
        raise SystemExit(
            f"{build_dir} doesn't look like a dune project (missing dune-project). "
            "Run inside the dev container (so /opt/build-cache exists) or pass --build-dir."
        )

    example = load_example(args.example_id, use_stub=args.use_stub)

    stage_into_build_dir(example, build_dir)
    print(f"Staged {example.id} into {build_dir}")

    if args.no_run:
        return 0

    return run_dune(build_dir)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
