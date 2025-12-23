"""
Hardcaml Web IDE - FastAPI Server

Provides an API for compiling and running Hardcaml circuits with tests.
"""

import logging
import time
from pathlib import Path
from typing import Optional

from compiler import CompileResult, compile_and_run
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")

app = FastAPI(
    title="Hardcaml Web IDE",
    description="API for compiling and running Hardcaml circuits",
    version="1.0.0",
)

# Enable CORS for frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve frontend - check multiple possible locations
STATIC_DIR = Path("/app/static")
if not STATIC_DIR.exists():
    STATIC_DIR = Path(__file__).parent.parent / "frontend" / "dist"

# Dev mode: no static files, frontend served by Vite
DEV_MODE = not STATIC_DIR.exists() or not (STATIC_DIR / "index.html").exists()


class CompileRequest(BaseModel):
    """Request to compile and run Hardcaml code."""

    files: dict[str, str] = Field(
        ...,
        description="Map of filename to file content",
        examples=[
            {
                "circuit.ml": "open! Core\nopen! Hardcaml...",
                "circuit.mli": "(* interface *)",
                "test.ml": "open! Core...",
            }
        ],
    )
    timeout_seconds: int = Field(
        default=30,
        ge=1,
        le=120,
        description="Maximum time for compilation and test execution",
    )


class CompileResponse(BaseModel):
    """Response from compilation."""

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


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "hardcaml-web-ide"}


@app.post("/compile", response_model=CompileResponse)
async def compile_code(request: CompileRequest):
    """
    Compile and run Hardcaml code.

    Expects files:
    - At least one .ml file for the circuit implementation
    - test.ml: The test file with expect tests
    - Optionally a .mli interface file
    """
    start_time = time.time()

    # Validate required files - need at least one .ml file (other than test.ml)
    circuit_files = [
        f for f in request.files.keys() if f.endswith(".ml") and f != "test.ml"
    ]
    if not circuit_files:
        raise HTTPException(status_code=400, detail="Missing required circuit .ml file")
    if "test.ml" not in request.files:
        raise HTTPException(status_code=400, detail="Missing required file: test.ml")

    try:
        result: CompileResult = compile_and_run(
            files=request.files, timeout_seconds=request.timeout_seconds
        )

        total_time = int((time.time() - start_time) * 1000)

        if result.success:
            return CompileResponse(
                success=True,
                output=result.output,
                waveform=result.waveform,
                waveform_vcd=result.waveform_vcd,
                compile_time_ms=result.compile_time_ms,
                run_time_ms=result.run_time_ms,
                tests_passed=result.tests_passed,
                tests_failed=result.tests_failed,
            )
        else:
            return CompileResponse(
                success=False,
                output=result.output,
                waveform=result.waveform,
                waveform_vcd=result.waveform_vcd,
                error_type=result.error_type,
                error_message=result.error_message,
                stage=result.stage,
                compile_time_ms=total_time,
                tests_passed=result.tests_passed,
                tests_failed=result.tests_failed,
            )

    except Exception as e:
        return CompileResponse(
            success=False,
            error_type="internal_error",
            error_message=str(e),
            stage="unknown",
        )


@app.get("/examples")
async def list_examples():
    """List available example circuits."""
    return {
        "examples": [
            {
                "id": "counter",
                "name": "Simple Counter",
                "description": "An 8-bit counter with enable signal",
            },
            {
                "id": "day1_part1",
                "name": "AoC Day 1 Part 1",
                "description": "Advent of Code 2025 Day 1 - Dial rotation counter",
            },
        ]
    }


# Serve frontend static files (production only)
if not DEV_MODE:
    app.mount("/assets", StaticFiles(directory=STATIC_DIR / "assets"), name="assets")

    @app.get("/")
    async def serve_frontend():
        return FileResponse(STATIC_DIR / "index.html")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
