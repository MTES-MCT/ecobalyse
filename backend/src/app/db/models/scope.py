from __future__ import annotations

from collections.abc import Hashable
from typing import TYPE_CHECKING

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.mixins import UniqueMixin
from sqlalchemy import ColumnElement, Table
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .component import ComponentModel


class Scope(UUIDAuditBase, UniqueMixin):
    __tablename__ = "scope"
    value: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)

    # -----------
    # ORM Relationships
    # ------------
    components: Mapped[list[ComponentModel]] = relationship(
        secondary=lambda: _component_scope(),
        back_populates="scopes",
    )

    @classmethod
    def unique_hash(cls, value: str) -> Hashable:
        return value

    @classmethod
    def unique_filter(
        cls,
        value: str,
    ) -> ColumnElement[bool]:
        return cls.value == value


def _component_scope() -> Table:
    from .component_scope import component_scope

    return component_scope
