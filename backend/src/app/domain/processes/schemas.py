from __future__ import annotations

from uuid import UUID  # noqa: TC003

from app.lib.schema import CamelizedBaseStruct

__all__ = (
    "Process",
    "Unit",
)

from enum import StrEnum


class Process(CamelizedBaseStruct):
    """Component properties to use for a response."""

    id: UUID
    display_name: str
    unit: Unit


class Unit(StrEnum):
    ITEM = "Item(s)"
    KG = "kg"
    KWH = "kWh"
    L = "L"
    M2 = "m2"
    M3 = "m3"
    MJ = "MJ"
    T_KM = "t⋅km"
