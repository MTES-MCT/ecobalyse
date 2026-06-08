from __future__ import annotations

from typing import TYPE_CHECKING, Any, Dict
from uuid import UUID

from advanced_alchemy.filters import OrderBy
from app.db import models as m
from app.domain.accounts.guards import requires_superuser
from app.domain.components import urls
from app.domain.components.deps import (
    provide_components_service,
)
from app.lib.deps import create_filter_dependencies
from litestar import delete, get, post, put
from litestar.controller import Controller
from litestar.di import Provide
from litestar.params import Parameter

if TYPE_CHECKING:
    from app.domain.components.services import ComponentService


class ComponentController(Controller):
    """Component CRUD"""

    dependencies = {
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

    tags = ["Components"]

    @get(
        operation_id="ListComponents", path=urls.COMPONENT_LIST, exclude_from_auth=True
    )
    async def list_components(
        self,
        components_service: ComponentService,
    ) -> list[Dict[str, Any]]:
        """List components."""
        results = await components_service.list(
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
        data: Dict[str, Any],
        current_user: m.User,
        components_service: ComponentService,
    ) -> Dict[str, Any]:
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
        data: Dict[str, Any],
        components_service: ComponentService,
        current_user: m.User,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to update."
        ),
    ) -> Dict[str, Any]:
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
        components_service: ComponentService,
        current_user: m.User,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to delete."
        ),
    ) -> None:
        """Delete a component."""

        _ = await components_service.delete(item_id=component_id, user=current_user)

    @get(
        operation_id="GetComponent", path=urls.COMPONENT_DETAIL, exclude_from_auth=True
    )
    async def get_component(
        self,
        components_service: ComponentService,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to retrieve."
        ),
    ) -> Dict[str, Any]:
        """Get a component."""

        component = await components_service.get(component_id)
        return component.value
