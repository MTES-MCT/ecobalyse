from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.base import UUIDAuditBase
from sqlalchemy import Float, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

if TYPE_CHECKING:
    from .component import Component
    from .process import Process
from .process_element_transform import ProcessElementTransform


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Element(UUIDAuditBase):
    __tablename__ = "element"
    amount: Mapped[float] = mapped_column(Float, nullable=False, default=0)

    material_process_id: Mapped[UUID] = mapped_column(
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

    process_transforms: Mapped[list[ProcessElementTransform]] = relationship(
        order_by="ProcessElementTransform.position",
        back_populates="element",
        lazy="joined",
        cascade="all",
    )

    @property
    def material(self) -> UUID:
        # Used for json/msgspec serialization
        return self.material_process_id

    @property
    def transforms(self) -> list[UUID]:
        transforms = [
            process_element_transform.transform.id
            for process_element_transform in self.process_transforms
        ]
        return transforms

    def __repr__(self) -> str:
        return f"Element(id={self.id!r}, amount={self.amount!r}, material_process_id={self.material_process_id!r}, component_id={self.component_id!r}, transforms={[str(t) for t in self.transforms]})"
