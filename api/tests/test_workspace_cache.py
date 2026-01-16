"""Tests for the workspace cache."""

import tempfile
from pathlib import Path

import pytest

from workspace_cache import WorkspaceCache


@pytest.fixture
def temp_template_dir():
    """Create a temporary template directory with minimal structure (flat layout)."""
    with tempfile.TemporaryDirectory() as tmpdir:
        template = Path(tmpdir) / "template"
        template.mkdir()
        (template / "dune-project").write_text("(lang dune 3.11)")
        (template / "test" / "harness_utils.ml").parent.mkdir(exist_ok=True)
        (template / "test" / "harness_utils.ml").write_text("let x = ()")
        yield template


@pytest.fixture
def cache(temp_template_dir):
    """Create a workspace cache with small max slots for testing."""
    with tempfile.TemporaryDirectory() as cache_root:
        cache = WorkspaceCache(max_slots=3, cache_root=Path(cache_root))
        yield cache, temp_template_dir


def test_create_new_workspace(cache):
    """Test that a new workspace is created for a new session."""
    workspace_cache, template = cache
    path, is_hit = workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    
    assert not is_hit
    assert path.exists()
    assert (path / "dune-project").exists()
    # Flat layout: dune file should be in root, not src/
    assert (path / "dune").exists() or (path / "harness_utils.ml").exists()


def test_reuse_existing_workspace(cache):
    """Test that an existing workspace is reused for the same session."""
    workspace_cache, template = cache
    
    # First request
    path1, is_hit1 = workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    assert not is_hit1
    
    # Second request with same session
    path2, is_hit2 = workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    assert is_hit2
    assert path1 == path2


def test_lru_eviction(cache):
    """Test that LRU eviction works when cache is full."""
    workspace_cache, template = cache
    
    # Fill the cache (max_slots=3)
    path1, _ = workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    path2, _ = workspace_cache.get_or_create("session-2", is_n2t=False, template_dir=template)
    path3, _ = workspace_cache.get_or_create("session-3", is_n2t=False, template_dir=template)
    
    # All paths should exist
    assert path1.exists()
    assert path2.exists()
    assert path3.exists()
    
    # Adding a 4th session should evict session-1 (LRU)
    path4, is_hit = workspace_cache.get_or_create("session-4", is_n2t=False, template_dir=template)
    
    assert not is_hit
    assert not path1.exists()  # Should be evicted
    assert path2.exists()
    assert path3.exists()
    assert path4.exists()


def test_access_updates_lru_order(cache):
    """Test that accessing a workspace updates its LRU position."""
    workspace_cache, template = cache
    
    # Fill the cache
    path1, _ = workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    workspace_cache.get_or_create("session-2", is_n2t=False, template_dir=template)
    workspace_cache.get_or_create("session-3", is_n2t=False, template_dir=template)
    
    # Access session-1 to move it to end
    workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    
    # Adding session-4 should now evict session-2 (oldest after session-1 was re-accessed)
    workspace_cache.get_or_create("session-4", is_n2t=False, template_dir=template)
    
    assert path1.exists()  # Should NOT be evicted (was re-accessed)


def test_update_workspace_files(cache):
    """Test that workspace files can be updated."""
    workspace_cache, template = cache
    
    path, _ = workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    
    files = {
        "circuit.ml": "let x = 1",
        "circuit.mli": "val x : int",
        "test.ml": "let () = print_endline \"test\"",
    }
    workspace_cache.update_workspace("session-1", files)
    
    # Flat layout: files should be in root, not src/ or test/
    assert (path / "circuit.ml").read_text() == "let x = 1"
    assert (path / "circuit.mli").read_text() == "val x : int"
    assert (path / "test.ml").read_text() == "let () = print_endline \"test\""


def test_project_type_change_recreates_workspace(cache):
    """Test that changing project type (n2t vs standard) recreates the workspace."""
    workspace_cache, template = cache
    
    # Create standard workspace
    path1, is_hit1 = workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    assert not is_hit1
    
    # Write a marker file to detect if workspace is recreated
    marker_file = path1 / "marker.txt"
    marker_file.write_text("original")
    
    # Request n2t workspace for same session - should recreate
    path2, is_hit2 = workspace_cache.get_or_create("session-1", is_n2t=True, template_dir=template)
    assert not is_hit2  # Not a cache hit because type changed
    # Marker file should be gone (workspace was recreated)
    assert not marker_file.exists()


def test_get_stats(cache):
    """Test that cache stats are returned correctly."""
    workspace_cache, template = cache
    
    workspace_cache.get_or_create("session-1", is_n2t=False, template_dir=template)
    workspace_cache.get_or_create("session-2", is_n2t=True, template_dir=template)
    
    stats = workspace_cache.get_stats()
    
    assert stats["max_slots"] == 3
    assert stats["used_slots"] == 2
    assert len(stats["slots"]) == 2
