from __future__ import annotations

import datetime
from typing import TYPE_CHECKING, Any

from app.config import constants
from app.config.app import alchemy
from app.config.base import get_settings
from app.db import models as m
from app.domain.accounts import urls
from app.domain.accounts.deps import provide_users_service
from app.domain.accounts.services import TokenService
from app.lib import crypt
from app.lib.deps import create_service_provider
from app.lib.middleware import CustomCookieAuthMiddleware
from litestar.exceptions import PermissionDeniedException
from litestar.security.jwt import OAuth2PasswordBearerAuth

if TYPE_CHECKING:
    from litestar.connection import ASGIConnection
    from litestar.handlers.base import BaseRouteHandler
    from litestar.security.jwt import Token


__all__ = (
    "auth",
    "current_user_from_token",
    "requires_active_user",
    "requires_superuser",
    "requires_verified_user",
)


settings = get_settings()


def requires_active_user(connection: ASGIConnection, _: BaseRouteHandler) -> None:
    """Request requires active user.

    Verifies the request user is active.

    Args:
        connection (ASGIConnection): HTTP Request
        _ (BaseRouteHandler): Route handler

    Raises:
        PermissionDeniedException: Permission denied exception
    """
    if connection.user.is_active:
        return
    msg = "Inactive account"
    raise PermissionDeniedException(msg)


def requires_superuser(
    connection: ASGIConnection[m.User, Any, Any, Any], _: BaseRouteHandler
) -> None:
    """Request requires active superuser.

    Args:
        connection (ASGIConnection): HTTP Request
        _ (BaseRouteHandler): Route handler

    Raises:
        PermissionDeniedException: Permission denied exception

    Returns:
        None: Returns None when successful
    """
    if connection.user.is_superuser:
        return
    raise PermissionDeniedException(detail="Insufficient privileges")


def requires_verified_user(
    connection: ASGIConnection[m.User, Any, Any, Any], _: BaseRouteHandler
) -> None:
    """Verify the connection user is a superuser.

    Args:
        connection (ASGIConnection): Request/Connection object.
        _ (BaseRouteHandler): Route handler.

    Raises:
        PermissionDeniedException: Not authorized

    Returns:
        None: Returns None when successful
    """
    if connection.user.is_verified:
        return
    raise PermissionDeniedException(detail="User account is not verified.")


async def current_user_from_token(
    token: Token, connection: ASGIConnection[Any, Any, Any, Any]
) -> tuple[m.User, m.Token | None] | None:
    """Lookup current user from local JWT token.

    Fetches the user information from the database


    Args:
        token (str): JWT Token Object
        connection (ASGIConnection[Any, Any, Any, Any]): ASGI connection.


    Returns:
        User: User record mapped to the JWT identifier
    """
    user_service = await anext(
        provide_users_service(
            alchemy.provide_session(connection.app.state, connection.scope)
        )
    )
    user = await user_service.get_one_or_none(email=token.sub)

    token_id = token.extras.get("id")

    if token_id:
        token_service_provider = create_service_provider(TokenService)
        token_service = await anext(
            token_service_provider(
                alchemy.provide_session(connection.app.state, connection.scope)
            )
        )

        db_token = await token_service.get_one_or_none(id=token_id)

        if db_token and await crypt.verify_password(
            token.extras.get("secret"), db_token.hashed_token
        ):
            db_token.last_accessed_at = datetime.datetime.now(datetime.timezone.utc)
            await token_service.repository.update(db_token)
            # Authentication ok
            return (user, db_token)
        else:
            # Authentication failed
            return (user, None)

    return (user, None) if user and user.is_active else None


auth = OAuth2PasswordBearerAuth[m.User](
    authentication_middleware_class=CustomCookieAuthMiddleware,
    default_token_expiration=datetime.timedelta(
        days=settings.app.DEFAULT_TOKEN_EXPIRATION_DAYS
    ),
    retrieve_user_handler=current_user_from_token,
    token_secret=settings.app.SECRET_KEY,
    token_url=urls.ACCOUNT_LOGIN,
    exclude=[
        constants.HEALTH_ENDPOINT,
        "^/schema",
        "^/public/",
    ],
)
