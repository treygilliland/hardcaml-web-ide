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

try:
    COMPILE_TIMEOUT_SECONDS = int(os.environ.get("COMPILE_TIMEOUT_SECONDS", "300"))
except Exception:
    COMPILE_TIMEOUT_SECONDS = 300

# CORS Configuration
# Comma-separated list of allowed origins
# Default allows localhost for development
CORS_ORIGINS_STR = os.environ.get(
    "CORS_ORIGINS",
    "http://localhost:4321,http://localhost:5173,http://localhost:8080"
)
CORS_ORIGINS = [origin.strip() for origin in CORS_ORIGINS_STR.split(",") if origin.strip()]

# Validation
def validate_config():
    """Validate configuration on startup."""
    if RATE_LIMIT_PER_MINUTE <= 0:
        raise ValueError("RATE_LIMIT_PER_MINUTE must be positive")
    if COMPILE_TIMEOUT_SECONDS > 600:
        import logging
        log = logging.getLogger(__name__)
        log.warning("COMPILE_TIMEOUT_SECONDS is very high: %d", COMPILE_TIMEOUT_SECONDS)
    if not CORS_ORIGINS:
        raise ValueError("CORS_ORIGINS must not be empty")
