"""
API integration test - validates the compile endpoint works end-to-end.
"""

import pytest
from app import app
from fastapi.testclient import TestClient
from rate_limit import limiter

from .examples import get_example_by_id


@pytest.fixture(scope="function")
def client():
    """Create a fresh test client for each test."""
    limiter.reset()
    with TestClient(app, raise_server_exceptions=False) as client:
        yield client


@pytest.mark.parametrize("example_id", ["counter", "n2t_mux", "n2t_alu", "day1_part1"])
def test_example_compiles_and_passes(client: TestClient, example_id: str):
    """Smoke test: key examples compile and pass through the API."""
    example = get_example_by_id(example_id)

    response = client.post(
        "/compile",
        json={
            "files": example.files,
            "timeout_seconds": 15,
        },
    )

    assert response.status_code == 200, f"HTTP error: {response.status_code}"

    result = response.json()
    assert result["success"], (
        f"Compilation failed for {example_id}: "
        f"{result.get('error_type')} - {result.get('error_message')}"
    )
    assert result.get("tests_failed", 0) == 0, (
        f"Tests failed for {example_id}: {result.get('output')}"
    )


def test_health_endpoint(client: TestClient):
    """Verify the health endpoint works."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_vcd_included_when_requested(client: TestClient):
    """Test that VCD is generated when include_vcd=true (default)."""
    example = get_example_by_id("counter")

    response = client.post(
        "/compile",
        json={
            "files": example.files,
            "timeout_seconds": 15,
            "include_vcd": True,
        },
    )

    assert response.status_code == 200
    result = response.json()
    assert result["success"], f"Compilation failed: {result.get('error_message')}"
    assert result.get("waveform_vcd") is not None, "VCD should be present when include_vcd=true"
    assert len(result.get("waveform_vcd", "")) > 0, "VCD should be non-empty"


def test_vcd_excluded_when_not_requested(client: TestClient):
    """Test that VCD is not generated when include_vcd=false."""
    example = get_example_by_id("counter")

    response = client.post(
        "/compile",
        json={
            "files": example.files,
            "timeout_seconds": 15,
            "include_vcd": False,
        },
    )

    assert response.status_code == 200
    result = response.json()
    assert result["success"], f"Compilation failed: {result.get('error_message')}"
    assert result.get("waveform_vcd") is None, "VCD should be null when include_vcd=false"


def test_concurrent_compiles_no_vcd_leakage(client: TestClient):
    """Test that concurrent compile requests don't leak VCD across responses."""
    import concurrent.futures

    example1 = get_example_by_id("counter")
    example2 = get_example_by_id("fibonacci")

    def compile_with_vcd(example, include_vcd):
        response = client.post(
            "/compile",
            json={
                "files": example.files,
                "timeout_seconds": 15,
                "include_vcd": include_vcd,
            },
        )
        result = response.json()
        return result.get("waveform_vcd")

    # Run two concurrent compiles: one with VCD, one without
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        future1 = executor.submit(compile_with_vcd, example1, True)
        future2 = executor.submit(compile_with_vcd, example2, False)

        vcd1 = future1.result()
        vcd2 = future2.result()

    # First should have VCD, second should not
    assert vcd1 is not None and len(vcd1) > 0, "First compile should have VCD"
    assert vcd2 is None, "Second compile should not have VCD (no leakage)"
