from __future__ import annotations

from typing import TYPE_CHECKING, Annotated, Any
from uuid import UUID

from advanced_alchemy.filters import OrderBy
from litestar import delete, get, post, put
from litestar.controller import Controller
from litestar.di import NamedDependency, Provide
from litestar.params import Parameter

from app.db import models as m
from app.domain.accounts.guards import requires_superuser
from app.domain.components import urls
from app.domain.components.deps import (
    provide_components_service,
)
from app.lib.deps import create_filter_dependencies

if TYPE_CHECKING:
    from litestar.router import Router

    from app.domain.components.services import ComponentService


class ComponentController(Controller):
    """Component CRUD"""

    def __init__(self, owner: Router) -> None:

        self.dependencies = {
            "components_service": Provide(provide_components_service),
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
        self.tags = ["Components"]
        super().__init__(owner)

    @get(
        operation_id="ListComponents", path=urls.COMPONENT_LIST, exclude_from_auth=True
    )
    async def list_components(
        self,
        components_service: NamedDependency[ComponentService],
    ) -> list[dict[str, Any] | None]:
        """List components."""
        results = await components_service.get_many(
            OrderBy(field_name="id", sort_order="asc"), uniquify=True
        )

        components = []
        for result in results:
            components.append(result.value)

        return components

    @post(
        operation_id="CreateComponent",
        path=urls.COMPONENT_CREATE,
        guards=[requires_superuser],
    )
    async def create_component(
        self,
        data: dict[str, Any],
        current_user: NamedDependency[m.User],
        components_service: NamedDependency[ComponentService],
    ) -> dict[str, Any] | None:
        """Create a component."""

        data["owner"] = current_user

        component = await components_service.create(data=data)

        return component.value

    @put(
        operation_id="UpdateComponent",
        path=urls.COMPONENT_UPDATE,
        guards=[requires_superuser],
    )
    async def update_component(
        self,
        data: dict[str, Any],
        components_service: NamedDependency[ComponentService],
        current_user: NamedDependency[m.User],
        component_id: Annotated[
            UUID,
            Parameter(title="Component ID", description="The component to update."),
        ],
    ) -> dict[str, Any] | None:
        """Update a component."""

        data["owner"] = current_user
        data["id"] = component_id

        component = await components_service.update(item_id=component_id, data=data)

        return component.value

    @delete(
        operation_id="DeleteComponent",
        guards=[requires_superuser],
        path=urls.COMPONENT_DELETE,
    )
    async def delete_component(
        self,
        components_service: NamedDependency[ComponentService],
        current_user: NamedDependency[m.User],
        component_id: Annotated[
            UUID,
            Parameter(title="Component ID", description="The component to delete."),
        ],
    ) -> None:
        """Delete a component."""

        _ = await components_service.delete_with_user(
            item_id=component_id, user=current_user
        )

    @get(
        operation_id="GetComponent", path=urls.COMPONENT_DETAIL, exclude_from_auth=True
    )
    async def get_component(
        self,
        components_service: NamedDependency[ComponentService],
        component_id: Annotated[
            UUID,
            Parameter(title="Component ID", description="The component to retrieve."),
        ],
    ) -> dict[str, Any] | None:
        """Get a component."""

        component = await components_service.get(component_id)
        return component.value
