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

from result_cache import get_result_cache
from workspace_cache import get_workspace_cache

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

# Template directories for standard vs N2T builds
# In dev mode with docker-compose, /hardcaml is mounted from host (has latest stubs)
# In production, use /opt/build-templates from Docker image
TEMPLATE_DIR_MOUNTED = Path("/hardcaml/build-templates")  # Docker volume mount
TEMPLATE_DIR_DOCKER = Path("/opt/build-templates")
TEMPLATE_DIR_REPO = Path(__file__).parent.parent / "hardcaml" / "build-templates"

# Cache for resolved template directories (lazy initialization)
_template_dir_cache: Path | None = None
_standard_template_dir_cache: Path | None = None
_n2t_template_dir_cache: Path | None = None


def _get_template_dir() -> Path:
    """Get the template directory, resolving lazily on first access."""
    global _template_dir_cache
    if _template_dir_cache is None:
        # Prefer mounted templates (dev mode) since they may have pre-built _build/
        if TEMPLATE_DIR_MOUNTED.exists():
            _template_dir_cache = TEMPLATE_DIR_MOUNTED
        elif TEMPLATE_DIR_DOCKER.exists():
            _template_dir_cache = TEMPLATE_DIR_DOCKER
        else:
            _template_dir_cache = TEMPLATE_DIR_REPO

        # Log template resolution on first access
        log.info(
            f"Template resolution: MOUNTED={TEMPLATE_DIR_MOUNTED.exists()}, DOCKER={TEMPLATE_DIR_DOCKER.exists()}"
        )
        log.info(f"Using template directory: {_template_dir_cache}")
    return _template_dir_cache


def _get_standard_template_dir() -> Path:
    """Get the standard template directory, resolving lazily on first access."""
    global _standard_template_dir_cache
    if _standard_template_dir_cache is None:
        _standard_template_dir_cache = _get_template_dir() / "standard"
    return _standard_template_dir_cache


def _get_n2t_template_dir() -> Path:
    """Get the N2T template directory, resolving lazily on first access."""
    global _n2t_template_dir_cache
    if _n2t_template_dir_cache is None:
        _n2t_template_dir_cache = _get_template_dir() / "n2t"
    return _n2t_template_dir_cache

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


def _is_n2t_project(files: dict[str, str]) -> bool:
    """
    Determine if this is an N2T project based on filenames.

    N2T projects have a main circuit module that is NOT circuit.ml
    (e.g., add16.ml, register.ml, etc.)

    This is a fallback when project_type is not explicitly provided.
    """
    circuit_files = [f for f in files.keys() if f.endswith(".ml") and f != "test.ml"]
    # If main circuit is not circuit.ml, it's N2T
    return "circuit.ml" not in circuit_files


def _get_circuit_modules(files: dict[str, str], is_n2t: bool) -> list[str] | None:
    """
    Determine which modules to include in the user_circuit library.
    
    Returns:
        List of module names (without .ml extension), or None to let Dune auto-detect.
    """
    # Get all .ml files except test.ml and harness_utils.ml
    circuit_files = [
        f[:-3]  # Remove .ml extension
        for f in files.keys()
        if f.endswith(".ml") and f not in ("test.ml", "harness_utils.ml")
    ]
    
    if not circuit_files:
        # No circuit files found, let Dune auto-detect
        return None
    
    if is_n2t:
        # For N2T projects, include all circuit files
        return circuit_files
    else:
        # For standard projects, only include circuit if it exists
        if "circuit" in circuit_files:
            return ["circuit"]
        # If circuit.ml doesn't exist but we have other files, include them
        return circuit_files if circuit_files else None


def _copy_template_selectively(
    template_dir: Path, build_dir: Path, is_n2t: bool
) -> None:
    """
    Copy template directory to build_dir, including pre-built _build/ for faster first builds.
    """
    if not template_dir.exists():
        # Fallback: use old build-cache if templates don't exist
        if BUILD_CACHE_DIR.exists():
            _copy_build_cache_selectively(BUILD_CACHE_DIR, build_dir, is_n2t)
        else:
            _create_fallback_structure(build_dir, is_n2t, files=None)
        return

    # Copy dune-project
    if (template_dir / "dune-project").exists():
        shutil.copy2(template_dir / "dune-project", build_dir / "dune-project")

    # For flat layout, we don't copy src/test directories - we'll create dune file directly
    # But we still need harness_utils.ml - copy it from template if it exists
    template_harness = template_dir / "test" / "harness_utils.ml"
    if template_harness.exists():
        shutil.copy2(template_harness, build_dir / "harness_utils.ml")

    # Copy lib/n2t_chips only for N2T projects
    if is_n2t:
        n2t_lib_src = template_dir / "lib" / "n2t_chips"
        if n2t_lib_src.exists():
            (build_dir / "lib").mkdir(exist_ok=True)
            shutil.copytree(
                n2t_lib_src, build_dir / "lib" / "n2t_chips", dirs_exist_ok=True
            )

    # Copy pre-built _build/ directory for faster first builds
    # Try template's own _build first, then fall back to build-cache's _build
    template_build = template_dir / "_build"
    build_cache_build = BUILD_CACHE_DIR / "_build"
    if template_build.exists():
        shutil.copytree(template_build, build_dir / "_build", dirs_exist_ok=True)
    elif build_cache_build.exists():
        # Use build-cache's _build as fallback - has pre-compiled deps
        shutil.copytree(build_cache_build, build_dir / "_build", dirs_exist_ok=True)


def _copy_build_cache_selectively(
    cache_dir: Path, build_dir: Path, is_n2t: bool
) -> None:
    """Copy build cache selectively, including _build/ for faster first builds."""
    # Copy dune-project
    if (cache_dir / "dune-project").exists():
        shutil.copy2(cache_dir / "dune-project", build_dir / "dune-project")

    # For flat layout, copy harness_utils.ml if it exists in test/
    cache_harness = cache_dir / "test" / "harness_utils.ml"
    if cache_harness.exists():
        shutil.copy2(cache_harness, build_dir / "harness_utils.ml")

    # Copy lib/n2t_chips only for N2T projects
    if is_n2t:
        n2t_lib_src = cache_dir / "lib" / "n2t_chips"
        if n2t_lib_src.exists():
            (build_dir / "lib").mkdir(exist_ok=True)
            shutil.copytree(
                n2t_lib_src, build_dir / "lib" / "n2t_chips", dirs_exist_ok=True
            )

    # Copy pre-built _build/ directory for faster first builds
    cache_build = cache_dir / "_build"
    if cache_build.exists():
        shutil.copytree(cache_build, build_dir / "_build", dirs_exist_ok=True)


def _create_fallback_structure(build_dir: Path, is_n2t: bool, files: dict[str, str] | None = None) -> None:
    """Create minimal dune project structure as fallback (flat layout)."""
    # Create dune-project
    (build_dir / "dune-project").write_text("""(lang dune 3.11)
(name user_project)
""")

    # Create flat dune file
    libs = "core hardcaml"
    if is_n2t:
        libs += " n2t_chips"
    
    test_libs = "core hardcaml hardcaml_waveterm hardcaml_test_harness"
    if is_n2t:
        test_libs += " n2t_chips"
    test_libs += " user_circuit"
    
    # Determine circuit modules (use empty dict if files not provided)
    files_dict = files or {}
    circuit_modules = _get_circuit_modules(files_dict, is_n2t)
    modules_line = f" (modules {' '.join(circuit_modules)})\n" if circuit_modules else ""
    
    # Only include input.txt dependency if it exists
    has_input_txt = "input.txt" in files_dict
    input_deps_line = " (deps input.txt)" if has_input_txt else ""
    
    (build_dir / "dune").write_text(f"""(library
 (name user_circuit)
 (libraries {libs}){modules_line}(preprocess
  (pps ppx_hardcaml ppx_jane)))

(library
 (name user_test)
 (libraries 
   {test_libs})
 (modules test harness_utils)
 (wrapped false)
 (inline_tests{input_deps_line})
 (preprocess
  (pps ppx_hardcaml ppx_jane ppx_expect)))
""")

    # Create harness_utils.ml in root
    (build_dir / "harness_utils.ml").write_text("""open! Hardcaml_waveterm

let write_vcd_if_requested waves =
  match Sys.getenv_opt "HARDCAML_VCD_PATH" with
  | Some path -> Waveform.Serialize.marshall_vcd waves path
  | None -> ()
""")


def setup_project(
    build_dir: Path, files: dict[str, str], project_type: str | None = None
) -> None:
    """
    Set up the project structure with user files.

    Selects appropriate template (standard vs N2T) and copies selectively.

    Args:
        build_dir: Directory to set up the project in
        files: User files to write
        project_type: Optional project type ("standard" or "n2t"). If None, inferred from files.
    """
    if project_type is None:
        is_n2t = _is_n2t_project(files)
    else:
        is_n2t = project_type == "n2t"

    # Select template directory
    if is_n2t:
        template_dir = _get_n2t_template_dir()
    else:
        template_dir = _get_standard_template_dir()

    # Copy template structure (harness_utils.ml, lib/n2t_chips if N2T, _build/)
    _copy_template_selectively(template_dir, build_dir, is_n2t)

    # Create flat dune file (overwrite any from template)
    libs = "core hardcaml"
    if is_n2t:
        libs += " n2t_chips"
    
    test_libs = "core hardcaml hardcaml_waveterm hardcaml_test_harness"
    if is_n2t:
        test_libs += " n2t_chips"
    test_libs += " user_circuit"
    
    # Determine circuit modules dynamically
    circuit_modules = _get_circuit_modules(files, is_n2t)
    modules_line = f" (modules {' '.join(circuit_modules)})\n" if circuit_modules else ""
    
    # Only include input.txt dependency if it exists
    has_input_txt = "input.txt" in files
    input_deps_line = " (deps input.txt)" if has_input_txt else ""
    
    (build_dir / "dune").write_text(f"""(library
 (name user_circuit)
 (libraries {libs}){modules_line}(preprocess
  (pps ppx_hardcaml ppx_jane)))

(library
 (name user_test)
 (libraries 
   {test_libs})
 (modules test harness_utils)
 (wrapped false)
 (inline_tests{input_deps_line})
 (preprocess
  (pps ppx_hardcaml ppx_jane ppx_expect)))
""")

    # Write user files to root (flat layout)
    for filename, content in files.items():
        if filename.endswith(".ml") or filename.endswith(".mli") or filename == "input.txt":
            (build_dir / filename).write_text(content)


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


def read_vcd_file(build_dir: Optional[Path] = None) -> Optional[str]:
    """
    Read the VCD file generated by the test.
    Returns the VCD content as a string, or None if not found.
    """
    # Try per-build path first (from env var)
    vcd_path = os.getenv("HARDCAML_VCD_PATH")
    if vcd_path:
        try:
            path = Path(vcd_path)
            if path.exists():
                return path.read_text()
        except Exception:
            pass

    # Fallback to legacy global path (for backwards compatibility)
    legacy_path = Path("/tmp/waveform.vcd")
    try:
        if legacy_path.exists():
            return legacy_path.read_text()
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
    timeout_seconds: int = 30,
    include_vcd: bool = True,
    session_id: Optional[str] = None,
    project_type: Optional[str] = None,
) -> CompileResult:
    """
    Compile and run Hardcaml code.

    1. Get or create build directory (cached if session_id provided)
    2. Set up project with user files
    3. Run dune build @runtest
    4. Parse and return results

    Args:
        files: Map of filename to content
        timeout_seconds: Max time for build
        include_vcd: Whether to generate VCD output
        session_id: Optional browser session ID for workspace caching
        project_type: Optional project type ("standard" or "n2t"). If None, inferred from files.
    """
    build_dir = None
    use_temp_dir = session_id is None
    cache_hit = False
    total_start = time.time()

    try:
        # Check result cache first (before any work)
        result_cache = get_result_cache()
        # Include include_vcd in cache key since it affects the result
        cache_key_files = {**files, "__include_vcd__": str(include_vcd)}
        cached_result = result_cache.get(cache_key_files)
        if cached_result:
            # Return cached result, but adjust VCD if needed
            if not include_vcd and cached_result.waveform_vcd:
                # Create a copy without VCD if it wasn't requested
                cached_result = CompileResult(
                    success=cached_result.success,
                    output=cached_result.output,
                    waveform=cached_result.waveform,
                    waveform_vcd=None,  # Don't include VCD if not requested
                    error_type=cached_result.error_type,
                    error_message=cached_result.error_message,
                    stage=cached_result.stage,
                    compile_time_ms=0,  # Cached, so no compile time
                    run_time_ms=cached_result.run_time_ms,
                    tests_passed=cached_result.tests_passed,
                    tests_failed=cached_result.tests_failed,
                )
            else:
                # Use cached result as-is, but mark compile_time_ms as 0 for cache hit
                cached_result = CompileResult(
                    success=cached_result.success,
                    output=cached_result.output,
                    waveform=cached_result.waveform,
                    waveform_vcd=cached_result.waveform_vcd if include_vcd else None,
                    error_type=cached_result.error_type,
                    error_message=cached_result.error_message,
                    stage=cached_result.stage,
                    compile_time_ms=0,  # Cached, so no compile time
                    run_time_ms=cached_result.run_time_ms,
                    tests_passed=cached_result.tests_passed,
                    tests_failed=cached_result.tests_failed,
                )
            log.info(
                f"[compile] Result cache hit: session={session_id[:8] if session_id else 'none'}"
            )
            return cached_result

        # Determine project type
        if project_type is None:
            is_n2t = _is_n2t_project(files)
        else:
            is_n2t = project_type == "n2t"
        project_type = "n2t" if is_n2t else "standard"
        file_names = list(files.keys())
        log.info(
            f"[compile] Starting: session={session_id[:8] if session_id else 'none'}, type={project_type}, files={file_names}"
        )

        # Get or create build directory
        t0 = time.time()
        if session_id:
            # Use session-based cached workspace
            template_dir = _get_n2t_template_dir() if is_n2t else _get_standard_template_dir()
            log.info(f"[compile] Using template: {template_dir}")

            cache = get_workspace_cache()
            build_dir, cache_hit = cache.get_or_create(session_id, is_n2t, template_dir)
            log.info(
                f"[timing] get_workspace (cache_hit={cache_hit}): "
                f"{int((time.time() - t0) * 1000)}ms"
            )

            # Check workspace state
            ws_build_dir = build_dir / "_build"
            ws_src_files = (
                list(build_dir.glob("*.ml"))
                if build_dir.exists()
                else []
            )
            log.info(
                f"[compile] Workspace: path={build_dir}, has_build={ws_build_dir.exists()}, "
                f"src_files={[f.name for f in ws_src_files]}"
            )

            # Update user files in the workspace
            t0 = time.time()
            cache.update_workspace(session_id, files)
            log.info(f"[timing] update_workspace: {int((time.time() - t0) * 1000)}ms")
        else:
            # Legacy: use temp directory (no caching)
            build_dir = create_build_dir()
            log.info(f"[timing] create_build_dir: {int((time.time() - t0) * 1000)}ms")

            # Set up project (copy template + write user files)
            t0 = time.time()
            setup_project(build_dir, files, project_type=project_type)
            log.info(f"[timing] setup_project: {int((time.time() - t0) * 1000)}ms")

        # Set up VCD path if requested
        vcd_path = None
        dune_env = {}
        if include_vcd:
            vcd_path = build_dir / "waveform.vcd"
            dune_env["HARDCAML_VCD_PATH"] = str(vcd_path)

        # Enable dune shared cache for faster builds
        dune_cache_root = os.getenv("DUNE_CACHE_ROOT", "/tmp/dune-cache")
        dune_env["DUNE_CACHE"] = "enabled"
        dune_env["DUNE_CACHE_ROOT"] = dune_cache_root

        # Check dune cache state
        dune_cache_path = Path(dune_cache_root)
        cache_exists = dune_cache_path.exists()
        cache_size = (
            sum(f.stat().st_size for f in dune_cache_path.rglob("*") if f.is_file())
            if cache_exists
            else 0
        )
        log.info(
            f"[compile] Dune cache: path={dune_cache_root}, exists={cache_exists}, size={cache_size // 1024}KB"
        )

        # Build and run tests
        # Note: No --force flag to allow dune's incremental build cache
        # Note: No --auto-promote - we don't want to rewrite test files
        log.info(f"[compile] Running: dune build @runtest (cwd={build_dir})")
        t0 = time.time()
        returncode, stdout, stderr = run_command(
            ["dune", "build", "@runtest"],
            cwd=build_dir,
            timeout=timeout_seconds,
            env=dune_env,
        )
        dune_time = int((time.time() - t0) * 1000)
        log.info(f"[timing] dune build @runtest: {dune_time}ms (exit={returncode})")

        # Log if there were any errors
        if returncode != 0 and stderr:
            # Just first 500 chars of error for debugging
            log.info(f"[compile] dune stderr (first 500 chars): {stderr[:500]}")

        # Parse output
        t0 = time.time()
        combined_output = stdout + "\n" + stderr
        parsed = parse_output(combined_output)
        log.info(f"[timing] parse_output: {int((time.time() - t0) * 1000)}ms")

        # Read VCD file if it was generated
        vcd = None
        if include_vcd:
            vcd = read_vcd_file(build_dir)
            if vcd:
                log.info(f"[timing] read VCD file: {len(vcd)} bytes")

        total_time = int((time.time() - total_start) * 1000)
        log.info(
            f"[timing] total (before cleanup): {total_time}ms | "
            f"session={session_id[:8] if session_id else 'none'}, "
            f"cache_hit={cache_hit}, dune={dune_time}ms"
        )

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

        result = CompileResult(
            success=True,
            output=parsed.test_output,
            waveform=parsed.waveform,
            waveform_vcd=vcd,
            compile_time_ms=dune_time,
            tests_passed=parsed.tests_passed,
            tests_failed=parsed.tests_failed,
        )

        # Cache successful result
        result_cache.put(cache_key_files, result)

        return result

    except Exception as e:
        return CompileResult(
            success=False,
            error_type="internal_error",
            error_message=str(e),
            stage="setup",
        )

    finally:
        # Cleanup build directory (only for temp dirs, not cached workspaces)
        if use_temp_dir and build_dir and build_dir.exists():
            t0 = time.time()
            try:
                shutil.rmtree(build_dir)
            except Exception:
                pass  # Best effort cleanup
            log.info(f"[timing] cleanup: {int((time.time() - t0) * 1000)}ms")
