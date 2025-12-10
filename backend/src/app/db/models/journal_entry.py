from __future__ import annotations
from sqlalchemy.util.topological import sort

import datetime
import json
from enum import StrEnum
from typing import TYPE_CHECKING, Any
from uuid import UUID

from advanced_alchemy.base import (
    AdvancedDeclarativeBase,
    AsyncAttrs,
    CommonTableAttributes,
    UUIDPrimaryKey,
)
from advanced_alchemy.types import DateTimeUTC, JsonB
from sqlalchemy import Enum, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .user import User


class JournalAction(StrEnum):
    CREATED = "created"
    UPDATED = "updated"
    DELETED = "deleted"


# Don’t add updated_at automatically with UUIDAuditBase but keep created_at
class JournalEntry(
    CommonTableAttributes, UUIDPrimaryKey, AdvancedDeclarativeBase, AsyncAttrs
):
    __tablename__ = "journal_entry"

    created_at: Mapped[datetime.datetime] = mapped_column(
        DateTimeUTC(timezone=True),
        default=lambda: datetime.datetime.now(datetime.timezone.utc),
    )

    table_name: Mapped[str] = mapped_column(nullable=False)

    record_id: Mapped[UUID] = mapped_column(nullable=False)
    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("user_account.id", ondelete="cascade"), nullable=False
    )

    action: Mapped[JournalAction] = mapped_column(Enum(JournalAction), nullable=False)

    value: Mapped[dict[str, Any] | None] = mapped_column(JsonB, nullable=True)

    # -----------
    # ORM Relationships
    # ------------
    user: Mapped[User] = relationship(
        back_populates="journal_entries", innerjoin=True, lazy="joined"
    )

    @property
    def value_str(self) -> str | None:
        if self.value is not None:
            # Used for json/msgspec serialization
            return json.dumps(self.value, ensure_ascii=False, indent=2, sort_keys=True)
        return self.value
