"""Processes Controllers."""

from __future__ import annotations

from app.domain.processes.services import ProcessService
from app.lib.deps import create_service_provider

provide_processes_service = create_service_provider(
    ProcessService,
)
