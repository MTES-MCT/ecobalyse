from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID  # noqa: TC003

from advanced_alchemy.base import UUIDAuditBase
from sqlalchemy import ForeignKey
from sqlalchemy.ext.associationproxy import AssociationProxy, association_proxy
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .user import User


class UserProfile(UUIDAuditBase):
    """User Role."""

    __tablename__ = "user_account_profile"
    __table_args__ = {"comment": "Profile details for a specific user."}
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
    def organization(self):
        return {
            "name": self.organization_name,
            "type": self.organization_type,
            "siren": self.organization_siren,
        }
