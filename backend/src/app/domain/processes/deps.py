"""Processes Controllers."""

from __future__ import annotations

from app.db import models as m
from app.domain.processes.services import ProcessService
from app.lib.deps import create_service_provider
from sqlalchemy.orm import joinedload, selectinload

provide_processes_service = create_service_provider(
    ProcessService,
    load=[
        selectinload(m.Process.process_categories).options(
            joinedload(m.ProcessCategory.processes, innerjoin=True),
        ),
    ],
)
