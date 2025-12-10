from __future__ import annotations

import datetime
from typing import TYPE_CHECKING
from uuid import UUID  # noqa: TC003

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.types import DateTimeUTC
from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship, validates

if TYPE_CHECKING:
    from .user import User


class Token(UUIDAuditBase):
    __tablename__ = "token"
    __table_args__ = {"comment": "Tokens for API access"}

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("user_account.id", ondelete="cascade"), nullable=False
    )

    hashed_token: Mapped[str | None] = mapped_column(
        String(length=255), nullable=True, default=None
    )

    last_accessed_at: Mapped[datetime.datetime] = mapped_column(
        DateTimeUTC(timezone=True), default=None, nullable=True
    )

    @validates("last_accessed_at")
    def validate_tz_info(self, _: str, value: datetime.datetime) -> datetime.datetime:
        if value and value.tzinfo is None:
            value = value.replace(tzinfo=datetime.timezone.utc)
        return value

    # -----------
    # ORM Relationships
    # ------------
    user: Mapped[User] = relationship(
        back_populates="tokens", innerjoin=True, lazy="selectin"
    )
