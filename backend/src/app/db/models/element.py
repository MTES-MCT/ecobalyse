from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.base import UUIDAuditBase
from sqlalchemy import Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .process_element_transform import process_element_transform

if TYPE_CHECKING:
    from .process import Component, Process


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Element(UUIDAuditBase):
    __tablename__ = "element"
    amount: Mapped[float] = mapped_column(Float, nullable=False, default=0)

    material_id: Mapped[UUID] = mapped_column(
        ForeignKey("process.id", ondelete="cascade"), nullable=False
    )

    component_id: Mapped[UUID] = mapped_column(
        ForeignKey("component.id", ondelete="cascade"), nullable=False
    )

    # -----------
    # ORM Relationships
    # ------------

    component: Mapped[Component] = relationship(
        back_populates="elements", innerjoin=True, lazy="joined"
    )

    material_process: Mapped[Process] = relationship(
        back_populates="elements_materials", innerjoin=True, lazy="joined"
    )
    process_transforms: Mapped[list[Process]] = relationship(
        secondary=lambda: process_element_transform,
        back_populates="elements_transforms",
    )

    @property
    def material(self) -> UUID:
        return self.material_id

    @property
    def transforms(self) -> list[UUID]:
        transforms = [transform.id for transform in self.process_transforms]

        return transforms

    def __repr__(self) -> str:
        return f"Element(id={self.id!r}, amount={self.amount!r}, material_id={self.material_id!r}, component_id={self.component_id!r}, transforms={self.transforms!r})"
