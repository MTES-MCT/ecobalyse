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
    DISTRIBUTION = "distribution"
    ENERGY = "energy"
    EOL = "end-of-life"
    INGREDIENT = "ingredient"
    MATERIAL = "material"

    MATERIAL_TYPE_ALUMINIUM = "material_type:aluminium"
    MATERIAL_TYPE_BATTERY_CELL = "material_type:battery_cell"
    MATERIAL_TYPE_COMPOSITES = "material_type:composites"
    MATERIAL_TYPE_CONTAINERBOARD = "material_type:containerboard"
    MATERIAL_TYPE_COPPER = "material_type:copper"
    MATERIAL_TYPE_FERROUS_METAL = "material_type:ferrous_metals"
    MATERIAL_TYPE_GLASS = "material_type:glass"
    MATERIAL_TYPE_HDPE = "material_type:hdpe"
    MATERIAL_TYPE_LDPE = "material_type:ldpe"
    MATERIAL_TYPE_ORGANIC_FIBERS = "material_type:organic_fibers"
    MATERIAL_TYPE_PET = "material_type:pet"
    MATERIAL_TYPE_PP = "material_type:pp"
    MATERIAL_TYPE_PUR_FOAM = "material_type:pur_foam"
    MATERIAL_TYPE_PWB = "material_type:pwb"
    MATERIAL_TYPE_RIGID_PLASTICS = "material_type:rigid_plastics"
    MATERIAL_TYPE_RUBBER = "material_type:rubber"
    MATERIAL_TYPE_SYNTHETIC_FIBERS = "material_type:synthetic_fibers"
    MATERIAL_TYPE_WOOD = "material_type:wood"
    MATERIAL_TYPE_OTHER = "material_type:other"

    # Food types
    MATERIAL_TYPE_EGGS = "material_type:eggs"
    MATERIAL_TYPE_FISH_AND_SHELLFISH = "material_type:fish_and_shellfish"
    MATERIAL_TYPE_FRUITS_AND_VEGETABLES = "material_type:fruits_and_vegetables"
    MATERIAL_TYPE_OFFAL = "material_type:offal"
    MATERIAL_TYPE_OTHER_FOOD_ITEMS = "material_type:other_food_items"
    MATERIAL_TYPE_POULTRY = "material_type:poultry"
    MATERIAL_TYPE_RED_MEATS = "material_type:red_meats"

    PACKAGING = "packaging"
    PACKAGING_TYPE_BAG = "packaging_type:bag"
    PACKAGING_TYPE_BOTTLE = "packaging_type:bottle"
    PACKAGING_TYPE_BOX = "packaging_type:box"
    PACKAGING_TYPE_CASE = "packaging_type:case"
    PACKAGING_TYPE_FLASK = "packaging_type:flask"
    PACKAGING_TYPE_JAR = "packaging_type:jar"
    PACKAGING_TYPE_OTHER = "packaging_type:other"
    PACKAGING_TYPE_PACK = "packaging_type:pack"
    PACKAGING_TYPE_SHEET = "packaging_type:sheet"
    PACKAGING_TYPE_TRAY = "packaging_type:tray"
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


class Process(CamelizedBaseStruct):
    """Component properties to use for a response."""

    categories: list[Category]
    comment: str
    id: UUID
    impacts: Impacts
    source: str
    unit: Unit

    # Optional fields

    activity_name: Optional[str] = None
    alias: Optional[str] = None
    mass_per_unit: Optional[float] = msgspec.field(name="massPerUnit", default=None)
    display_name: Optional[str] = None
    elec_mj: float = msgspec.field(name="elecMJ", default=0)
    heat_mj: float = msgspec.field(name="heatMJ", default=0)
    location: Optional[str] = None
    scopes: list[Scope] = []
    waste: float = 0


class Unit(StrEnum):
    ITEM = "item"
    KG = "kg"
    KWH = "kWh"
    L = "L"
    M2 = "m2"
    M3 = "m3"
    MJ = "MJ"
    T_KM = "t⋅km"
