from __future__ import annotations

from enum import StrEnum
from typing import Any

from app.lib.schema import CamelizedBaseStruct


class GenericScope(StrEnum):
    FOOD2 = "food2"
    OBJECT = "object"
    VELI = "veli"


class GenericContributionCreate(CamelizedBaseStruct):
    description: str
    name: str
    query: dict[str, Any]
    scope: GenericScope


class GenericContributionResponse(CamelizedBaseStruct):
    branch_name: str
    pull_request_url: str
