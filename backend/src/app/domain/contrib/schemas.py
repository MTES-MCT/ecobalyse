from __future__ import annotations

from enum import StrEnum
from typing import Any

from app.lib.schema import BaseSchema


class GenericScope(StrEnum):
    "All generic scopes."

    FOOD2 = "food2"
    OBJECT = "object"
    VELI = "veli"


class ExampleContribCreate(BaseSchema):
    description: str
    name: str
    query: dict[str, Any]
    scope: GenericScope


class ExampleContribResponse(BaseSchema):
    branch_name: str
    pull_request_url: str
