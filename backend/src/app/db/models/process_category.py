from __future__ import annotations

from typing import TYPE_CHECKING

from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.mixins import UniqueMixin
from sqlalchemy import (
    ColumnElement,
    Table,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from collections.abc import Hashable

    from .process import Process


class ProcessCategory(UUIDAuditBase, UniqueMixin):
    """Tag."""

    __tablename__ = "process_category"
    name: Mapped[str] = mapped_column(index=False)

    # -----------
    # ORM Relationships
    # ------------
    processes: Mapped[list[Process]] = relationship(
        secondary=lambda: _process_process_category(),
        back_populates="process_categories",
    )

    @classmethod
    def unique_hash(cls, name: str, slug: str | None = None) -> Hashable:  # noqa: ARG003
        return name

    @classmethod
    def unique_filter(
        cls,
        name: str,
        slug: str | None = None,  # noqa: ARG003
    ) -> ColumnElement[bool]:
        return cls.name == name


def _process_process_category() -> Table:
    from .process_process_category import process_process_category

    return process_process_category
