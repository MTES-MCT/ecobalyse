from __future__ import annotations

from typing import Optional

from advanced_alchemy.base import UUIDAuditBase
from sqlalchemy.orm import Mapped


class ProcessModel(UUIDAuditBase):
    __tablename__ = "process"
    display: Mapped[Optional[str]]
    name: Mapped[str]
