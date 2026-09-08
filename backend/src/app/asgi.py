from __future__ import annotations

from litestar import Litestar


def create_app() -> Litestar:
    """Create ASGI application."""

    from litestar.plugins.pydantic import PydanticPlugin

    from app.server.core import ApplicationCore

    return Litestar(plugins=[ApplicationCore(), PydanticPlugin(prefer_alias=True)])
