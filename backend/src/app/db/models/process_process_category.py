from __future__ import annotations

from advanced_alchemy.base import orm_registry
from sqlalchemy import Column, ForeignKey, Table

process_process_category = Table(
    "process_process_category",
    orm_registry.metadata,
    Column(
        "process_id", ForeignKey("process.id", ondelete="CASCADE"), primary_key=True
    ),
    Column(
        "process_category_id",
        ForeignKey("process_category.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)
