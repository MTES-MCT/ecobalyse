from __future__ import annotations

from typing import TYPE_CHECKING

from advanced_alchemy.base import UUIDAuditBase
from sqlalchemy import Table
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .component import ComponentModel


class Scope(UUIDAuditBase):
    __tablename__ = "scope"
    value: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)

    # -----------
    # ORM Relationships
    # ------------
    components: Mapped[list[ComponentModel]] = relationship(
        secondary=lambda: _component_scope(),
        back_populates="scopes",
    )


def _component_scope() -> Table:
    from .component_scope import component_scope

    return component_scope
