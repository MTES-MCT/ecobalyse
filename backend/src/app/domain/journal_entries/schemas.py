from __future__ import annotations

from datetime import datetime  # noqa: TC003
from uuid import UUID  # noqa: TC003

from pydantic import Field

from app.domain.accounts.schemas import User
from app.lib.schema import BaseSchema

__all__ = "JournalEntry"


class JournalEntry(BaseSchema):
    """Journal entry properties."""

    id: UUID
    action: str
    table_name: str
    record_id: UUID
    user: User
    # We want to serialize the value as a string rather than an object
    # so that the frontend doesn’t have to validate it.
    value_str: str | None = Field(alias="value")

    created_at: datetime | None = None
