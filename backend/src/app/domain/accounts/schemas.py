from __future__ import annotations

from datetime import date, datetime  # noqa: TC003
from enum import StrEnum
from uuid import UUID  # noqa: TC003

import msgspec
from app.lib.schema import CamelizedBaseStruct
from litestar.exceptions import ValidationException
from stdnum.fr import siren

__all__ = (
    "AccountLogin",
    "User",
    "UserCreate",
    "UserRole",
    "UserRoleAdd",
    "UserRoleRevoke",
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


class OrganizationCreate(CamelizedBaseStruct):
    type: OrganizationType
    name: str | None = None
    siren: str | None = None

    def __post_init__(self):
        if self.type != OrganizationType.INDIVIDUAL and self.name is None:
            raise ValidationException("You need to provide an organization name")

        if self.type == OrganizationType.BUSINESS and self.siren is None:
            raise ValidationException(
                "You need to provide a SIREN number for a business"
            )
        if self.siren is not None:
            try:
                siren.validate(self.siren)
            except Exception:
                raise ValidationException("SIREN format is invalid")

            self.siren = siren.compact(self.siren)


class Organization(CamelizedBaseStruct):
    type: OrganizationType
    name: str | None | msgspec.UnsetType = msgspec.UNSET
    siren: str | None | msgspec.UnsetType = msgspec.UNSET


class UserRole(CamelizedBaseStruct):
    """Holds role details for a user.

    This is nested in the User Model for 'roles'
    """

    role_id: UUID
    role_slug: str
    role_name: str
    assigned_at: datetime


class UserProfile(CamelizedBaseStruct):
    """Holds profile details for a user.

    This is nested in the User Model for 'profile'
    """

    organization: Organization
    terms_accepted: bool
    email_optin: bool
    first_name: str | None = None
    last_name: str | None = None


class User(CamelizedBaseStruct):
    """User properties to use for a response."""

    id: UUID
    email: str
    profile: UserProfile
    joined_at: date
    is_superuser: bool = False
    is_active: bool = False
    is_verified: bool = False
    roles: list[UserRole] = []
    magic_link_sent_at: datetime | None = None
    has_active_token: bool = False


class TermsAcceptedUser(CamelizedBaseStruct):
    def __post_init__(self):
        if not self.terms_accepted:
            raise ValidationException("You need to explicitly accept terms")


class UserCreate(TermsAcceptedUser):
    email: str
    first_name: str
    last_name: str
    organization: OrganizationCreate
    terms_accepted: bool = False
    is_superuser: bool = False
    is_active: bool = True
    is_verified: bool = False


class UserProfileUpdate(CamelizedBaseStruct, omit_defaults=True):
    email_optin: bool | None | msgspec.UnsetType = msgspec.UNSET
    first_name: str | None | msgspec.UnsetType = msgspec.UNSET
    last_name: str | None | msgspec.UnsetType = msgspec.UNSET
    terms_accepted: bool | None | msgspec.UnsetType = msgspec.UNSET


class AccountLogin(CamelizedBaseStruct):
    email: str


class AccountRegisterMagicLink(TermsAcceptedUser):
    email: str
    first_name: str
    last_name: str
    organization: OrganizationCreate
    terms_accepted: bool = False
    email_optin: bool = False
    is_active: bool = True


class UserRoleAdd(CamelizedBaseStruct):
    """User role add ."""

    user_name: str


class UserRoleRevoke(CamelizedBaseStruct):
    """User role revoke ."""

    user_name: str


class ApiToken(CamelizedBaseStruct):
    """Api token validation"""

    token: str


class ApiTokenFromDb(CamelizedBaseStruct):
    """Api token DB information"""

    id: UUID
    last_accessed_at: datetime | None = None


class ApiTokenCreate(CamelizedBaseStruct):
    """Api token creation"""

    hashed_token: str
    user_id: UUID
