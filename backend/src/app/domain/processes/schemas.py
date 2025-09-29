from __future__ import annotations

from typing import Optional
from uuid import UUID  # noqa: TC003

import msgspec
from app.lib.schema import CamelizedBaseStruct

__all__ = (
    "Process",
    "Unit",
)

from enum import StrEnum

from app.domain.components.schemas import Scope


class Category(StrEnum):
    ENERGY = "energy"
    EOL = "end-of-life"
    INGREDIENT = "ingredient"
    MATERIAL = "material"
    MATERIAL_TYPE_METAL = "material_type:metal"
    MATERIAL_TYPE_ORGANIC_FIBERS = "material_type:organic_fibers"
    MATERIAL_TYPE_OTHER = "material_type:other"
    MATERIAL_TYPE_SYNTHETIC_FIBERS = "material_type:synthetic_fibers"
    MATERIAL_TYPE_PLASTIC = "material_type:plastic"
    MATERIAL_TYPE_UPHOLSTERY = "material_type:upholstery"
    MATERIAL_TYPE_WOOD = "material_type:wood"
    PACKAGING = "packaging"
    TEXTILE_MATERIAL = "textile_material"
    TRANSFORMATION = "transformation"
    TRANSPORT = "transport"
    USE = "use"


class Impacts(CamelizedBaseStruct):
    acd: float = 0
    cch: float = 0
    etf: float = 0
    etf_c: float = msgspec.field(name="etf-c", default=0)
    fru: float = 0
    fwe: float = 0
    htc: float = 0
    htc_c: float = msgspec.field(name="htc-c", default=0)
    htn: float = 0
    htn_c: float = msgspec.field(name="htn-c", default=0)
    ior: float = 0
    ldu: float = 0
    mru: float = 0
    ozd: float = 0
    pco: float = 0
    pma: float = 0
    swe: float = 0
    tre: float = 0
    wtu: float = 0
    ecs: float = 0
    pef: float = 0


class Process(CamelizedBaseStruct):
    """Component properties to use for a response."""

    categories: list[Category]
    comment: str
    display_name: Optional[str]
    id: UUID
    impacts: Impacts
    source: str
    source_id: Optional[str]
    unit: Unit

    # Optional fields
    alias: Optional[str] = None
    density: float = 0
    elec_mj: float = msgspec.field(name="elecMJ", default=0)
    heat_mj: float = msgspec.field(name="heatMJ", default=0)
    scopes: list[Scope] = []
    waste: float = 0


class Unit(StrEnum):
    ITEM = "Item(s)"
    KG = "kg"
    KWH = "kWh"
    L = "L"
    M2 = "m2"
    M3 = "m3"
    MJ = "MJ"
    T_KM = "t⋅km"
