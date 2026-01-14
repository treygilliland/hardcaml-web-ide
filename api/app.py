"""FastAPI application factory and configuration."""

import logging

from config import DEV_MODE, STATIC_DIR
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from rate_limit import limiter, rate_limit_exceeded_handler
from routes import router
from slowapi.errors import RateLimitExceeded

logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
log = logging.getLogger(__name__)


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="Hardcaml Web IDE",
        description="API for compiling and running Hardcaml circuits",
        version="1.0.0",
    )

    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, rate_limit_exceeded_handler)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(router)

    if not DEV_MODE:
        app.mount(
            "/assets", StaticFiles(directory=STATIC_DIR / "assets"), name="assets"
        )

        @app.get("/")
        async def serve_frontend():
            return FileResponse(STATIC_DIR / "index.html")

        @app.get("/favicon.png")
        async def serve_favicon():
            return FileResponse(STATIC_DIR / "favicon.png")

    return app


app = create_app()
