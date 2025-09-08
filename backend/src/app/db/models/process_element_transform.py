from __future__ import annotations

from advanced_alchemy.base import orm_registry
from sqlalchemy import Column, ForeignKey, Table

process_element_transform = Table(
    "process_element_transform",
    orm_registry.metadata,
    Column(
        "process_id", ForeignKey("process.id", ondelete="CASCADE"), primary_key=True
    ),
    Column(
        "element_id",
        ForeignKey("element.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)
