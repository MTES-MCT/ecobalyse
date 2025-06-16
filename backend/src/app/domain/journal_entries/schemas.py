from __future__ import annotations

from uuid import UUID  # noqa: TC003

from app.lib.schema import CamelizedBaseStruct

__all__ = "DbJournalEntry"


class DbJournalEntry(CamelizedBaseStruct):
    """Journal entry properties."""

    id: UUID
    action: str
    table_name: str
    record_id: UUID
    value: dict | None
