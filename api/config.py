"""Application configuration loaded from environment variables."""

import os
from pathlib import Path

try:
    RATE_LIMIT_PER_MINUTE = int(os.environ.get("RATE_LIMIT_PER_MINUTE", "10"))
except Exception:
    RATE_LIMIT_PER_MINUTE = 10

try:
    RESULT_CACHE_SIZE = int(os.environ.get("RESULT_CACHE_SIZE", "100"))
except Exception:
    RESULT_CACHE_SIZE = 100

try:
    RESULT_CACHE_TTL = int(os.environ.get("RESULT_CACHE_TTL", "3600"))
except Exception:
    RESULT_CACHE_TTL = 3600

STATIC_DIR = Path("/app/static")
if not STATIC_DIR.exists():
    STATIC_DIR = Path(__file__).parent.parent / "frontend" / "dist"

DEV_MODE = not STATIC_DIR.exists() or not (STATIC_DIR / "index.html").exists()
