"""
Session-based workspace cache with LRU eviction.

Provides persistent build directories keyed by session ID, enabling
browser sessions to reuse their warm dune build cache across requests.
"""

import logging
import shutil
import threading
import time
from collections import OrderedDict
from dataclasses import dataclass, field
from pathlib import Path

log = logging.getLogger(__name__)

# Default configuration
DEFAULT_MAX_SLOTS = 10
DEFAULT_CACHE_ROOT = Path("/tmp/hardcaml-workspaces")


@dataclass
class WorkspaceSlot:
    """A cached workspace slot."""

    session_id: str
    path: Path
    is_n2t: bool
    last_accessed: float = field(default_factory=time.time)
    lock: threading.Lock = field(default_factory=threading.Lock)


class WorkspaceCache:
    """
    LRU cache of pre-built workspaces keyed by session ID.

    Each session gets a dedicated build directory that persists across
    requests, allowing dune's incremental build to work effectively.
    When the cache is full, the least recently used workspace is evicted.
    """

    def __init__(
        self,
        max_slots: int = DEFAULT_MAX_SLOTS,
        cache_root: Path = DEFAULT_CACHE_ROOT,
    ):
        self.max_slots = max_slots
        self.cache_root = cache_root
        self.cache_root.mkdir(parents=True, exist_ok=True)

        # OrderedDict maintains insertion order; we move items to end on access
        self._slots: OrderedDict[str, WorkspaceSlot] = OrderedDict()
        self._global_lock = threading.Lock()

        log.info(
            f"WorkspaceCache initialized: max_slots={max_slots}, root={cache_root}"
        )

    def get_or_create(
        self,
        session_id: str,
        is_n2t: bool,
        template_dir: Path,
    ) -> tuple[Path, bool]:
        """
        Get or create a workspace for the given session.

        Returns:
            Tuple of (workspace_path, is_cache_hit)
        """
        with self._global_lock:
            # Check if session already has a workspace
            if session_id in self._slots:
                slot = self._slots[session_id]

                # Check if project type matches (n2t vs standard)
                if slot.is_n2t != is_n2t:
                    # Project type changed - need to recreate
                    log.info(
                        f"Session {session_id[:8]} changed project type, recreating"
                    )
                    self._evict_slot(session_id)
                else:
                    # Move to end (most recently used)
                    self._slots.move_to_end(session_id)
                    slot.last_accessed = time.time()
                    log.info(f"Cache hit for session {session_id[:8]}")
                    return slot.path, True

            # Need to create new workspace
            # First, evict if at capacity
            while len(self._slots) >= self.max_slots:
                self._evict_lru()

            # Create new workspace
            workspace_path = self._create_workspace(session_id, is_n2t, template_dir)
            slot = WorkspaceSlot(
                session_id=session_id,
                path=workspace_path,
                is_n2t=is_n2t,
            )
            self._slots[session_id] = slot
            log.info(
                f"Created new workspace for session {session_id[:8]} "
                f"(slots: {len(self._slots)}/{self.max_slots})"
            )
            return workspace_path, False

    def _create_workspace(
        self, session_id: str, is_n2t: bool, template_dir: Path
    ) -> Path:
        """Create a new workspace from template."""
        workspace_path = self.cache_root / session_id
        if workspace_path.exists():
            shutil.rmtree(workspace_path)

        # Check template contents
        template_build = template_dir / "_build"
        # For flat layout, check root for files
        template_files = list(template_dir.glob("*.ml")) if template_dir.exists() else []
        build_size = (
            sum(f.stat().st_size for f in template_build.rglob("*") if f.is_file())
            if template_build.exists()
            else 0
        )

        log.info(
            f"Creating workspace: template={template_dir}, "
            f"has_build={template_build.exists()} ({build_size // 1024}KB), "
            f"files={[f.name for f in template_files]}"
        )

        t0 = time.time()
        shutil.copytree(template_dir, workspace_path)
        
        # Remove src/ and test/ directories if they exist (we use flat layout)
        for subdir in ["src", "test"]:
            subdir_path = workspace_path / subdir
            if subdir_path.exists():
                shutil.rmtree(subdir_path)
        
        # Copy harness_utils.ml from test/ to root if it exists
        template_harness = template_dir / "test" / "harness_utils.ml"
        if template_harness.exists():
            shutil.copy2(template_harness, workspace_path / "harness_utils.ml")
        
        copy_time = int((time.time() - t0) * 1000)

        # Verify _build was copied
        workspace_build = workspace_path / "_build"
        if workspace_build.exists():
            ws_build_size = sum(
                f.stat().st_size for f in workspace_build.rglob("*") if f.is_file()
            )
            log.info(
                f"Workspace created ({session_id[:8]}): copy_time={copy_time}ms, _build={ws_build_size // 1024}KB"
            )
        else:
            log.info(
                f"Workspace created ({session_id[:8]}): copy_time={copy_time}ms, NO _build copied"
            )

        return workspace_path

    def _evict_slot(self, session_id: str) -> None:
        """Evict a specific session's workspace."""
        if session_id not in self._slots:
            return
        slot = self._slots.pop(session_id)
        try:
            if slot.path.exists():
                shutil.rmtree(slot.path)
            log.info(f"Evicted workspace for session {session_id[:8]}")
        except Exception as e:
            log.warning(f"Failed to clean up workspace {slot.path}: {e}")

    def _evict_lru(self) -> None:
        """Evict the least recently used workspace."""
        if not self._slots:
            return
        # First item in OrderedDict is the LRU
        session_id, slot = next(iter(self._slots.items()))
        self._evict_slot(session_id)

    def update_workspace(
        self,
        session_id: str,
        files: dict[str, str],
    ) -> None:
        """
        Update user files in an existing workspace (flat layout).

        This writes the user's source files to the workspace root,
        preserving the _build/ directory for incremental builds.
        """
        with self._global_lock:
            if session_id not in self._slots:
                raise KeyError(f"No workspace for session {session_id}")
            slot = self._slots[session_id]

        # Ensure dune file exists (flat layout)
        # Determine if this is an N2T project using same logic as compiler.py
        circuit_files = [f for f in files.keys() if f.endswith(".ml") and f != "test.ml"]
        is_n2t = "circuit.ml" not in circuit_files
        
        libs = "core hardcaml"
        if is_n2t:
            libs += " n2t_chips"
        
        test_libs = "core hardcaml hardcaml_waveterm hardcaml_test_harness"
        if is_n2t:
            test_libs += " n2t_chips"
        test_libs += " user_circuit"
        
        # Determine circuit modules dynamically
        circuit_modules = [
            f[:-3]  # Remove .ml extension
            for f in files.keys()
            if f.endswith(".ml") and f not in ("test.ml", "harness_utils.ml")
        ]
        if is_n2t:
            # For N2T projects, include all circuit files
            modules_list = circuit_modules if circuit_modules else None
        else:
            # For standard projects, only include circuit if it exists
            if "circuit" in circuit_modules:
                modules_list = ["circuit"]
            else:
                modules_list = circuit_modules if circuit_modules else None
        
        modules_line = f" (modules {' '.join(modules_list)})\n" if modules_list else ""
        
        # Only include input.txt dependency if it exists
        has_input_txt = "input.txt" in files
        input_deps_line = " (deps input.txt)" if has_input_txt else ""
        
        dune_file = slot.path / "dune"
        dune_content = f"""(library
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
"""
        # Always write dune file (may change if project type changes)
        dune_file.write_text(dune_content)
        
        # Ensure harness_utils.ml exists
        harness_file = slot.path / "harness_utils.ml"
        if not harness_file.exists():
            harness_file.write_text("""open! Hardcaml_waveterm

let write_vcd_if_requested waves =
  match Sys.getenv_opt "HARDCAML_VCD_PATH" with
  | Some path -> Waveform.Serialize.marshall_vcd waves path
  | None -> ()
""")

        # Write files to root (flat layout)
        for filename, content in files.items():
            if filename.endswith(".ml") or filename.endswith(".mli") or filename == "input.txt":
                file_path = slot.path / filename
            else:
                continue  # Skip unknown file types

            # Skip writing if content hasn't changed (preserves mtime for dune)
            if file_path.exists():
                try:
                    existing_content = file_path.read_text()
                    if existing_content == content:
                        continue  # Content unchanged, skip write
                except Exception:
                    # If read fails, write anyway
                    pass

            file_path.write_text(content)

    def get_stats(self) -> dict:
        """Get cache statistics."""
        with self._global_lock:
            slots_info = []
            for session_id, slot in self._slots.items():
                slots_info.append(
                    {
                        "session_id": session_id[:8] + "...",
                        "is_n2t": slot.is_n2t,
                        "age_seconds": int(time.time() - slot.last_accessed),
                    }
                )
            return {
                "max_slots": self.max_slots,
                "used_slots": len(self._slots),
                "slots": slots_info,
            }

    def clear(self) -> None:
        """Clear all cached workspaces."""
        with self._global_lock:
            for session_id in list(self._slots.keys()):
                self._evict_slot(session_id)
        log.info("Workspace cache cleared")


# Global singleton instance
_cache_instance: WorkspaceCache | None = None
_cache_lock = threading.Lock()


def get_workspace_cache() -> WorkspaceCache:
    """Get the global workspace cache instance."""
    global _cache_instance
    if _cache_instance is None:
        with _cache_lock:
            if _cache_instance is None:
                _cache_instance = WorkspaceCache()
    return _cache_instance
