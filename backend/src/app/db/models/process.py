from __future__ import annotations

from typing import TYPE_CHECKING, Optional

from advanced_alchemy.base import UUIDAuditBase
from app.domain.components.schemas import Scope
from app.domain.processes.schemas import Unit
from sqlalchemy import Enum, Float, String, Table
from sqlalchemy.dialects import postgresql
from sqlalchemy.ext.mutable import MutableList
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .process_process_category import process_process_category

if TYPE_CHECKING:
    from .element import Element
    from .process_category import ProcessCategory


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Process(UUIDAuditBase):
    __tablename__ = "process"

    comment: Mapped[str]
    density: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    display_name: Mapped[Optional[str]]
    elec_mj: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    heat_mj: Mapped[float] = mapped_column(Float, nullable=False, default=0)

    scopes: Mapped[list[Scope]] = mapped_column(
        # See https://docs.sqlalchemy.org/en/20/dialects/postgresql.html#postgresql-data-types
        # For the mutable trick
        MutableList.as_mutable(
            postgresql.ARRAY(Enum(Scope, values_callable=get_enum_values), dimensions=1)
        ),
        default=[],
    )
    source: Mapped[str]
    source_id: Mapped[str] = mapped_column(String, nullable=False)

    unit: Mapped[Unit] = mapped_column(Enum(Unit, values_callable=get_enum_values))
    waste: Mapped[float] = mapped_column(Float, nullable=False, default=0)

    # -----------
    # ORM Relationships
    # ------------
    process_categories: Mapped[list[ProcessCategory]] = relationship(
        secondary=lambda: process_process_category,
        back_populates="processes",
    )

    elements_transforms: Mapped[list[Element]] = relationship(
        secondary=lambda: _process_element_transforms(),
        back_populates="process_transforms",
        cascade="all",
    )

    elements_materials: Mapped[list[Element]] = relationship(
        back_populates="material_process",
        lazy="selectin",
        cascade="all, delete-orphan",
    )

    # Impacts
    acd: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    cch: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    etf: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    etf_c: Mapped[float] = mapped_column(Float, nullable=False, name="etf-c", default=0)
    fru: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    fwe: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    htc: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    htc_c: Mapped[float] = mapped_column(Float, nullable=False, name="htc-c", default=0)
    htn: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    htn_c: Mapped[float] = mapped_column(Float, nullable=False, name="htn-c", default=0)
    ior: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    ldu: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    mru: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    ozd: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    pco: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    pma: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    swe: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    tre: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    wtu: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    ecs: Mapped[float] = mapped_column(Float, nullable=False, default=0)
    pef: Mapped[float] = mapped_column(Float, nullable=False, default=0)

    @property
    def categories(self) -> list[str]:
        categories = []
        for c in self.process_categories:
            categories.append(c.name)

        return categories

    @property
    def impacts(self) -> dict[str, float]:
        impacts = {
            "acd": self.acd,
            "cch": self.cch,
            "ecs": self.ecs,
            "etf": self.etf,
            "etf-c": self.etf_c,
            "fru": self.fru,
            "fwe": self.fwe,
            "htc": self.htc,
            "htc-c": self.htc_c,
            "htn": self.htn,
            "htn-c": self.htn_c,
            "ior": self.ior,
            "ldu": self.ldu,
            "mru": self.mru,
            "ozd": self.ozd,
            "pco": self.pco,
            "pef": self.pef,
            "pma": self.pma,
            "swe": self.swe,
            "tre": self.tre,
            "wtu": self.wtu,
        }
        return impacts

    def __repr__(self) -> str:
        return f"Process(id={self.id!r}, display_name={self.display_name!r}, comment={self.comment!r}, scopes={self.scopes!r}, caterories={self.process_categories!r})"


def _process_element_transforms() -> Table:
    from .process_element_transform import process_element_transform

    return process_element_transform
