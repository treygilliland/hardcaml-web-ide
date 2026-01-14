"""
Manifest of testable HardCaml examples.

Thin wrapper around hardcaml/examples_manifest.py for API test compatibility.
"""

import sys
from pathlib import Path

# Add hardcaml directory to path so we can import examples_manifest
PROJECT_ROOT = Path(__file__).parent.parent.parent
HARDCAML_DIR = PROJECT_ROOT / "hardcaml"
sys.path.insert(0, str(HARDCAML_DIR))

from examples_manifest import (
    Example,
    N2T_CHIPS,
    STANDARD_EXAMPLES,
    get_all_testable_examples,
    get_example_by_id,
    get_example_ids,
)

# Re-export for backward compatibility
__all__ = [
    "Example",
    "N2T_CHIPS",
    "STANDARD_EXAMPLES",
    "get_all_testable_examples",
    "get_example_by_id",
    "get_example_ids",
]
