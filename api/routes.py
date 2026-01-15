"""API route handlers."""

from config import COMPILE_TIMEOUT_SECONDS, RATE_LIMIT_PER_MINUTE
from fastapi import APIRouter, HTTPException, Request
from rate_limit import limiter
from schemas import CompileRequest, CompileResponse
from workspace_cache import get_workspace_cache

router = APIRouter()


@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "hardcaml-web-ide"}


@router.get("/cache/stats")
async def cache_stats():
    """Get workspace cache statistics (for debugging)."""
    cache = get_workspace_cache()
    return cache.get_stats()


@router.post("/compile", response_model=CompileResponse)
@limiter.limit(f"{RATE_LIMIT_PER_MINUTE}/minute")
async def compile_code(request: Request, compile_request: CompileRequest):
    """Compile and run Hardcaml code."""
    # Lazy import to avoid loading compiler module at startup
    from compiler import compile_and_run

    circuit_files = [
        f for f in compile_request.files.keys() if f.endswith(".ml") and f != "test.ml"
    ]
    if not circuit_files:
        raise HTTPException(status_code=400, detail="Missing required circuit .ml file")
    if "test.ml" not in compile_request.files:
        raise HTTPException(status_code=400, detail="Missing required file: test.ml")

    try:
        # Use environment variable timeout, but allow request to override if it's less
        timeout = min(compile_request.timeout_seconds, COMPILE_TIMEOUT_SECONDS)
        result = compile_and_run(
            files=compile_request.files,
            timeout_seconds=timeout,
            include_vcd=compile_request.include_vcd,
            session_id=compile_request.session_id,
        )
        return CompileResponse(
            success=result.success,
            output=result.output,
            waveform=result.waveform,
            waveform_vcd=result.waveform_vcd,
            error_type=result.error_type,
            error_message=result.error_message,
            stage=result.stage,
            compile_time_ms=result.compile_time_ms,
            run_time_ms=result.run_time_ms,
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
