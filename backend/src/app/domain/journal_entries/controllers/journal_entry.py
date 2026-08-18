from __future__ import annotations

from typing import TYPE_CHECKING, Annotated
from uuid import UUID

from advanced_alchemy.filters import OrderBy
from litestar import get
from litestar.controller import Controller
from litestar.di import NamedDependency, Provide
from litestar.params import Parameter

from app.domain.accounts.guards import requires_superuser
from app.domain.journal_entries import urls
from app.domain.journal_entries.deps import provide_journal_entries_service
from app.domain.journal_entries.schemas import JournalEntry

if TYPE_CHECKING:
    from litestar.router import Router

    from app.domain.journal_entries.services import JournalEntryService


class JournalEntryController(Controller):
    """JournalEntry CRUD"""

    def __init__(self, owner: Router) -> None:
        self.tags = ["Journal entries"]
        self.dependencies = {
            "journal_entries_service": Provide(provide_journal_entries_service),
        }
        super().__init__(owner)

    @get(
        operation_id="ListJournalEntries",
        path=urls.JOURNAL_ENTRIES_LIST,
        guards=[requires_superuser],
    )
    async def list_journal_entries(
        self,
        journal_entries_service: NamedDependency[JournalEntryService],
    ) -> list[JournalEntry]:
        """List all journal entries."""
        results = await journal_entries_service.get_many(
            OrderBy(field_name="created_at", sort_order="desc"),
        )

        converted_results = [
            JournalEntry.model_validate(converted_result)
            for converted_result in results
        ]
        return converted_results

    @get(
        operation_id="ListJournalEntriesPerTable",
        path=urls.JOURNAL_ENTRIES_TABLE_LIST,
        guards=[requires_superuser],
    )
    async def list_journal_entries_per_table(
        self,
        journal_entries_service: NamedDependency[JournalEntryService],
        table_name: str = Parameter(
            title="Table name", description="The table name to get journal from."
        ),
    ) -> list[JournalEntry]:
        """List all journal entries per table."""
        results = await journal_entries_service.get_many(
            OrderBy(field_name="created_at", sort_order="desc"), table_name=table_name
        )

        converted_results = [
            JournalEntry.model_validate(converted_result)
            for converted_result in results
        ]
        return converted_results

    @get(
        operation_id="ListJournalEntriesPerTableAndRecordId",
        path=urls.JOURNAL_ENTRIES_TABLE_DETAIL,
        guards=[requires_superuser],
    )
    async def list_journal_entries_per_table_and_record_id(
        self,
        journal_entries_service: NamedDependency[JournalEntryService],
        record_id: Annotated[
            UUID,
            Parameter(
                title="Record id", description="The record_id to get journal for."
            ),
        ],
        table_name: Annotated[
            str,
            Parameter(
                title="Table name", description="The table name to get journal from."
            ),
        ],
    ) -> list[JournalEntry]:
        """List all journal entries per table."""
        results = await journal_entries_service.get_many(
            OrderBy(field_name="created_at", sort_order="desc"),
            table_name=table_name,
            record_id=record_id,
        )

        converted_results = [
            JournalEntry.model_validate(converted_result)
            for converted_result in results
        ]
        return converted_results
