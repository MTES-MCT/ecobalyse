from __future__ import annotations

from advanced_alchemy.base import orm_registry
from sqlalchemy import Column, ForeignKey, Table

component_scope = Table(
    "component_scope",
    orm_registry.metadata,
    Column(
        "component_id", ForeignKey("component.id", ondelete="CASCADE"), primary_key=True
    ),
    Column("scope_id", ForeignKey("scope.id", ondelete="CASCADE"), primary_key=True),
)
