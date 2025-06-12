from __future__ import annotations

import base64
import json
from collections.abc import Sequence
from datetime import UTC, datetime, timedelta, timezone
from functools import cache
from typing import TYPE_CHECKING, Any, Union
from uuid import UUID, uuid4  # noqa: TC003

import msgspec
from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
    SQLAlchemyAsyncSlugRepository,
)
from advanced_alchemy.repository.typing import ModelOrRowMappingT
from advanced_alchemy.service import (
    ModelDictT,
    SQLAlchemyAsyncRepositoryService,
    is_dict,
    is_dict_with_field,
    is_dict_without_field,
    schema_dump,
)
from advanced_alchemy.service.pagination import OffsetPagination
from advanced_alchemy.service.typing import (
    ModelDTOT,
)
from app.config import constants
from app.db import models as m
from app.domain.accounts.schemas import Organization
from app.lib import crypt
from litestar.exceptions import PermissionDeniedException

if TYPE_CHECKING:
    from advanced_alchemy.base import ModelProtocol
    from sqlalchemy import RowMapping


class UserRepository(SQLAlchemyAsyncRepository[m.User]):
    """User SQLAlchemy Repository."""

    model_type = m.User


class UserService(SQLAlchemyAsyncRepositoryService[m.User]):
    """Handles database operations for users."""

    repository_type = UserRepository
    default_role = constants.DEFAULT_USER_ROLE
    match_fields = ["email"]

    async def to_model_on_create(self, data: ModelDictT[m.User]) -> ModelDictT[m.User]:
        return await self._populate_model(data, operation="create")

    async def to_model_on_update(self, data: ModelDictT[m.User]) -> ModelDictT[m.User]:
        return await self._populate_model(data, operation="update")

    async def to_model_on_upsert(self, data: ModelDictT[m.User]) -> ModelDictT[m.User]:
        return await self._populate_model(data, operation="upsert")

    def to_schema(
        self,
        data: "Union[ModelOrRowMappingT, Sequence[ModelOrRowMappingT], ModelProtocol, Sequence[ModelProtocol], RowMapping, Sequence[RowMapping]]",
        **kwargs,
    ) -> "Union[ModelOrRowMappingT, OffsetPagination[ModelOrRowMappingT], ModelDTOT, OffsetPagination[ModelDTOT]]":
        # Convert organization to an object for JSON output
        data.profile.organization = Organization(
            name=data.profile.organization_name or msgspec.UNSET,
            type=data.profile.organization_type,
            siren=data.profile.organization_siren or msgspec.UNSET,
        )
        return super().to_schema(data, **kwargs)

    async def authenticate_magic_token(
        self, username: str, token: bytes | str
    ) -> m.User:
        """Authenticate a user against the stored hashed magic link token."""
        from app.config import get_settings

        settings = get_settings()

        db_obj = await self.get_one_or_none(email=username)

        if db_obj is None:
            msg = "User not found or password invalid"
            raise PermissionDeniedException(detail=msg)

        await self._check_permissions(db_obj, token, db_obj.magic_link_hashed_token)

        db_obj.is_verified = True

        now = datetime.now(timezone.utc)

        if db_obj.magic_link_sent_at and (
            db_obj.magic_link_sent_at
            + timedelta(seconds=settings.email.MAGIC_LINK_DURATION)
            < now
        ):
            msg = "Magic link token expired"
            raise PermissionDeniedException(detail=msg)

        db_obj.magic_link_hashed_token = None
        db_obj.magic_link_sent_at = None

        await self.repository.update(db_obj)

        return db_obj

    async def _check_permissions(
        self, db_obj: m.User | None, password: str, hashed_password: str
    ) -> None:
        if hashed_password is None:
            msg = "User not found or password invalid"
            raise PermissionDeniedException(detail=msg)
        if not await crypt.verify_password(password, hashed_password):
            msg = "User not found or password invalid"
            raise PermissionDeniedException(detail=msg)
        if not db_obj.is_active:
            msg = "User account is inactive"
            raise PermissionDeniedException(detail=msg)

    async def update_password(self, data: dict[str, Any], db_obj: m.User) -> None:
        """Modify stored user password."""
        if db_obj.hashed_password is None:
            msg = "User not found or password invalid"
            raise PermissionDeniedException(detail=msg)
        if not await crypt.verify_password(
            data["current_password"], db_obj.hashed_password
        ):
            msg = "User not found or password invalid"
            raise PermissionDeniedException(detail=msg)
        if not db_obj.is_active:
            msg = "User account is not active"
            raise PermissionDeniedException(detail=msg)
        db_obj.hashed_password = await crypt.get_password_hash(data["new_password"])
        await self.repository.update(db_obj)

    @staticmethod
    async def has_role_id(db_obj: m.User, role_id: UUID) -> bool:
        """Return true if user has specified role ID"""
        return any(
            assigned_role.role_id
            for assigned_role in db_obj.roles
            if assigned_role.role_id == role_id
        )

    @staticmethod
    async def has_role(db_obj: m.User, role_name: str) -> bool:
        """Return true if user has specified role ID"""
        return any(
            assigned_role.role_id
            for assigned_role in db_obj.roles
            if assigned_role.role_name == role_name
        )

    @staticmethod
    def is_superuser(user: m.User) -> bool:
        return bool(
            user.is_superuser
            or any(
                assigned_role.role.name
                for assigned_role in user.roles
                if assigned_role.role.name in {"Superuser"}
            ),
        )

    async def _populate_model(
        self,
        data: ModelDictT[m.User],
        operation: str | None,
    ) -> ModelDictT[m.User]:
        data = schema_dump(data)

        data = await self._populate_with_hashed_magic_link_token(data)

        data = await self._populate_with_role_and_profile_and_token(
            data, operation=operation
        )
        return data

    async def _populate_with_hashed_magic_link_token(
        self, data: ModelDictT[m.User]
    ) -> ModelDictT[m.User]:
        if (
            is_dict(data)
            and (magic_link_token := data.pop("magic_link_token", None)) is not None
        ):
            data["magic_link_hashed_token"] = await crypt.get_password_hash(
                magic_link_token
            )
        return data

    async def _populate_with_role_and_profile_and_token(
        self,
        data: ModelDictT[m.User],
        operation: str | None,
    ) -> ModelDictT[m.User]:
        first_name = data.pop("first_name", None) if is_dict(data) else None
        terms_accepted = data.pop("terms_accepted", None) if is_dict(data) else None
        last_name = data.pop("last_name", None) if is_dict(data) else None
        organization = data.pop("organization", None)
        email_optin = data.pop("email_optin", None) if is_dict(data) else None

        role_id = data.pop("role_id", None) if is_dict(data) else None

        if is_dict(data):
            data = await self.to_model(data)

        if role_id is not None:
            data.roles.append(
                m.UserRole(role_id=role_id, assigned_at=datetime.now(UTC))
            )

        if operation == "create" or operation == "upsert":
            if any(
                [
                    v is not None
                    for v in [
                        first_name,
                        last_name,
                        organization,
                        terms_accepted,
                    ]
                ]
            ):
                data.profile = m.UserProfile(
                    first_name=first_name,
                    last_name=last_name,
                    organization_name=organization.get("name")
                    if is_dict(organization)
                    else organization.name,
                    organization_type=organization.get("type")
                    if is_dict(organization)
                    else organization.type,
                    organization_siren=organization.get("siren")
                    if is_dict(organization)
                    else organization.siren,
                    terms_accepted=terms_accepted,
                    email_optin=email_optin,
                )
        return data


class RoleService(SQLAlchemyAsyncRepositoryService[m.Role]):
    """Handles database operations for users."""

    class Repository(SQLAlchemyAsyncSlugRepository[m.Role]):
        """User SQLAlchemy Repository."""

        model_type = m.Role

    repository_type = Repository
    match_fields = ["name"]

    async def to_model_on_create(self, data: ModelDictT[m.Role]) -> ModelDictT[m.Role]:
        data = schema_dump(data)
        if is_dict_without_field(data, "slug"):
            data["slug"] = await self.repository.get_available_slug(data["name"])
        return data

    async def to_model_on_update(self, data: ModelDictT[m.Role]) -> ModelDictT[m.Role]:
        data = schema_dump(data)
        if is_dict_without_field(data, "slug") and is_dict_with_field(data, "name"):
            data["slug"] = await self.repository.get_available_slug(data["name"])
        return data


class UserRoleService(SQLAlchemyAsyncRepositoryService[m.UserRole]):
    """Handles database operations for user roles."""

    class Repository(SQLAlchemyAsyncRepository[m.UserRole]):
        """User Role SQLAlchemy Repository."""

        model_type = m.UserRole

    repository_type = Repository


class UserProfileService(SQLAlchemyAsyncRepositoryService[m.UserProfile]):
    """Handles database operations for user profiles."""

    class Repository(SQLAlchemyAsyncRepository[m.UserProfile]):
        """User Profile SQLAlchemy Repository."""

        model_type = m.UserProfile

    repository_type = Repository

    def to_schema(
        self,
        data: "Union[ModelOrRowMappingT, Sequence[ModelOrRowMappingT], ModelProtocol, Sequence[ModelProtocol], RowMapping, Sequence[RowMapping]]",
        **kwargs,
    ) -> "Union[ModelOrRowMappingT, OffsetPagination[ModelOrRowMappingT], ModelDTOT, OffsetPagination[ModelDTOT]]":
        # Convert organization to an object for JSON output
        data.organization = Organization(
            name=data.organization_name or msgspec.UNSET,
            type=data.organization_type,
            siren=data.organization_siren or msgspec.UNSET,
        )
        return super().to_schema(data, **kwargs)


class TokenService(SQLAlchemyAsyncRepositoryService[m.Token]):
    """Handles database operations for tokens."""

    class Repository(SQLAlchemyAsyncRepository[m.Token]):
        """Token SQLAlchemy Repository."""

        model_type = m.Token

    repository_type = Repository

    async def find_by_secret(self, secret: str) -> m.Token | None:
        hashed_token = await crypt.get_password_hash(secret)
        return await self.repository.get_one_or_none(hashed_token=hashed_token)

    async def generate_for_user(self, user: m.User, secret: str = str(uuid4())) -> str:
        hashed_token = await crypt.get_password_hash(secret)
        data = m.Token(user_id=user.id, hashed_token=hashed_token)
        added_token = await self.repository.add(data)

        payload = {"email": user.email, "id": str(added_token.id), "secret": secret}

        # Convert the payload to a JSON string
        json_payload = json.dumps(payload)

        # Encode the JSON string to bytes
        bytes_payload = json_payload.encode("utf-8")

        # Encode the bytes
        encoded_payload = base64.urlsafe_b64encode(bytes_payload)
        encoded_string = encoded_payload.decode("utf-8")

        return "eco_api_" + encoded_string

    async def extract_payload(self, token: str) -> dict:
        try:
            decoded_bytes = base64.urlsafe_b64decode(token.replace("eco_api_", ""))
            json_payload = decoded_bytes.decode("utf-8")
            payload = json.loads(json_payload)
        except Exception:
            raise PermissionDeniedException(detail="Error decoding the token")

        return payload

    @cache
    async def authenticate(self, secret: str, token_id: UUID) -> bool:
        token = await self.repository.get_one_or_none(id=token_id)
        if token and await crypt.verify_password(secret, token.hashed_token):
            token.last_accessed_at = datetime.now(timezone.utc)
            await self.repository.update(token)
            return True

        raise PermissionDeniedException(detail="Invalid token")
