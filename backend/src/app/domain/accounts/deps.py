"""User Account Controllers."""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

from app.db import models as m
from app.domain.accounts.services import UserService
from app.lib.deps import create_service_provider
from sqlalchemy.orm import joinedload, selectinload

if TYPE_CHECKING:
    from litestar import Request

# create a hard reference to this since it's used oven
provide_users_service = create_service_provider(
    UserService,
    load=[
        selectinload(m.User.roles).options(joinedload(m.UserRole.role, innerjoin=True)),
        m.User.profile,
    ],
    error_messages={
        "duplicate_key": "This user already exists.",
        "integrity": "User operation failed.",
    },
)


async def provide_user(request: Request[m.User, Any, Any]) -> m.User:
    """Get the user from the request.

    Args:
        request: current Request.

    Returns:
        User
    """
    return request.user
