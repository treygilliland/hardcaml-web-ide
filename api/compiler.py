"""
Hardcaml Compiler Module

Handles compilation and execution of Hardcaml circuits in a sandboxed environment.
"""

import logging
import os
import re
import shutil
import subprocess
import tempfile
import time
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

log = logging.getLogger(__name__)


@dataclass
class CompileResult:
    """Result of compilation and test execution."""

    success: bool
    output: Optional[str] = None
    waveform: Optional[str] = None
    waveform_vcd: Optional[str] = None
    error_type: Optional[str] = None
    error_message: Optional[str] = None
    stage: Optional[str] = None
    compile_time_ms: Optional[int] = None
    run_time_ms: Optional[int] = None
    tests_passed: Optional[int] = None
    tests_failed: Optional[int] = None


# Build cache directory (pre-built in Docker image for fast compilation)
BUILD_CACHE_DIR = Path("/opt/build-cache")

# Markers for parsing output
WAVEFORM_START = "===WAVEFORM_START==="
WAVEFORM_END = "===WAVEFORM_END==="
TEST_SUMMARY = "===TEST_SUMMARY==="


def create_build_dir() -> Path:
    """Create an isolated build directory for this request."""
    build_id = str(uuid.uuid4())[:8]
    build_dir = Path(tempfile.gettempdir()) / f"hardcaml-build-{build_id}"
    build_dir.mkdir(parents=True, exist_ok=True)
    return build_dir


def setup_project(build_dir: Path, files: dict[str, str]) -> None:
    """
    Set up the project structure with user files.

    Copies the build cache and injects user files.
    """
    # Copy build cache structure
    if BUILD_CACHE_DIR.exists():
        shutil.copytree(BUILD_CACHE_DIR, build_dir, dirs_exist_ok=True)
    else:
        # Fallback: create structure from scratch (for local development)
        (build_dir / "src").mkdir(exist_ok=True)
        (build_dir / "test").mkdir(exist_ok=True)

        # Create dune-project
        (build_dir / "dune-project").write_text("""(lang dune 3.11)
(name user_project)
""")

        # Create src/dune
        (build_dir / "src" / "dune").write_text("""(library
 (name user_circuit)
 (libraries core hardcaml)
 (preprocess
  (pps ppx_hardcaml ppx_jane)))
""")

        # Create test/dune
        (build_dir / "test" / "dune").write_text("""(library
 (name user_test)
 (libraries 
   core 
   hardcaml 
   hardcaml_waveterm
   hardcaml_test_harness
   user_circuit)
 (inline_tests)
 (preprocess
  (pps ppx_hardcaml ppx_jane ppx_expect)))
""")

    # Write user files
    src_dir = build_dir / "src"
    test_dir = build_dir / "test"

    for filename, content in files.items():
        if filename == "test.ml":
            (test_dir / "test.ml").write_text(content)
        elif filename.endswith(".ml") or filename.endswith(".mli"):
            (src_dir / filename).write_text(content)


def run_command(
    cmd: list[str], cwd: Path, timeout: int, env: Optional[dict] = None
) -> tuple[int, str, str]:
    """
    Run a command with timeout and capture output.

    Returns (return_code, stdout, stderr).
    """
    # Set up environment with opam paths
    run_env = os.environ.copy()
    if env:
        run_env.update(env)

    # Ensure opam binaries are in PATH
    opam_bin = "/root/.opam/5.2.0+ox/bin"
    if opam_bin not in run_env.get("PATH", ""):
        run_env["PATH"] = f"{opam_bin}:{run_env.get('PATH', '')}"

    try:
        result = subprocess.run(
            cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout, env=run_env
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", f"Command timed out after {timeout} seconds"
    except Exception as e:
        return -1, "", str(e)


@dataclass
class ParsedOutput:
    """Parsed output from test execution."""

    test_output: str
    waveform: Optional[str]
    tests_passed: Optional[int]
    tests_failed: Optional[int]


def parse_output(output_text: str) -> ParsedOutput:
    """
    Parse output to separate test results from waveform.

    Returns ParsedOutput with test output, waveform, and test counts.
    """
    waveform = None
    test_lines = []
    tests_passed = None
    tests_failed = None

    in_waveform = False
    waveform_lines = []
    in_summary = False

    for line in output_text.split("\n"):
        # Strip diff prefixes (+, -, |) that dune adds
        clean_line = line
        if line.startswith("+    ") or line.startswith("-    "):
            clean_line = line[5:]
        elif line.startswith("|    "):
            clean_line = line[5:]
        elif line.startswith("+") and not line.startswith("++"):
            clean_line = line[1:]

        if WAVEFORM_START in clean_line:
            in_waveform = True
            continue
        elif WAVEFORM_END in clean_line:
            in_waveform = False
            waveform = "\n".join(waveform_lines)
            continue
        elif TEST_SUMMARY in clean_line:
            in_summary = True
            continue

        if in_waveform:
            waveform_lines.append(clean_line)
        elif in_summary:
            # Parse "TESTS: X passed, Y failed"
            match = re.search(r"TESTS:\s*(\d+)\s*passed,\s*(\d+)\s*failed", clean_line)
            if match:
                tests_passed = int(match.group(1))
                tests_failed = int(match.group(2))
                test_lines.append(clean_line)
            in_summary = False
        else:
            # Capture PASS/FAIL lines
            if clean_line.startswith("PASS:") or clean_line.startswith("FAIL:"):
                test_lines.append(clean_line)

    return ParsedOutput(
        test_output="\n".join(test_lines).strip(),
        waveform=waveform,
        tests_passed=tests_passed,
        tests_failed=tests_failed,
    )


def read_vcd_file() -> Optional[str]:
    """
    Read the VCD file generated by the test.
    Returns the VCD content as a string, or None if not found.
    """
    vcd_path = Path("/tmp/waveform.vcd")
    try:
        if vcd_path.exists():
            return vcd_path.read_text()
    except Exception:
        pass
    return None


def parse_error(stderr: str) -> tuple[str, str]:
    """
    Parse error message to determine error type.

    Returns (error_type, cleaned_message).
    """
    if "Error: Unbound" in stderr:
        return "unbound_error", stderr
    elif "Error: Syntax error" in stderr:
        return "syntax_error", stderr
    elif "Error: This expression has type" in stderr:
        return "type_error", stderr
    elif "timed out" in stderr.lower():
        return "timeout_error", stderr
    else:
        return "compile_error", stderr


def compile_and_run(files: dict[str, str], timeout_seconds: int = 30) -> CompileResult:
    """
    Compile and run Hardcaml code.

    1. Create isolated build directory
    2. Set up project with user files
    3. Run dune build @runtest
    4. Parse and return results
    """
    build_dir = None
    total_start = time.time()

    try:
        # Create build directory
        t0 = time.time()
        build_dir = create_build_dir()
        log.info(f"[timing] create_build_dir: {int((time.time() - t0) * 1000)}ms")

        # Set up project (copy build cache + write user files)
        t0 = time.time()
        setup_project(build_dir, files)
        log.info(f"[timing] setup_project: {int((time.time() - t0) * 1000)}ms")

        # Build and run tests
        # Note: No --force flag to allow dune's incremental build cache
        # Each request uses a fresh temp dir, but this helps if container stays warm
        t0 = time.time()
        returncode, stdout, stderr = run_command(
            ["dune", "build", "@runtest", "--auto-promote"],
            cwd=build_dir,
            timeout=timeout_seconds,
        )
        dune_time = int((time.time() - t0) * 1000)
        log.info(f"[timing] dune build @runtest: {dune_time}ms")

        # Parse output
        t0 = time.time()
        combined_output = stdout + "\n" + stderr
        parsed = parse_output(combined_output)
        log.info(f"[timing] parse_output: {int((time.time() - t0) * 1000)}ms")

        # Read VCD file if it was generated
        vcd = read_vcd_file()
        if vcd:
            log.info(f"[timing] read VCD file: {len(vcd)} bytes")

        total_time = int((time.time() - total_start) * 1000)
        log.info(f"[timing] total (before cleanup): {total_time}ms")

        # Check for compile errors (as opposed to test failures)
        has_compile_error = "Error:" in stderr and "File" in stderr and "line" in stderr

        if has_compile_error:
            error_type, error_message = parse_error(stderr)
            return CompileResult(
                success=False,
                output=parsed.test_output if parsed.test_output else None,
                waveform=parsed.waveform,
                waveform_vcd=vcd,
                error_type=error_type,
                error_message=error_message,
                stage="compile",
                compile_time_ms=dune_time,
                tests_passed=parsed.tests_passed,
                tests_failed=parsed.tests_failed,
            )

        # Tests ran - report success based on test results
        if parsed.tests_failed is not None and parsed.tests_failed > 0:
            return CompileResult(
                success=False,
                output=parsed.test_output,
                waveform=parsed.waveform,
                waveform_vcd=vcd,
                error_type="test_failure",
                error_message=f"{parsed.tests_failed} test(s) failed",
                stage="test",
                compile_time_ms=dune_time,
                tests_passed=parsed.tests_passed,
                tests_failed=parsed.tests_failed,
            )

        # Check for runtime exceptions (failwith, etc.) - returncode != 0 but no test counts
        if returncode != 0 and parsed.tests_passed is None:
            # Extract exception message from output
            exception_msg = None
            for line in combined_output.split("\n"):
                if "Failure" in line or "failwith" in line.lower():
                    exception_msg = line.strip()
                    break
                if "Exception:" in line:
                    exception_msg = line.strip()
                    break

            return CompileResult(
                success=False,
                output=parsed.test_output if parsed.test_output else combined_output,
                waveform=parsed.waveform,
                waveform_vcd=vcd,
                error_type="runtime_error",
                error_message=exception_msg or "Test crashed with an exception",
                stage="test",
                compile_time_ms=dune_time,
                tests_passed=0,
                tests_failed=1,
            )

        return CompileResult(
            success=True,
            output=parsed.test_output,
            waveform=parsed.waveform,
            waveform_vcd=vcd,
            compile_time_ms=dune_time,
            tests_passed=parsed.tests_passed,
            tests_failed=parsed.tests_failed,
        )

    except Exception as e:
        return CompileResult(
            success=False,
            error_type="internal_error",
            error_message=str(e),
            stage="setup",
        )

    finally:
        # Cleanup build directory
        if build_dir and build_dir.exists():
            t0 = time.time()
            try:
                shutil.rmtree(build_dir)
            except Exception:
                pass  # Best effort cleanup
            log.info(f"[timing] cleanup: {int((time.time() - t0) * 1000)}ms")
