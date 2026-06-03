from __future__ import annotations

from uuid import UUID  # noqa: TC003

import msgspec
from app.lib.schema import CamelizedBaseStruct

__all__ = (
    "Component",
    "ComponentCreate",
    "ComponentUpdate",
    "GenericScope",
    "Scope",
)

from enum import StrEnum


class GenericScope(StrEnum):
    "All generic scopes."

    FOOD2 = "food2"
    OBJECT = "object"
    VELI = "veli"


class Scope(StrEnum):
    "All scopes, merging generic and legacy ones. Note: StrEnum isn't inheritable."

    FOOD = "food"
    FOOD2 = GenericScope.FOOD2.value
    OBJECT = GenericScope.OBJECT.value
    TEXTILE = "textile"
    VELI = GenericScope.VELI.value


class Component(CamelizedBaseStruct):
    """Component properties to use for a response."""

    id: UUID
    published: bool
    value: dict


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


class JsonComponent(CamelizedBaseStruct):
    """Component properties to use for a JSON dump."""

    id: UUID
    name: str
    elements: list[ComponentElement] | None
    comment: str | None
    scopes: list[Scope] = []
