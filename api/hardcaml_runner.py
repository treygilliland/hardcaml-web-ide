#!/usr/bin/env python3
"""
Hardcaml example runner - alternative to the web IDE.

Runs Hardcaml examples directly using the same compiler as the web IDE.
This provides a command-line alternative to using the web IDE for running
and testing Hardcaml circuits.

Includes all examples exposed in the frontend:
- All standard examples (ocaml_basics, hardcaml examples, advent examples)
- All N2T solutions (excludes N2T stubs, matching frontend behavior)

Must be run inside Docker where dune/opam environment exists.

Usage:
    uv run python hardcaml_runner.py           # Run all examples
    uv run python hardcaml_runner.py counter   # Run specific example
    uv run python hardcaml_runner.py -l        # List available examples
    uv run python hardcaml_runner.py -v        # Verbose output
"""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from compiler import compile_and_run
from tests.examples import get_all_testable_examples, get_example_by_id


def run_example(example, verbose: bool = False) -> bool:
    """Run a single example and return True if it passes."""
    if verbose:
        print(f"\n{'=' * 60}")
        print(f"Running: {example.id}")
        print(f"{'=' * 60}")

    result = compile_and_run(
        files=example.files,
        timeout_seconds=60,
        project_type=example.project_type,
    )

    if result.success:
        passed = result.tests_passed or 0
        failed = result.tests_failed or 0
        if verbose:
            print(f"  Output: {result.output}")
        print(f"  ✓ {example.id}: {passed} passed, {failed} failed")
        return True
    else:
        print(f"  ✗ {example.id}: {result.error_type} - {result.error_message}")
        if verbose and result.output:
            print(f"  Output: {result.output}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Run Hardcaml examples - CLI alternative to the web IDE"
    )
    parser.add_argument(
        "examples",
        nargs="*",
        help="Specific example IDs to run (default: all)",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Verbose output",
    )
    parser.add_argument(
        "-l",
        "--list",
        action="store_true",
        help="List available examples",
    )
    args = parser.parse_args()

    if args.list:
        examples = get_all_testable_examples()
        print(f"Available examples ({len(examples)} total):")
        # Group by project type for better readability
        standard = [e for e in examples if e.project_type == "standard"]
        n2t = [e for e in examples if e.project_type == "n2t"]
        if standard:
            print(f"\n  Standard examples ({len(standard)}):")
            for ex in standard:
                print(f"    - {ex.id}")
        if n2t:
            print(f"\n  N2T solutions ({len(n2t)}):")
            for ex in n2t:
                print(f"    - {ex.id}")
        return 0

    if args.examples:
        examples = [get_example_by_id(eid) for eid in args.examples]
    else:
        examples = get_all_testable_examples()

    print(f"Running {len(examples)} example(s)...")

    passed = 0
    failed = 0
    failed_examples = []

    for example in examples:
        if run_example(example, verbose=args.verbose):
            passed += 1
        else:
            failed += 1
            failed_examples.append(example.id)

    print(f"\n{'=' * 60}")
    print(f"Results: {passed} passed, {failed} failed")
    if failed_examples:
        print(f"Failed: {', '.join(failed_examples)}")
    print(f"{'=' * 60}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
