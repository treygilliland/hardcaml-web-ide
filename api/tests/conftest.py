"""Pytest configuration - runs before any test imports."""

import os

os.environ["RATE_LIMIT_PER_MINUTE"] = "2"
