from __future__ import annotations

import datetime
from typing import TYPE_CHECKING

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.types import DateTimeUTC
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship, validates

if TYPE_CHECKING:
    from .journal_entry import JournalEntry
    from .token import Token
    from .user_profile import UserProfile
    from .user_role import UserRole


class User(UUIDAuditBase):
    __tablename__ = "user_account"
    __table_args__ = {"comment": "User accounts for application access"}
    __pii_columns__ = {"email"}

    email: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)
    magic_link_hashed_token: Mapped[str | None] = mapped_column(
        String(length=255), nullable=True, default=None
    )
    magic_link_sent_at: Mapped[datetime.datetime] = mapped_column(
        DateTimeUTC(timezone=True), default=None, nullable=True
    )

    @validates("magic_link_sent_at")
    def validate_tz_info(self, _: str, value: datetime.datetime) -> datetime.datetime:
        if value and value.tzinfo is None:
            value = value.replace(tzinfo=datetime.timezone.utc)
        return value

    is_active: Mapped[bool] = mapped_column(default=False, nullable=False)
    is_superuser: Mapped[bool] = mapped_column(default=False, nullable=False)
    is_verified: Mapped[bool] = mapped_column(default=False, nullable=False)
    verified_at: Mapped[datetime.date] = mapped_column(nullable=True, default=None)
    joined_at: Mapped[datetime.date] = mapped_column(default=datetime.datetime.now)

    # -----------
    # ORM Relationships
    # ------------
    journal_entries: Mapped[list[JournalEntry]] = relationship(
        back_populates="user",
        lazy="selectin",
        cascade="all, delete",
    )
    roles: Mapped[list[UserRole]] = relationship(
        back_populates="user",
        lazy="selectin",
        cascade="all, delete",
    )

    profile: Mapped[UserProfile] = relationship(
        back_populates="user", cascade="all, delete"
    )

    tokens: Mapped[list[Token]] = relationship(
        back_populates="user",
        lazy="selectin",
        cascade="all, delete",
    )

    @property
    def has_active_token(self) -> bool:
        now = datetime.datetime.now(datetime.timezone.utc)
        # We don’t care much about exactitude here, leap years are ignored.
        # An alternative would be to use the dateutil module.
        one_year_ago = now - datetime.timedelta(days=365)
        return any(t.last_accessed_at > one_year_ago for t in self.tokens)
