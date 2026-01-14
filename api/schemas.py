"""Pydantic request/response schemas for the API."""

from pydantic import BaseModel, Field


class CompileRequest(BaseModel):
    """Request to compile and run Hardcaml code."""

    files: dict[str, str] = Field(..., description="Map of filename to file content")
    timeout_seconds: int = Field(
        default=30,
        ge=1,
        le=120,
        description="Maximum time for compilation and test execution",
    )
    include_vcd: bool = Field(
        default=True,
        description="Whether to generate VCD waveform file",
    )
    session_id: str | None = Field(
        default=None,
        description="Browser session ID for workspace caching (enables fast incremental builds)",
    )


class CompileResponse(BaseModel):
    """Response from compilation."""

    success: bool
    output: str | None = None
    waveform: str | None = None
    waveform_vcd: str | None = None
    error_type: str | None = None
    error_message: str | None = None
    stage: str | None = None
    compile_time_ms: int | None = None
    run_time_ms: int | None = None
    tests_passed: int | None = None
    tests_failed: int | None = None
