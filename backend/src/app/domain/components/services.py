from __future__ import annotations

from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.service import (
    SQLAlchemyAsyncRepositoryService,
)
from app.db import models as m

__all__ = (
    "ComponentService",
    "ScopeService",
)


class ComponentService(SQLAlchemyAsyncRepositoryService[m.ComponentModel]):
    """Handles database operations for components."""

    class ComponentRepository(SQLAlchemyAsyncRepository[m.ComponentModel]):
        """Component SQLAlchemy Repository."""

        model_type = m.ComponentModel

    repository_type = ComponentRepository

    match_fields = ["name"]


class ScopeService(SQLAlchemyAsyncRepositoryService[m.Scope]):
    """Handles database operations for components."""

    class ScopeRepository(SQLAlchemyAsyncRepository[m.Scope]):
        """Scope SQLAlchemy Repository."""

        model_type = m.Scope

    repository_type = ScopeRepository

    match_fields = ["value"]
