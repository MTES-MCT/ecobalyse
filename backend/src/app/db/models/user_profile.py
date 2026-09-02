from __future__ import annotations

from typing import TYPE_CHECKING, ClassVar
from uuid import UUID

from advanced_alchemy.base import UUIDAuditBase
from sqlalchemy import ForeignKey
from sqlalchemy.ext.associationproxy import AssociationProxy, association_proxy
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .user import User


class UserProfile(UUIDAuditBase):
    """User Role."""

    __tablename__ = "user_account_profile"
    __table_args__: ClassVar[dict] = {"comment": "Profile details for a specific user."}  # ty: ignore[invalid-attribute-override]
    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("user_account.id", ondelete="cascade"), nullable=False
    )

    first_name: Mapped[str | None] = mapped_column(nullable=True, default=None)
    last_name: Mapped[str | None] = mapped_column(nullable=True, default=None)
    organization_type: Mapped[str] = mapped_column(nullable=False)
    organization_name: Mapped[str | None] = mapped_column(nullable=True, default=None)
    organization_siren: Mapped[str | None] = mapped_column(nullable=True, default=None)
    terms_accepted: Mapped[bool] = mapped_column(default=False, nullable=False)
    email_optin: Mapped[bool] = mapped_column(default=False, nullable=False)

    # -----------
    # ORM Relationships
    # ------------
    user: Mapped[User] = relationship(
        back_populates="profile", innerjoin=True, lazy="joined"
    )
    user_email: AssociationProxy[str] = association_proxy("user", "email")

    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}".strip()

    @property
    def organization(self):
        return {
            "name": self.organization_name,
            "type": self.organization_type,
            "siren": self.organization_siren,
        }

    @property
    def organization_info(self) -> str:
        org_name = self.organization_name.strip() if self.organization_name else None
        return org_name if org_name else "Non renseignée"

    def __repr__(self) -> str:
        return f"UserProfile(id={self.id!r}, first_name={self.first_name!r}, last_name={self.last_name!r}, user_email={self.last_name!r})"
