from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.filters import OrderBy
from advanced_alchemy.service.typing import (
    convert,
)
from app.domain.accounts.guards import requires_superuser
from app.domain.components import urls
from app.domain.components.deps import (
    provide_components_service,
    provide_scopes_service,
)
from app.domain.components.schemas import (
    Component,
    ComponentCreate,
    ComponentUpdate,
    DbScope,
)
from app.lib.deps import create_filter_dependencies
from litestar import delete, get, patch, post
from litestar.controller import Controller
from litestar.di import Provide
from litestar.params import Parameter

if TYPE_CHECKING:
    from app.domain.components.services import ComponentService, ScopeService


class ComponentController(Controller):
    """Component CRUD"""

    dependencies = {
        "components_service": Provide(provide_components_service),
        "scopes_service": Provide(provide_scopes_service),
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

    @get(operation_id="ListScopes", path=urls.SCOPE_LIST, exclude_from_auth=True)
    async def list_scopes(
        self,
        scopes_service: ScopeService,
    ) -> list[DbScope]:
        """List scopes."""
        results = await scopes_service.list()

        return convert(
            obj=results,
            type=list[DbScope],  # type: ignore[valid-type]
            from_attributes=True,
        )

    @get(
        operation_id="ListComponents", path=urls.COMPONENT_LIST, exclude_from_auth=True
    )
    async def list_components(
        self,
        components_service: ComponentService,
    ) -> list[Component]:
        """List components."""
        results = await components_service.list(
            OrderBy(field_name="name", sort_order="asc"), uniquify=True
        )

        return components_service.from_list_db_to_response(results)

    @post(
        operation_id="CreateComponent",
        path=urls.COMPONENT_CREATE,
        guards=[requires_superuser],
    )
    async def create_component(
        self,
        data: ComponentCreate,
        components_service: ComponentService,
        scopes_service: ScopeService,
    ) -> Component:
        """Create a component."""

        await scopes_service.validate_scopes(data.scopes)

        component = await components_service.create(data=data.to_dict())

        # Force reload from db to get scopes
        created_component = await components_service.get_one(id=component.id)

        return components_service.from_db_to_response(created_component)

    @patch(
        operation_id="UpdateComponent",
        path=urls.COMPONENT_UPDATE,
        guards=[requires_superuser],
    )
    async def update_component(
        self,
        data: ComponentUpdate,
        components_service: ComponentService,
        scopes_service: ScopeService,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to update."
        ),
    ) -> Component:
        """Update a component."""

        await scopes_service.validate_scopes(data.scopes)

        component = await components_service.update(
            item_id=component_id, data=data.to_dict()
        )

        component_with_scopes = await components_service.get_one(id=component.id)

        return components_service.from_db_to_response(component_with_scopes)

    @delete(
        operation_id="DeleteComponent",
        guards=[requires_superuser],
        path=urls.COMPONENT_DELETE,
    )
    async def delete_component(
        self,
        components_service: ComponentService,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to delete."
        ),
    ) -> None:
        """Delete a component."""

        _ = await components_service.delete(item_id=component_id)

    @get(
        operation_id="GetComponent", path=urls.COMPONENT_DETAIL, exclude_from_auth=True
    )
    async def get_component(
        self,
        components_service: ComponentService,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to retrieve."
        ),
    ) -> Component:
        """Get a component."""

        component = await components_service.get(component_id)
        return components_service.from_db_to_response(component)

    @patch(
        operation_id="BulkUpdateComponent",
        guards=[requires_superuser],
        path=urls.COMPONENT_BULK_UPDATE,
    )
    async def bulk_update_component(
        self,
        data: list[ComponentUpdate],
        components_service: ComponentService,
    ) -> list[Component]:
        """Update a list of components."""

        existing_components = await components_service.list(uniquify=True)

        existing_components_ids = [c.id for c in existing_components]

        to_delete: list[UUID] = []
        to_update: list[UUID] = [
            component for component in data if component.id in existing_components_ids
        ]
        to_create: list[UUID] = [
            component
            for component in data
            if component.id not in existing_components_ids
        ]

        for component_id in existing_components_ids:
            if component_id not in [c.id for c in data]:
                to_delete.append(component_id)

        _ = await components_service.delete_many(item_ids=to_delete)

        for c in to_update:
            # For a reason I don’t get update_many doesn’t work as it should, it doesn’t update scopes
            _ = await components_service.update(item_id=c.id, data=c.to_dict())

        _ = await components_service.create_many(data=to_create)

        updated_components = await components_service.list(
            OrderBy(field_name="name", sort_order="asc"), uniquify=True
        )

        return components_service.from_list_db_to_response(updated_components)
