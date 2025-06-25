from __future__ import annotations

from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.service import (
    SQLAlchemyAsyncRepositoryService,
)
from app.db import models as m

__all__ = ("JournalEntryService",)


class JournalEntryService(SQLAlchemyAsyncRepositoryService[m.JournalEntry]):
    """Handles database operations for journal entries."""

    class JournalEntryRepository(SQLAlchemyAsyncRepository[m.JournalEntry]):
        """Journal entry SQLAlchemy Repository."""

        model_type = m.JournalEntry

    repository_type = JournalEntryRepository
