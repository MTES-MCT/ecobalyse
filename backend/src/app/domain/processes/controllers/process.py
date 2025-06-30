from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.filters import OrderBy
from advanced_alchemy.service.typing import (
    convert,
)
from app.domain.processes import urls
from app.domain.processes.deps import (
    provide_processes_service,
)
from app.domain.processes.schemas import (
    Process,
)
from app.lib.deps import create_filter_dependencies
from litestar import get
from litestar.controller import Controller
from litestar.di import Provide

if TYPE_CHECKING:
    from app.domain.processes.services import ProcessService


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
