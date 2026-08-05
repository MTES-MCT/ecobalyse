from __future__ import annotations

from datetime import date, datetime, timedelta, timezone  # noqa: TC003
from enum import StrEnum
from uuid import UUID  # noqa: TC003

from pydantic import computed_field, model_validator
from stdnum.fr import siren
from typing_extensions import Self

from app.lib.schema import BaseSchema

__all__ = (
    "AccountLogin",
    "User",
    "UserCreate",
    "UserRole",
)


class OrganizationType(StrEnum):
    ASSOCIATION = "association"
    BUSINESS = "business"
    EDUCATION = "education"
    INDIVIDUAL = "individual"
    LOCAL_AUTHORITY = "localAuthority"
    MEDIA = "media"
    PUBLIC = "public"
    STUDENT = "student"


class OrganizationCreate(BaseSchema):
    type: OrganizationType
    name: str | None = None
    siren: str | None = None

    @model_validator(mode="after")
    def check_organization(self) -> Self:
        if self.type != OrganizationType.INDIVIDUAL and self.name is None:
            raise ValueError("You need to provide an organization name")

        if self.type == OrganizationType.BUSINESS and self.siren is None:
            raise ValueError("You need to provide a SIREN number for a business")
        if self.siren is not None:
            try:
                siren.validate(self.siren)
            except Exception:
                raise ValueError("SIREN format is invalid")

            self.siren = siren.compact(self.siren)

        return self


class Organization(BaseSchema):
    name: str | None
    siren: str | None
    type: OrganizationType


class UserRole(BaseSchema):
    """Holds role details for a user.

    This is nested in the User Model for 'roles'
    """

    role_id: UUID
    role_slug: str
    role_name: str
    assigned_at: datetime


class UserProfile(BaseSchema):
    """Holds profile details for a user.

    This is nested in the User Model for 'profile'
    """

    email_optin: bool
    first_name: str | None = None
    last_name: str | None = None
    organization: Organization
    terms_accepted: bool


class User(BaseSchema):
    """User properties to use for a response."""

    id: UUID
    email: str

    @computed_field
    @property
    def has_active_token(self) -> bool:

        now = datetime.now(timezone.utc)
        # We don’t care much about exactitude here, leap years are ignored.
        # An alternative would be to use the dateutil module.
        one_year_ago = now - timedelta(days=365)
        return any(
            t.last_accessed_at is not None and t.last_accessed_at > one_year_ago
            for t in self.tokens
        )

    is_active: bool = False
    is_superuser: bool = False
    is_verified: bool = False
    joined_at: date
    profile: UserProfile
    last_login_at: datetime | None = None
    magic_link_sent_at: datetime | None = None
    roles: list[UserRole] = []
    tokens: list[ApiTokenFromDb] = []


class UserCreate(BaseSchema):
    email: str
    first_name: str
    last_name: str
    organization: OrganizationCreate
    terms_accepted: bool = False
    is_superuser: bool = False
    is_active: bool = True
    is_verified: bool = False


class UserProfileUpdate(BaseSchema):
    email_optin: bool | None = None
    first_name: str | None = None
    last_name: str | None = None
    terms_accepted: bool | None = None


class AccountLogin(BaseSchema):
    email: str


class AccountRegisterMagicLink(BaseSchema):
    email: str
    first_name: str
    last_name: str
    organization: OrganizationCreate
    terms_accepted: bool = False
    email_optin: bool = False
    is_active: bool = True


class ApiToken(BaseSchema):
    """Api token validation"""

    token: str


class ApiTokenFromDb(BaseSchema):
    """Api token DB information"""

    id: UUID
    last_accessed_at: datetime | None = None


class ApiTokenCreate(BaseSchema):
    """Api token creation"""

    hashed_token: str
    user_id: UUID
