"""
Hardcaml Compiler Module

Handles compilation and execution of Hardcaml circuits in a sandboxed environment.
"""

import logging
import os
import shutil
import subprocess
import tempfile
import time
import uuid
from dataclasses import dataclass
from typing import Optional
from pathlib import Path

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


# Build cache directory (pre-built in Docker image for fast compilation)
BUILD_CACHE_DIR = Path("/opt/build-cache")

# Markers for parsing output
WAVEFORM_START = "===WAVEFORM_START==="
WAVEFORM_END = "===WAVEFORM_END==="


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
    cmd: list[str],
    cwd: Path,
    timeout: int,
    env: Optional[dict] = None
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
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=run_env
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", f"Command timed out after {timeout} seconds"
    except Exception as e:
        return -1, "", str(e)


def parse_output(output_text: str) -> tuple[str, Optional[str]]:
    """
    Parse output to separate test results from waveform.
    
    Returns (output, waveform).
    """
    waveform = None
    output_lines = []
    
    in_waveform = False
    waveform_lines = []
    
    for line in output_text.split('\n'):
        # Strip diff prefixes (+, -, |) that dune adds
        clean_line = line
        if line.startswith('+    ') or line.startswith('-    '):
            clean_line = line[5:]
        elif line.startswith('|    '):
            clean_line = line[5:]
            
        if WAVEFORM_START in clean_line:
            in_waveform = True
            continue
        elif WAVEFORM_END in clean_line:
            in_waveform = False
            waveform = '\n'.join(waveform_lines)
            continue
        
        if in_waveform:
            # Remove any remaining diff prefix
            if clean_line.startswith('+') and not clean_line.startswith('++'):
                clean_line = clean_line[1:]
            waveform_lines.append(clean_line)
        else:
            # Look for test result output (sexp format)
            if '(Result' in line or '(result' in line:
                # Extract just the sexp part
                import re
                match = re.search(r'\(Result[^)]+\)', line, re.IGNORECASE)
                if match:
                    output_lines.append(match.group(0))
    
    return '\n'.join(output_lines).strip(), waveform


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


def compile_and_run(
    files: dict[str, str],
    timeout_seconds: int = 30
) -> CompileResult:
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
        t0 = time.time()
        returncode, stdout, stderr = run_command(
            ["dune", "build", "@runtest", "--force", "--auto-promote"],
            cwd=build_dir,
            timeout=timeout_seconds
        )
        dune_time = int((time.time() - t0) * 1000)
        log.info(f"[timing] dune build @runtest: {dune_time}ms")
        
        # Parse output
        t0 = time.time()
        combined_output = stdout + "\n" + stderr
        output, waveform = parse_output(combined_output)
        log.info(f"[timing] parse_output: {int((time.time() - t0) * 1000)}ms")
        
        # Read VCD file if it was generated
        vcd = read_vcd_file()
        if vcd:
            log.info(f"[timing] read VCD file: {len(vcd)} bytes")
        
        total_time = int((time.time() - total_start) * 1000)
        log.info(f"[timing] total (before cleanup): {total_time}ms")
        
        # If we got a waveform, consider it a success even if expect test "failed"
        # (the "failure" is just that the expected output didn't match)
        if waveform:
            return CompileResult(
                success=True,
                output=output,
                waveform=waveform,
                waveform_vcd=vcd,
                compile_time_ms=dune_time,
                run_time_ms=None
            )
        
        if returncode != 0:
            # Check if it's a compile error or test failure
            error_type, error_message = parse_error(stderr)
            stage = "compile" if "Error:" in stderr and "File" in stderr else "test"
            return CompileResult(
                success=False,
                output=output if output else None,
                waveform=None,
                error_type=error_type,
                error_message=error_message,
                stage=stage,
                compile_time_ms=dune_time,
                run_time_ms=None
            )
        
        return CompileResult(
            success=True,
            output=output,
            waveform=waveform,
            compile_time_ms=dune_time,
            run_time_ms=None
        )
        
    except Exception as e:
        return CompileResult(
            success=False,
            error_type="internal_error",
            error_message=str(e),
            stage="setup"
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
