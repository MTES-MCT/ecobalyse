from __future__ import annotations

__all__ = (
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
