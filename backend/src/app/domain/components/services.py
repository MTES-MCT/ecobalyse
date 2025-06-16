from __future__ import annotations

import copy
from collections.abc import Sequence
from typing import Any, Optional, Union, cast
from uuid import uuid4

from advanced_alchemy.exceptions import ErrorMessages
from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.repository._util import LoadSpec
from advanced_alchemy.repository.typing import ModelT
from advanced_alchemy.service import (
    ModelDictT,
    SQLAlchemyAsyncRepositoryService,
    is_dict,
    schema_dump,
)
from advanced_alchemy.utils.dataclass import Empty, EmptyType
from app.db import models as m
from app.domain.components.schemas import (
    Component,
    DbComponent,
)
from litestar.exceptions import ValidationException
from sqlalchemy.orm import InstrumentedAttribute

__all__ = ("ComponentService",)


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

    async def to_model_on_create(
        self, data: ModelDictT[m.ComponentModel]
    ) -> ModelDictT[m.ComponentModel]:
        data = schema_dump(data)
        return await self._populate_with_scopes(data, "create")

    async def to_model_on_update(
        self, data: ModelDictT[m.ComponentModel]
    ) -> ModelDictT[m.ComponentModel]:
        data = schema_dump(data)
        return await self._populate_with_scopes(data, "update")

    async def to_model_on_upsert(
        self, data: ModelDictT[m.ComponentModel]
    ) -> ModelDictT[m.ComponentModel]:
        data = schema_dump(data)
        return await self._populate_with_scopes(data, "upsert")

    async def delete(
        self,
        item_id: Any,
        user: m.User,
        *,
        auto_commit: Optional[bool] = None,
        auto_expunge: Optional[bool] = None,
        id_attribute: Optional[Union[str, InstrumentedAttribute[Any]]] = None,
        error_messages: Optional[Union[ErrorMessages, EmptyType]] = Empty,
        load: Optional[LoadSpec] = None,
        execution_options: Optional[dict[str, Any]] = None,
        uniquify: Optional[bool] = None,
    ) -> ModelT:
        """Wrap repository delete operation.

        Args:
            item_id: Identifier of instance to be deleted.
            auto_commit: Commit objects before returning.
            auto_expunge: Remove object from session before returning.
            id_attribute: Allows customization of the unique identifier to use for model fetching.
                Defaults to `id`, but can reference any surrogate or candidate key for the table.
            error_messages: An optional dictionary of templates to use
                for friendlier error messages to clients
            load: Set default relationships to be loaded
            execution_options: Set default execution options
            uniquify: Optionally apply the ``unique()`` method to results before returning.

        Returns:
            Representation of the deleted instance.
        """

        user.journal_entries.append(
            m.JournalEntry(
                table_name=m.ComponentModel.__tablename__,
                record_id=item_id,
                action=m.JournalAction.DELETED,
                user=user,
            )
        )
        return cast(
            "ModelT",
            await self.repository.delete(
                item_id=item_id,
                auto_commit=auto_commit,
                auto_expunge=auto_expunge,
                id_attribute=id_attribute,
                error_messages=error_messages,
                load=load,
                execution_options=execution_options,
                uniquify=self._get_uniquify(uniquify),
            ),
        )

    async def delete_many(
        self,
        item_ids: list[Any],
        user: m.User,
        *,
        auto_commit: Optional[bool] = None,
        auto_expunge: Optional[bool] = None,
        id_attribute: Optional[Union[str, InstrumentedAttribute[Any]]] = None,
        chunk_size: Optional[int] = None,
        error_messages: Optional[Union[ErrorMessages, EmptyType]] = Empty,
        load: Optional[LoadSpec] = None,
        execution_options: Optional[dict[str, Any]] = None,
        uniquify: Optional[bool] = None,
    ) -> Sequence[ModelT]:
        """Wrap repository bulk instance deletion.

        Args:
            item_ids: Identifier of instance to be deleted.
            auto_expunge: Remove object from session before returning.
            auto_commit: Commit objects before returning.
            id_attribute: Allows customization of the unique identifier to use for model fetching.
                Defaults to `id`, but can reference any surrogate or candidate key for the table.
            chunk_size: Allows customization of the ``insertmanyvalues_max_parameters`` setting for the driver.
                Defaults to `950` if left unset.
            error_messages: An optional dictionary of templates to use
                for friendlier error messages to clients
            load: Set default relationships to be loaded
            execution_options: Set default execution options
            uniquify: Optionally apply the ``unique()`` method to results before returning.

        Returns:
            Representation of removed instances.
        """

        for item_id in item_ids:
            user.journal_entries.append(
                m.JournalEntry(
                    table_name=m.ComponentModel.__tablename__,
                    record_id=item_id,
                    action=m.JournalAction.DELETED,
                    user=user,
                )
            )
        return cast(
            "Sequence[ModelT]",
            await self.repository.delete_many(
                item_ids=item_ids,
                auto_commit=auto_commit,
                auto_expunge=auto_expunge,
                id_attribute=id_attribute,
                chunk_size=chunk_size,
                error_messages=error_messages,
                load=load,
                execution_options=execution_options,
                uniquify=self._get_uniquify(uniquify),
            ),
        )

    async def _populate_with_scopes(
        self,
        data: ModelDictT[m.ComponentModel],
        operation: str | None,
    ) -> ModelDictT[m.ComponentModel]:
        has_id = data.get("id") is not None

        owner: m.User | None = data.pop("owner", None)
        input_data = copy.deepcopy(data)

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

            if owner:
                owner.journal_entries.append(
                    m.JournalEntry(
                        table_name=m.ComponentModel.__tablename__,
                        record_id=data.id,
                        action=m.JournalAction.CREATED,
                        user=owner,
                        value=await self.from_db_to_response(data),
                    )
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
            if owner:
                owner.journal_entries.append(
                    m.JournalEntry(
                        table_name=m.ComponentModel.__tablename__,
                        record_id=data.id,
                        action=m.JournalAction.UPDATED,
                        user=owner,
                        value=input_data
                        if is_dict(input_data)
                        else input_data.to_dict(),
                    )
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
                detail=f"Scope must be one of `{', '.join(possible_scopes)}`, got `{', '.join(scopes)}`"
            )

        return True
