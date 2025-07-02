from __future__ import annotations

from uuid import UUID

from advanced_alchemy.filters import OrderBy
from advanced_alchemy.service.typing import (
    convert,
)
from app.db import models as m
from app.domain.processes import urls
from app.domain.processes.deps import (
    provide_processes_service,
)
from app.domain.processes.schemas import (
    Process,
)
from app.domain.processes.services import ProcessService
from app.lib.deps import create_filter_dependencies
from litestar import get
from litestar.controller import Controller
from litestar.di import Provide
from litestar.params import Parameter


class ProcessController(Controller):
    """Process CRUD"""

    dependencies = {
        "processes_service": Provide(provide_processes_service),
    } | create_filter_dependencies(
        {
            "id_filter": UUID,
            "search": "name",
            "pagination_type": "limit_offset",
            "pagination_size": 20,
            "created_at": True,
            "updated_at": True,
        },
    )

    tags = ["Processes"]

    @get(operation_id="ListProcesses", path=urls.PROCESS_LIST, exclude_from_auth=True)
    async def list_processes(
        self,
        processes_service: ProcessService,
    ) -> list[Process]:
        """List processes."""
        results = await processes_service.list(
            OrderBy(field_name="display_name", sort_order="asc"), uniquify=True
        )

        return convert(
            obj=results,
            type=list[Process],  # type: ignore[valid-type]
            from_attributes=True,
        )

    @get(operation_id="GetProcess", path=urls.PROCESS_DETAIL, allow_none_user=True)
    async def get_process(
        self,
        current_user: m.User | None,
        processes_service: ProcessService,
        process_id: UUID = Parameter(
            title="Process ID", description="The process to retrieve."
        ),
    ) -> Process:
        """Get a process."""

        process = await processes_service.get(process_id)
        schema_process = processes_service.to_schema(process, schema_type=Process)

        if not current_user:
            schema_process.impacts = ProcessService.remove_detailed_impacts(
                schema_process.impacts
            )

        return schema_process
