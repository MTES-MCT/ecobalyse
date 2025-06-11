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
    Scope,
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
    ) -> list[Scope]:
        """List scopes."""
        results = await scopes_service.list()

        return convert(
            obj=results,
            type=list[Scope],  # type: ignore[valid-type]
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

        return convert(
            obj=results,
            type=list[Component],  # type: ignore[valid-type]
            from_attributes=True,
        )

    @post(
        operation_id="CreateComponent",
        path=urls.COMPONENT_CREATE,
        guards=[requires_superuser],
    )
    async def create_component(
        self,
        data: ComponentCreate,
        components_service: ComponentService,
    ) -> Component:
        """Create a component."""

        component = await components_service.create(data=data.to_dict())

        return components_service.to_schema(component, schema_type=Component)

    @patch(
        operation_id="UpdateComponent",
        path=urls.COMPONENT_UPDATE,
        guards=[requires_superuser],
    )
    async def update_component(
        self,
        data: ComponentUpdate,
        components_service: ComponentService,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to update."
        ),
    ) -> Component:
        """Update a component."""

        component = await components_service.update(
            item_id=component_id, data=data.to_dict()
        )

        return components_service.to_schema(component, schema_type=Component)

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
        return components_service.to_schema(component, schema_type=Component)

    @patch(
        operation_id="BulkUpdateComponent",
        guards=[requires_superuser],
        path=urls.COMPONENT_BULK_UPDATE,
    )
    async def bulk_update_component(
        self,
        data: list[ComponentUpdate],
        components_service: ComponentService,
    ) -> Component:
        """Update a list of components."""

        existing_components, _ = await components_service.list_and_count(uniquify=True)

        to_delete: list[UUID] = []
        to_update: list[UUID] = [component.id for component in data if component.id]

        for component in existing_components:
            if component.id not in to_update:
                to_delete.append(component.id)

        _ = await components_service.delete_many(item_ids=to_delete)
        components = await components_service.upsert_many(data=data, uniquify=True)

        return convert(
            obj=components,
            type=list[Component],  # type: ignore[valid-type]
            from_attributes=True,
        )
