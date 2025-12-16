"""User Account Controllers."""

from __future__ import annotations

import uuid
from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.filters import (
    OrderBy,
)
from advanced_alchemy.service.typing import (
    convert,
)
from advanced_alchemy.utils.text import slugify
from app.db import models as m
from app.domain.accounts import tasks, urls
from app.domain.accounts.deps import provide_users_service
from app.domain.accounts.guards import auth, requires_active_user, requires_superuser
from app.domain.accounts.schemas import (
    AccountLogin,
    AccountRegisterMagicLink,
    ApiToken,
    ApiTokenFromDb,
    User,
    UserProfileUpdate,
)
from app.domain.accounts.services import RoleService, TokenService, UserProfileService
from app.lib import http
from app.lib.deps import create_service_provider
from litestar import Controller, Request, Response, delete, get, patch, post
from litestar.background_tasks import BackgroundTask
from litestar.di import Provide
from litestar.exceptions import PermissionDeniedException
from litestar.params import Parameter
from litestar.security.jwt import Token

if TYPE_CHECKING:
    from app.domain.accounts.services import UserService
    from litestar.security.jwt import OAuth2Login


from app.config.base import get_settings

settings = get_settings()


class AccessController(Controller):
    """User login and registration."""

    tags = ["Access"]
    dependencies = {
        "profiles_service": Provide(create_service_provider(UserProfileService)),
        "roles_service": Provide(create_service_provider(RoleService)),
        "tokens_service": Provide(create_service_provider(TokenService)),
        "users_service": Provide(provide_users_service),
    }

    @get(operation_id="AccountLogin", path=urls.ACCOUNT_LOGIN, exclude_from_auth=True)
    async def login(
        self, users_service: UserService, email: str, token: str
    ) -> Response[OAuth2Login]:
        """Authenticate a user using a magic link token."""
        user = await users_service.authenticate_magic_token(email, token)
        return auth.login(user.email)

    @post(
        operation_id="AccountLogout", path=urls.ACCOUNT_LOGOUT, exclude_from_auth=True
    )
    async def logout(self, request: Request) -> Response:
        """Account Logout"""
        request.cookies.pop(auth.key, None)
        request.clear_session()

        response = Response(
            {"message": "OK"},
            status_code=200,
        )
        response.delete_cookie(auth.key)

        return response

    @post(
        operation_id="AccountRegisterMagicLink",
        path=urls.ACCOUNT_REGISTER_MAGIC_LINK,
        exclude_from_auth=True,
    )
    async def signup_magic_link(
        self,
        request: Request,
        users_service: UserService,
        roles_service: RoleService,
        data: AccountRegisterMagicLink,
    ) -> User:
        """User Signup."""
        user_data = data.to_dict()

        role_obj = await roles_service.get_one_or_none(
            slug=slugify(users_service.default_role)
        )
        if role_obj is not None:
            user_data.update({"role_id": role_obj.id})

        token = str(uuid.uuid4())
        user_data.update({"magic_link_token": token})

        user = await users_service.create(user_data)

        new_user = await users_service.get_one_or_none(id=user.id)

        background = BackgroundTask(
            tasks.send_magic_link_email_task,
            user_id=user.id,
            user_email=user.email,
            token=token,
            url=http.get_base_url(request),
        )
        return Response(
            users_service.to_schema(new_user, schema_type=User), background=background
        )

    @post(
        operation_id="AccountLoginMagicLink",
        path=urls.ACCOUNT_LOGIN_MAGIC_LINK,
        exclude_from_auth=True,
    )
    async def login_magic_link(
        self,
        request: Request,
        users_service: UserService,
        data: AccountLogin,
    ) -> None:
        """User Login."""

        user = await users_service.get_one_or_none(email=data.email)

        if not user:
            return None

        # Generate new token
        token = str(uuid.uuid4())
        user = await users_service.update(
            item_id=user.id, data={"magic_link_token": token}
        )

        background = BackgroundTask(
            tasks.send_magic_link_email_task,
            user_id=user.id,
            user_email=user.email,
            token=token,
            url=http.get_base_url(request),
        )
        return Response(None, background=background)

    @patch(
        operation_id="UpdateProfile",
        path=urls.ACCOUNT_PROFILE_UPDATE,
        guards=[requires_active_user],
    )
    async def update_profile(
        self,
        data: UserProfileUpdate,
        current_user: m.User,
        users_service: UserService,
        profiles_service: UserProfileService,
    ) -> User:
        """Update an user profile."""
        db_obj = await profiles_service.update(
            item_id=current_user.profile.id, data=data.to_dict()
        )

        return users_service.to_schema(db_obj.user, schema_type=User)

    @get(
        operation_id="AccountProfile",
        path=urls.ACCOUNT_PROFILE,
        guards=[requires_active_user],
    )
    async def profile(self, current_user: m.User, users_service: UserService) -> User:
        """User Profile."""
        return users_service.to_schema(current_user, schema_type=User)

    @post(
        operation_id="ValidateToken",
        path=urls.TOKEN_VALIDATE,
        exclude_from_auth=True,
    )
    async def validate_token(
        self,
        tokens_service: TokenService,
        users_service: UserService,
        data: ApiToken,
    ) -> None:
        """Validate a token"""

        if data.token.startswith("eco_api_"):
            payload = await tokens_service.extract_payload(data.token)

            await tokens_service.authenticate(
                secret=payload["secret"], token_id=payload["id"]
            )

            user = await users_service.get_one_or_none(email=payload["email"])

            if user.profile.terms_accepted:
                return
            else:
                raise PermissionDeniedException(
                    detail="You must accept the terms to have access to detailed impacts"
                )
        else:
            try:
                payload = Token.decode_payload(
                    data.token, settings.app.SECRET_KEY, [auth.algorithm]
                )

                user = await users_service.get_one_or_none(email=payload["sub"])

                if user.profile.terms_accepted:
                    return
                else:
                    raise PermissionDeniedException(
                        detail="You must accept the terms to have access to detailed impacts"
                    )
            except Exception:
                raise PermissionDeniedException(detail="Error decoding Token")

        raise PermissionDeniedException(detail="Invalid token")

    @post(
        operation_id="GenerateToken",
        path=urls.TOKEN_GENERATE,
        guards=[requires_active_user],
    )
    async def generate_token(
        self, current_user: m.User, tokens_service: TokenService
    ) -> ApiToken:
        token = await tokens_service.generate_for_user(current_user)
        return ApiToken(token=token)

    @get(
        operation_id="GetTokens",
        path=urls.TOKEN_LIST,
        guards=[requires_active_user],
    )
    async def get_tokens(
        self, current_user: m.User, tokens_service: TokenService
    ) -> list[ApiTokenFromDb]:
        results = await tokens_service.list(
            m.Token.user == current_user,
            OrderBy(field_name="created_at", sort_order="desc"),
        )

        return convert(
            obj=results,
            type=list[ApiTokenFromDb],  # type: ignore[valid-type]
            from_attributes=True,
        )

    @delete(
        operation_id="DeleteToken",
        guards=[requires_active_user],
        path=urls.TOKEN_DELETE,
    )
    async def delete_token(
        self,
        current_user: m.User,
        tokens_service: TokenService,
        token_id: UUID = Parameter(
            title="Token ID", description="The token to delete."
        ),
    ) -> None:
        """Delete a token."""

        token = await tokens_service.get_one_or_none(
            m.Token.user == current_user, m.Token.id == token_id
        )
        if token:
            _ = await tokens_service.delete(item_id=token_id)
        else:
            msg = "You don’t have the permission to delete this token"
            raise PermissionDeniedException(detail=msg)

    @get(
        operation_id="ListAccounts",
        path=urls.ACCOUNT_LIST,
        guards=[requires_superuser],
    )
    async def list_accounts(
        self,
        users_service: UserService,
    ) -> list[User]:
        """List all accounts."""

        results = await users_service.list(
            OrderBy(field_name="created_at", sort_order="desc"),
        )

        return convert(
            obj=results,
            type=list[User],  # type: ignore[valid-type]
            from_attributes=True,
        )
