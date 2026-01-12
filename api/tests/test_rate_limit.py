"""
Test rate limiting functionality.
"""

import pytest
from app import app
from fastapi.testclient import TestClient
from rate_limit import limiter

MINIMAL_FILES = {
    "circuit.ml": "let x = 1",
    "circuit.mli": "(* empty *)",
    "test.ml": 'let%expect_test _ = print_endline "ok"',
}


@pytest.fixture(scope="function")
def client():
    """Create a fresh test client with rate limit state reset."""
    limiter.reset()
    with TestClient(app, raise_server_exceptions=False) as client:
        yield client


def test_rate_limit_allows_initial_requests(client: TestClient):
    """First request should succeed (not be rate limited)."""
    response = client.post(
        "/compile", json={"files": MINIMAL_FILES, "timeout_seconds": 5}
    )
    assert response.status_code != 429


def test_rate_limit_blocks_excessive_requests(client: TestClient):
    """Requests beyond the limit should return 429."""
    for i in range(5):
        response = client.post(
            "/compile", json={"files": MINIMAL_FILES, "timeout_seconds": 5}
        )
        if response.status_code == 429:
            result = response.json()
            assert result["success"] is False
            assert result["error_type"] == "rate_limit"
            assert "wait" in result["error_message"].lower()
            assert "Retry-After" in response.headers
            return

    pytest.fail("Rate limit was never triggered after 5 requests (test config: 2/min)")


def test_rate_limit_response_format(client: TestClient):
    """Rate limit response should match CompileResponse schema and include Retry-After header."""
    response = None
    for _ in range(5):
        response = client.post(
            "/compile", json={"files": MINIMAL_FILES, "timeout_seconds": 5}
        )
        if response.status_code == 429:
            break

    assert response is not None
    assert response.status_code == 429
    assert "Retry-After" in response.headers
    result = response.json()
    assert "success" in result
    assert "error_type" in result
    assert "error_message" in result
