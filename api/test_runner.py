#!/usr/bin/env python3
"""
Direct dune test runner for HardCaml examples.

Runs examples through compiler.compile_and_run() without HTTP.
Must be run inside Docker where dune/opam environment exists.

Usage:
    python test_runner.py           # Run all examples
    python test_runner.py counter   # Run specific example
    python test_runner.py -v        # Verbose output
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

    result = compile_and_run(files=example.files, timeout_seconds=60)

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
    parser = argparse.ArgumentParser(description="Run HardCaml dune tests directly")
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
        print("Available examples:")
        for ex in examples:
            print(f"  - {ex.id}")
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
