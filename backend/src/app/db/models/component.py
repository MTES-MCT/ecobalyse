from __future__ import annotations

from typing import Any

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.types import JsonB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .component_scope import component_scope
from .scope import Scope


class ComponentModel(UUIDAuditBase):
    __tablename__ = "component"
    elements: Mapped[dict[str, Any] | None] = mapped_column(JsonB)
    name: Mapped[str]

    # -----------
    # ORM Relationships
    # ------------
    scopes: Mapped[list[Scope]] = relationship(
        secondary=lambda: component_scope,
        cascade="all, delete",
        passive_deletes=True,
        order_by=Scope.value,
    )
