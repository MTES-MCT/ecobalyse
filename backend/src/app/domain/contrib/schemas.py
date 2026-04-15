from __future__ import annotations

from typing import Any

from app.domain.components.schemas import GenericScope
from app.lib.schema import CamelizedBaseStruct


class ExampleContribCreate(CamelizedBaseStruct):
    description: str
    name: str
    query: dict[str, Any]
    scope: GenericScope


class ExampleContribResponse(CamelizedBaseStruct):
    branch_name: str
    pull_request_url: str
