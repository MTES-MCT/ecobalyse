from __future__ import annotations

from typing import TYPE_CHECKING, Optional
from uuid import UUID

from advanced_alchemy.base import DefaultBase
from sqlalchemy import ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .element import Element
    from .process import Process


# Based on https://docs.sqlalchemy.org/en/20/orm/basic_relationships.html#association-object
class ProcessElementTransform(DefaultBase):
    __tablename__ = "process_element_transform"

    element_id: Mapped[UUID] = mapped_column(
        ForeignKey("element.id", ondelete="cascade"), primary_key=True
    )

    process_id: Mapped[UUID] = mapped_column(
        ForeignKey("process.id", ondelete="cascade"), primary_key=True
    )

    position: Mapped[Optional[int]]

    transform: Mapped["Process"] = relationship(
        back_populates="elements_transforms",
        lazy="joined",
    )
    element: Mapped["Element"] = relationship(
        back_populates="process_transforms",
        lazy="joined",
    )
