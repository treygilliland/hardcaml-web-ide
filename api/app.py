"""FastAPI application factory and configuration."""

import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from rate_limit import limiter, rate_limit_exceeded_handler
from routes import router
from slowapi.errors import RateLimitExceeded
from config import CORS_ORIGINS, validate_config

logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
log = logging.getLogger(__name__)


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    # Validate configuration on startup
    validate_config()

    log.info("Starting Hardcaml Web IDE API")
    log.info(f"CORS allowed origins: {CORS_ORIGINS}")

    app = FastAPI(
        title="Hardcaml Web IDE",
        description="API for compiling and running Hardcaml circuits",
        version="1.0.0",
    )

    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(router)

    return app


app = create_app()
