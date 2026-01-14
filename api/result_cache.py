"""
Result cache for compilation outputs keyed by content hash.

Caches CompileResult objects by hashing the input files, enabling
instant returns for repeated compilations of the same code.
"""

from __future__ import annotations

import hashlib
import logging
import threading
import time
from collections import OrderedDict
from dataclasses import dataclass, field
from typing import Optional

log = logging.getLogger(__name__)

# Default configuration
DEFAULT_MAX_SIZE = 100
DEFAULT_TTL_SECONDS = 3600  # 1 hour


@dataclass
class CacheEntry:
    """A cached compilation result."""

    result: CompileResult  # type: ignore
    created_at: float = field(default_factory=time.time)


class ResultCache:
    """
    LRU cache of compilation results keyed by content hash.

    Caches successful compilation results to avoid recompiling identical code.
    When cache is full, evicts least recently used entries.
    """

    def __init__(
        self, max_size: int = DEFAULT_MAX_SIZE, ttl_seconds: int = DEFAULT_TTL_SECONDS
    ):
        self.max_size = max_size
        self.ttl_seconds = ttl_seconds
        # OrderedDict maintains insertion order; we move items to end on access
        self._cache: OrderedDict[str, CacheEntry] = OrderedDict()
        self._lock = threading.Lock()

        log.info(f"ResultCache initialized: max_size={max_size}, ttl={ttl_seconds}s")

    def _hash_files(self, files: dict[str, str]) -> str:
        """
        Generate a deterministic hash of the file contents.

        Files are sorted by name to ensure consistent hashing regardless of dict order.
        """
        # Sort files by name for consistent hashing
        sorted_files = sorted(files.items())
        # Create a string representation: "filename1:content1\nfilename2:content2\n..."
        content = "\n".join(f"{name}:{content}" for name, content in sorted_files)
        # Hash the content
        return hashlib.sha256(content.encode("utf-8")).hexdigest()

    def _is_expired(self, entry: CacheEntry) -> bool:
        """Check if a cache entry has expired."""
        if self.ttl_seconds <= 0:
            return False  # TTL disabled
        return (time.time() - entry.created_at) > self.ttl_seconds

    def get(self, files: dict[str, str]) -> Optional[CompileResult]:
        """
        Get a cached result for the given files, if available.

        Returns:
            Cached CompileResult if found and not expired, None otherwise.
        """
        key = self._hash_files(files)

        with self._lock:
            if key not in self._cache:
                return None

            entry = self._cache[key]

            # Check expiration
            if self._is_expired(entry):
                del self._cache[key]
                log.debug(f"Cache entry expired for key {key[:8]}...")
                return None

            # Move to end (most recently used)
            self._cache.move_to_end(key)
            log.debug(f"Cache hit for key {key[:8]}...")
            return entry.result

    def put(self, files: dict[str, str], result: CompileResult) -> None:
        """
        Cache a compilation result.

        Only caches successful compilations to avoid caching errors.
        """
        # Only cache successful results
        if not result.success:
            return

        key = self._hash_files(files)

        with self._lock:
            # Evict if at capacity
            while len(self._cache) >= self.max_size:
                # Remove oldest entry (first in OrderedDict)
                oldest_key = next(iter(self._cache))
                del self._cache[oldest_key]
                log.debug(f"Evicted cache entry for key {oldest_key[:8]}...")

            # Add new entry
            self._cache[key] = CacheEntry(result=result)
            log.debug(
                f"Cached result for key {key[:8]}... (size: {len(self._cache)}/{self.max_size})"
            )

    def clear(self) -> None:
        """Clear all cached results."""
        with self._lock:
            self._cache.clear()
        log.info("Result cache cleared")

    def get_stats(self) -> dict:
        """Get cache statistics."""
        with self._lock:
            expired_count = sum(
                1 for entry in self._cache.values() if self._is_expired(entry)
            )
            return {
                "max_size": self.max_size,
                "current_size": len(self._cache),
                "ttl_seconds": self.ttl_seconds,
                "expired_entries": expired_count,
            }


# Global singleton instance
_cache_instance: Optional[ResultCache] = None
_cache_lock = threading.Lock()


def get_result_cache() -> ResultCache:
    """Get the global result cache instance."""
    global _cache_instance
    if _cache_instance is None:
        with _cache_lock:
            if _cache_instance is None:
                from config import RESULT_CACHE_SIZE, RESULT_CACHE_TTL

                _cache_instance = ResultCache(
                    max_size=RESULT_CACHE_SIZE, ttl_seconds=RESULT_CACHE_TTL
                )
    return _cache_instance
