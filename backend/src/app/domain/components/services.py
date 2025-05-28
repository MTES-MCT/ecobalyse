from __future__ import annotations

from typing import TYPE_CHECKING

from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.service import (
    SQLAlchemyAsyncRepositoryService,
)

from app.db import models as m

if TYPE_CHECKING:
    pass

__all__ = ("ComponentService",)


class ComponentService(SQLAlchemyAsyncRepositoryService[m.ComponentModel]):
    """Handles database operations for components."""

    class ComponentRepository(SQLAlchemyAsyncRepository[m.ComponentModel]):
        """Component SQLAlchemy Repository."""

        model_type = m.ComponentModel

    repository_type = ComponentRepository

    match_fields = ["name"]
