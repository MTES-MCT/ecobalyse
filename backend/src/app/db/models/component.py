from __future__ import annotations

from typing import Any

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.types import JsonB
from sqlalchemy import Boolean
from sqlalchemy.orm import Mapped, mapped_column


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Component(UUIDAuditBase):
    __tablename__ = "component"

    value: Mapped[dict[str, Any] | None] = mapped_column(JsonB, nullable=True)

    published: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=False, server_default="f"
    )

    def __repr__(self) -> str:
        return f"Component(id={self.id!r}, published={self.published}, value={self.value!r})"
