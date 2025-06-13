from __future__ import annotations

from uuid import uuid4

from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.service import (
    ModelDictT,
    SQLAlchemyAsyncRepositoryService,
    is_dict,
    schema_dump,
)
from app.db import models as m
from app.domain.components.schemas import (
    Component,
    DbComponent,
)
from litestar.exceptions import ValidationException

__all__ = (
    "ComponentService",
    "ScopeService",
)


class ComponentService(SQLAlchemyAsyncRepositoryService[m.ComponentModel]):
    """Handles database operations for components."""

    class ComponentRepository(SQLAlchemyAsyncRepository[m.ComponentModel]):
        """Component SQLAlchemy Repository."""

        model_type = m.ComponentModel

    repository_type = ComponentRepository

    match_fields = ["name"]

    async def from_db_to_response(self, db_component: m.ComponentModel) -> Component:
        db_component_schema = self.to_schema(db_component, schema_type=DbComponent)

        return Component(
            id=db_component_schema.id,
            name=db_component_schema.name,
            elements=db_component_schema.elements,
            scopes=[s.value for s in db_component_schema.scopes],
        )

    async def from_list_db_to_response(
        self, db_components: list[m.ComponentModel]
    ) -> list[Component]:
        return [
            await self.from_db_to_response(db_component)
            for db_component in db_components
        ]

    async def to_model_on_create(self, data: ModelDictT[m.Team]) -> ModelDictT[m.Team]:
        data = schema_dump(data)
        return await self._populate_with_scopes(data, "create")

    async def to_model_on_update(self, data: ModelDictT[m.Team]) -> ModelDictT[m.Team]:
        data = schema_dump(data)
        return await self._populate_with_scopes(data, "update")

    async def to_model_on_upsert(self, data: ModelDictT[m.Team]) -> ModelDictT[m.Team]:
        data = schema_dump(data)
        return await self._populate_with_scopes(data, "upsert")

    async def _populate_with_scopes(
        self,
        data: ModelDictT[m.Team],
        operation: str | None,
    ) -> ModelDictT[m.Team]:
        has_id = data.get("id") is not None

        if (
            operation == "create"
            and is_dict(data)
            or (operation == "upsert" and not has_id)
        ):
            scopes_added: list[str] = data.pop("scopes", [])
            data["id"] = data.get("id", uuid4())
            data = await super().to_model(data)
            if scopes_added:
                data.scopes.extend(
                    [
                        await m.Scope.as_unique_async(
                            self.repository.session,
                            value=scope_value,
                        )
                        for scope_value in scopes_added
                    ],
                )

        if (
            operation == "update"
            and is_dict(data)
            or (operation == "upsert" and has_id)
        ):
            scopes_updated = data.pop("scopes", None)
            data = await super().to_model(data)
            if scopes_updated:
                existing_scopes = [scope.value for scope in data.scopes]

                scopes_to_remove = [
                    scope for scope in data.scopes if scope.value not in scopes_updated
                ]

                scopes_to_add = [
                    scope for scope in scopes_updated if scope not in existing_scopes
                ]

                for scope_rm in scopes_to_remove:
                    data.scopes.remove(scope_rm)
                data.scopes.extend(
                    [
                        await m.Scope.as_unique_async(
                            self.repository.session,
                            value=scope_value,
                        )
                        for scope_value in scopes_to_add
                    ],
                )

        return data


class ScopeService(SQLAlchemyAsyncRepositoryService[m.Scope]):
    """Handles database operations for components."""

    class ScopeRepository(SQLAlchemyAsyncRepository[m.Scope]):
        """Scope SQLAlchemy Repository."""

        model_type = m.Scope

    repository_type = ScopeRepository

    match_fields = ["value"]

    async def validate_scopes(self, scopes: list[str]) -> bool:
        possible_scopes = [s.value for s in await self.list()]

        if not all([s in possible_scopes for s in scopes]):
            raise ValidationException(
                detail=f"Scope must be one of `{', '.join(possible_scopes)}`"
            )

        return True
