from __future__ import annotations

import json
from datetime import datetime  # noqa: TC003
from typing import Annotated
from uuid import UUID  # noqa: TC003

from app.config.base import UUIDEncoder
from app.domain.accounts.schemas import User
from app.lib.schema import BaseSchema

__all__ = "JournalEntry"

from pydantic import PlainSerializer


def value_as_str(value: dict) -> str:
    return json.dumps(value, cls=UUIDEncoder, indent=2, sort_keys=True)


class JournalEntry(BaseSchema):
    """Journal entry properties."""

    id: UUID
    action: str
    table_name: str
    record_id: UUID
    user: User
    # We want to serialize the value as a string rather than an object
    # so that the frontend doesn’t have to validate it.
    value: Annotated[dict | None, PlainSerializer(value_as_str)]
    created_at: datetime | None = None
