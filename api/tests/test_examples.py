"""
API integration test - validates the compile endpoint works end-to-end.
"""

import pytest
from fastapi.testclient import TestClient

from main import app

from .examples import get_example_by_id


@pytest.fixture(scope="function")
def client():
    """Create a fresh test client for each test."""
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
