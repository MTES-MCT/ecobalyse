from __future__ import annotations

from typing import TYPE_CHECKING, Any

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.types import JsonB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .component_scope import component_scope

if TYPE_CHECKING:
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
        back_populates="components",
        cascade="all, delete",
        passive_deletes=True,
    )
