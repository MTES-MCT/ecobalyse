from __future__ import annotations

from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.service import (
    SQLAlchemyAsyncRepositoryService,
)
from app.db import models as m

__all__ = ("ProcessService",)


class ProcessService(SQLAlchemyAsyncRepositoryService[m.Process]):
    """Handles database operations for processes."""

    class ProcessRepository(SQLAlchemyAsyncRepository[m.Process]):
        """Process SQLAlchemy Repository."""

        model_type = m.Process

    repository_type = ProcessRepository

    match_fields = ["name"]
