from __future__ import annotations

from typing import TYPE_CHECKING, Literal, TypeVar

import structlog
from litestar import Controller, MediaType, Request, get
from litestar.response import Response
from sqlalchemy import text

from .schemas import SystemHealth
from .urls import SYSTEM_HEALTH

if TYPE_CHECKING:
    from sqlalchemy.ext.asyncio import AsyncSession

logger = structlog.get_logger()
OnlineOffline = TypeVar("OnlineOffline", bound=Literal["online", "offline"])


class SystemController(Controller):
    tags = ["System"]

    @get(
        operation_id="SystemHealth",
        name="system:health",
        path=SYSTEM_HEALTH,
        media_type=MediaType.JSON,
        cache=False,
        tags=["System"],
        summary="Health Check",
        description="Execute a health check against backend components.  Returns system information including database and cache status.",
    )
    async def check_system_health(
        self,
        request: Request,
        db_session: AsyncSession,
    ) -> Response[SystemHealth]:
        """Check database available and returns app config info."""
        try:
            await db_session.execute(text("select 1"))
            db_ping = True
        except ConnectionRefusedError:
            db_ping = False

        db_status = "online" if db_ping else "offline"
        healthy = db_ping
        if healthy:
            await logger.adebug(
                "System Health",
                database_status=db_status,
            )
        else:
            await logger.awarn(
                "System Health Check",
                database_status=db_status,
            )

        return Response(
            content=SystemHealth(database_status=db_status),  # type: ignore
            status_code=200 if db_ping else 500,
            media_type=MediaType.JSON,
        )
