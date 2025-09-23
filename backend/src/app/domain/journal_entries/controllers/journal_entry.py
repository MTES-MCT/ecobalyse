from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.filters import OrderBy
from advanced_alchemy.service.typing import (
    convert,
)
from app.domain.accounts.guards import requires_superuser
from app.domain.journal_entries import urls
from app.domain.journal_entries.deps import provide_journal_entries_service
from app.domain.journal_entries.schemas import JournalEntry
from litestar import get
from litestar.controller import Controller
from litestar.di import Provide
from litestar.params import Parameter

if TYPE_CHECKING:
    from app.domain.journal_entries.services import JournalEntryService


class JournalEntryController(Controller):
    """JournalEntry CRUD"""

    dependencies = {
        "journal_entries_service": Provide(provide_journal_entries_service),
    }

    tags = ["Journal entries"]

    @get(
        operation_id="ListJournalEntries",
        path=urls.JOURNAL_ENTRIES_LIST,
        guards=[requires_superuser],
    )
    async def list_journal_entries(
        self,
        journal_entries_service: JournalEntryService,
    ) -> list[JournalEntry]:
        """List all journal entries."""
        results = await journal_entries_service.list(
            OrderBy(field_name="created_at", sort_order="desc"),
        )

        return convert(
            obj=results,
            type=list[JournalEntry],  # type: ignore[valid-type]
            from_attributes=True,
        )

    @get(
        operation_id="ListJournalEntriesPerTable",
        path=urls.JOURNAL_ENTRIES_TABLE_LIST,
        guards=[requires_superuser],
    )
    async def list_journal_entries_per_table(
        self,
        journal_entries_service: JournalEntryService,
        table_name: str = Parameter(
            title="Table name", description="The table name to get journal from."
        ),
    ) -> list[JournalEntry]:
        """List all journal entries per table."""
        results = await journal_entries_service.list(
            OrderBy(field_name="created_at", sort_order="desc"), table_name=table_name
        )

        return convert(
            obj=results,
            type=list[JournalEntry],  # type: ignore[valid-type]
            from_attributes=True,
        )

    @get(
        operation_id="ListJournalEntriesPerTableAndRecordId",
        path=urls.JOURNAL_ENTRIES_TABLE_DETAIL,
        guards=[requires_superuser],
    )
    async def list_journal_entries_per_table_and_record_id(
        self,
        journal_entries_service: JournalEntryService,
        record_id: UUID = Parameter(
            title="Record id", description="The record_id to get journal for."
        ),
        table_name: str = Parameter(
            title="Table name", description="The table name to get journal from."
        ),
    ) -> list[JournalEntry]:
        """List all journal entries per table."""
        results = await journal_entries_service.list(
            OrderBy(field_name="created_at", sort_order="desc"),
            table_name=table_name,
            record_id=record_id,
        )

        return convert(
            obj=results,
            type=list[JournalEntry],  # type: ignore[valid-type]
            from_attributes=True,
        )
