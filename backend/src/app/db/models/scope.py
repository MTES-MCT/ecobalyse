from __future__ import annotations

from collections.abc import Hashable

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.mixins import UniqueMixin
from sqlalchemy import ColumnElement, Table
from sqlalchemy.orm import Mapped, mapped_column


class Scope(UUIDAuditBase, UniqueMixin):
    __tablename__ = "scope"
    value: Mapped[str] = mapped_column(unique=True, index=True, nullable=False)

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
