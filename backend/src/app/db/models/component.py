from __future__ import annotations

from typing import Any

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.types import JsonB
from sqlalchemy.orm import Mapped, mapped_column


class ComponentModel(UUIDAuditBase):
    __tablename__ = "component"
    elements: Mapped[dict[str, Any] | None] = mapped_column(JsonB)
    name: Mapped[str]
