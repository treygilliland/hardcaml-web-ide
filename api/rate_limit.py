"""Rate limiting configuration and handlers."""

import logging

from config import RATE_LIMIT_PER_MINUTE
from fastapi import Request
from fastapi.responses import JSONResponse, Response
from slowapi import Limiter
from slowapi.util import get_remote_address

logger = logging.getLogger(__name__)


def get_client_id(request: Request) -> str:
    """Get client identifier for rate limiting. Uses Cloudflare's real IP if available."""
    return request.headers.get("CF-Connecting-IP", get_remote_address(request))


limiter = Limiter(key_func=get_client_id)


async def rate_limit_exceeded_handler(request: Request, exc: Exception) -> Response:
    """Custom handler for rate limit exceeded errors."""
    client_id = get_client_id(request)
    logger.warning(f"Rate limit exceeded for client {client_id}")

    retry_after = getattr(exc, "retry_after", 60)

    return JSONResponse(
        status_code=429,
        headers={"Retry-After": str(retry_after)},
        content={
            "success": False,
            "error_type": "rate_limit",
            "error_message": f"Too many builds (limit: {RATE_LIMIT_PER_MINUTE}/minute). Please wait a minute before trying again.",
        },
    )
