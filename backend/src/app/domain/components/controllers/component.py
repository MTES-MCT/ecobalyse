from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import UUID

from advanced_alchemy.filters import OrderBy
from advanced_alchemy.service.typing import (
    convert,
)
from app.db import models as m
from app.domain.accounts.guards import requires_superuser
from app.domain.components import urls
from app.domain.components.deps import (
    provide_components_service,
)
from app.domain.components.schemas import (
    Component,
    ComponentCreate,
    ComponentUpdate,
)
from app.lib.deps import create_filter_dependencies
from litestar import delete, get, patch, post
from litestar.controller import Controller
from litestar.di import Provide
from litestar.params import Parameter
from litestar.status_codes import HTTP_200_OK

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
        current_user: m.User,
        components_service: ComponentService,
    ) -> Component:
        """Create a component."""

        data = data.to_dict()
        data["owner"] = current_user

        component = await components_service.create(data=data)

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
        current_user: m.User,
        component_id: UUID = Parameter(
            title="Component ID", description="The component to update."
        ),
    ) -> Component:
        """Update a component."""

        data = data.to_dict()
        data["owner"] = current_user
        data["id"] = component_id

        component = await components_service.update(item_id=component_id, data=data)

        return components_service.to_schema(component, schema_type=Component)

    @delete(
        operation_id="DeleteComponent",
        guards=[requires_superuser],
        path=urls.COMPONENT_DELETE,
        status_code=HTTP_200_OK,
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
        current_user: m.User,
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

        _ = await components_service.delete_many(item_ids=to_delete, user=current_user)

        for c in to_update:
            data_dict = c.to_dict()
            data_dict["owner"] = current_user
            # For a reason I don’t get update_many doesn’t work as it should, it doesn’t update scopes
            _ = await components_service.update(item_id=c.id, data=data_dict)

        to_create_dicts = []
        for c_to_create in to_create:
            data_dict = c_to_create.to_dict()
            data_dict["owner"] = current_user
            to_create_dicts.append(data_dict)

        _ = await components_service.create_many(data=to_create_dicts)

        updated_components = await components_service.list(
            OrderBy(field_name="name", sort_order="asc"), uniquify=True
        )

        return convert(
            obj=updated_components,
            type=list[Component],  # type: ignore[valid-type]
            from_attributes=True,
        )
