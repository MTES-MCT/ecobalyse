from __future__ import annotations

from uuid import UUID  # noqa: TC003

import msgspec
from app.lib.schema import CamelizedBaseStruct

__all__ = (
    "Component",
    "ComponentCreate",
    "ComponentUpdate",
    "Scope",
)

from enum import StrEnum


class Scope(StrEnum):
    FOOD = "food"
    OBJECT = "object"
    TEXTILE = "textile"
    VELI = "veli"


class Component(CamelizedBaseStruct):
    """Component properties to use for a response."""

    id: UUID
    name: str
    elements: list[ComponentElement] | None
    comment: str | None
    published: bool
    scopes: list[Scope] = []


class ComponentCreate(CamelizedBaseStruct):
    name: str
    elements: list[ComponentElement]
    comment: str | None = None
    published: bool = False
    scopes: list[Scope] = []


class ComponentElement(
    CamelizedBaseStruct, omit_defaults=True, repr_omit_defaults=True
):
    amount: float | None | msgspec.UnsetType = msgspec.UNSET
    material: UUID | None | msgspec.UnsetType = msgspec.UNSET

    transforms: list[UUID] | None | msgspec.UnsetType = msgspec.UNSET


class ComponentUpdate(CamelizedBaseStruct, omit_defaults=True):
    comment: str | None | msgspec.UnsetType = msgspec.UNSET
    id: UUID | None | msgspec.UnsetType = msgspec.UNSET
    elements: list[ComponentElement] | None | msgspec.UnsetType = msgspec.UNSET
    name: str | None | msgspec.UnsetType = msgspec.UNSET
    published: bool | None | msgspec.UnsetType = msgspec.UNSET
    scopes: list[Scope] = []
