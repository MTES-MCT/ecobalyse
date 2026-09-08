from __future__ import annotations

from typing import Any

from app.domain.components.schemas import GenericScope
from app.lib.schema import BaseSchema


class ExampleContribCreate(BaseSchema):
    description: str
    name: str
    query: dict[str, Any]
    scope: GenericScope


class ExampleContribResponse(BaseSchema):
    branch_name: str
    pull_request_url: str
