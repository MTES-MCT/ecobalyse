from __future__ import annotations

from typing import TYPE_CHECKING, Optional

from advanced_alchemy.base import UUIDAuditBase
from app.domain.components.schemas import Scope
from app.domain.processes.schemas import Category, Unit
from sqlalchemy import Enum, Float, String
from sqlalchemy.dialects import postgresql
from sqlalchemy.ext.mutable import MutableList
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .process_process_category import process_process_category

if TYPE_CHECKING:
    from .process_category import ProcessCategory


def get_enum_values(enum_class):
    return [member.value for member in enum_class]


class Process(UUIDAuditBase):
    __tablename__ = "process"

    categories: Mapped[list[Category]] = mapped_column(
        # See https://docs.sqlalchemy.org/en/20/dialects/postgresql.html#postgresql-data-types
        # For the mutable trick
        MutableList.as_mutable(
            postgresql.ARRAY(
                Enum(Category, values_callable=get_enum_values), dimensions=1
            )
        ),
        default=[],
    )

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

    categories: Mapped[list[ProcessCategory]] = relationship(
        secondary=lambda: process_process_category,
        back_populates="processes",
        cascade="all, delete",
        passive_deletes=True,
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
