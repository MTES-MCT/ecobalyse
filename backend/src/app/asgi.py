from __future__ import annotations

from typing import TYPE_CHECKING

from litestar import Litestar

if TYPE_CHECKING:
    from litestar import Litestar


def create_app() -> Litestar:
    """Create ASGI application."""

    from app.server.core import ApplicationCore

    return Litestar(plugins=[ApplicationCore()])
