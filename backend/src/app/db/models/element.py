from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.base import UUIDAuditBase
from sqlalchemy import Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .process_element_transform import process_element_transform

if TYPE_CHECKING:
    from .process import Process


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Element(UUIDAuditBase):
    __tablename__ = "element"
    amount: Mapped[float] = mapped_column(Float, nullable=False, default=0)

    material_id: Mapped[UUID] = mapped_column(
        ForeignKey("process.id", ondelete="cascade"), nullable=False
    )

    # -----------
    # ORM Relationships
    # ------------

    material: Mapped[Process] = relationship(
        back_populates="elements_materials", innerjoin=True, lazy="joined"
    )
    process_transforms: Mapped[list[Process]] = relationship(
        secondary=lambda: process_element_transform,
        back_populates="elements_transforms",
        cascade="all, delete",
        passive_deletes=True,
    )
