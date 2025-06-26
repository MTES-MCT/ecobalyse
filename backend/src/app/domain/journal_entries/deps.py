from __future__ import annotations

from app.db import models as m
from app.domain.journal_entries.services import JournalEntryService
from app.lib.deps import create_service_provider
from sqlalchemy.orm import joinedload, selectinload

provide_journal_entries_service = create_service_provider(
    JournalEntryService,
    load=[
        selectinload(m.JournalEntry.user).options(
            joinedload(m.User.profile, innerjoin=True)
        ),
    ],
)
