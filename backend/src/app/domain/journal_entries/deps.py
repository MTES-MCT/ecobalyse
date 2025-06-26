from __future__ import annotations

from app.db import models as m
from app.domain.journal_entries.services import JournalEntryService
from app.lib.deps import create_service_provider
from sqlalchemy.orm import joinedload

provide_journal_entries_service = create_service_provider(
    JournalEntryService,
    load=[
        joinedload(m.JournalEntry.user, innerjoin=True).options(
            joinedload(m.User.profile, innerjoin=True)
        ),
    ],
)
