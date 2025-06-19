from __future__ import annotations

from datetime import datetime  # noqa: TC003
from uuid import UUID  # noqa: TC003

from app.domain.accounts.schemas import User
from app.lib.schema import CamelizedBaseStruct

__all__ = "DbJournalEntry"


class JournalEntry(CamelizedBaseStruct):
    """Journal entry properties."""

    id: UUID
    action: str
    table_name: str
    record_id: UUID
    user: User
    value: dict | None

    created_at: datetime | None = None
    updated_at: datetime | None = None
