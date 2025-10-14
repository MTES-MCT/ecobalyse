from __future__ import annotations

import copy
from collections.abc import Sequence
from typing import TYPE_CHECKING, Any, Optional, Union, cast
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
from app.domain.components.schemas import Component, ComponentElement
from app.domain.processes.deps import (
    provide_processes_service,
)
from sqlalchemy.orm import InstrumentedAttribute

if TYPE_CHECKING:
    from uuid import UUID

__all__ = ("ComponentService",)


class ComponentService(SQLAlchemyAsyncRepositoryService[m.Component]):
    """Handles database operations for components."""

    class ComponentRepository(SQLAlchemyAsyncRepository[m.Component]):
        """Component SQLAlchemy Repository."""

        model_type = m.Component

    repository_type = ComponentRepository

    match_fields = ["name"]

    async def to_model_on_create(
        self, data: ModelDictT[m.Component]
    ) -> ModelDictT[m.Component]:
        data = schema_dump(data)
        return await self._populate_with_journaling(data, "create")

    async def to_model_on_update(
        self, data: ModelDictT[m.Component]
    ) -> ModelDictT[m.Component]:
        data = schema_dump(data)
        return await self._populate_with_journaling(data, "update")

    async def to_model_on_upsert(
        self, data: ModelDictT[m.Component]
    ) -> ModelDictT[m.Component]:
        data = schema_dump(data)
        return await self._populate_with_journaling(data, "upsert")

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
                table_name=m.Component.__tablename__,
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
                    table_name=m.Component.__tablename__,
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

    async def _create_element(
        self,
        element: ModelDictT[ComponentElement],
        component_id: str,
        processes_service,
    ):
        element_dict = (
            element.to_dict() if type(element) is ComponentElement else element
        )
        tranforms_ids = element_dict.pop("transforms", [])

        element_dict["material_process_id"] = element_dict.pop("material")
        element_dict["component_id"] = component_id

        elt = m.Element(**element_dict)

        if len(tranforms_ids):
            elt.process_transforms.extend(
                await processes_service.list(m.Process.id.in_(tranforms_ids))
            )

        return elt

    async def _create_component(
        self, data: ModelDictT[m.Component], processes_service, owner_id: UUID
    ):
        data["id"] = data.get("id", uuid4())
        elements: list[ModelDictT[ComponentElement]] = data.pop("elements", [])

        model = await super().to_model(data)
        for element in elements:
            elt = await self._create_element(element, data["id"], processes_service)
            model.elements.append(elt)

        assert owner_id

        value = self.to_schema(model, schema_type=Component)
        self.repository.session.add(
            m.JournalEntry(
                table_name=m.Component.__tablename__,
                record_id=model.id,
                action=m.JournalAction.CREATED,
                user_id=owner_id,
                value=value,
            )
        )

        return model

    async def _update_component(
        self, data: ModelDictT[m.Component], processes_service, owner_id: UUID
    ):
        # Used for journaling as it is the only moment where we have the full object in json
        # In the following code, the model is either without the name/scopes changes
        input_data = copy.deepcopy(data)

        data["id"] = data.get("id", uuid4())
        elements: list[ComponentElement] = data.pop("elements", [])

        model = await self.repository.get(item_id=data["id"])
        model.elements = []

        for element in elements:
            elt = await self._create_element(element, model, processes_service)
            model.elements.append(elt)

        model = await super().to_model(data)

        assert owner_id

        entry = m.JournalEntry(
            table_name=m.Component.__tablename__,
            record_id=model.id,
            action=m.JournalAction.UPDATED,
            user_id=owner_id,
            value=input_data,
        )
        self.repository.session.add(entry)

        return model

    async def _populate_with_journaling(
        self,
        data: ModelDictT[m.Component],
        operation: str | None,
    ) -> ModelDictT[m.Component]:
        has_id = data.get("id") is not None

        owner: m.User | None = data.pop("owner", None)
        owner_id: UUID | None = data.pop("owner_id", None)

        processes_service = await anext(
            provide_processes_service(self.repository.session)
        )

        with self.repository.session.no_autoflush:
            if (
                operation == "create"
                and is_dict(data)
                or (operation == "upsert" and not has_id)
            ):
                return await self._create_component(
                    data, processes_service, owner.id if owner else owner_id
                )

            if (
                operation == "update"
                and is_dict(data)
                or (operation == "upsert" and has_id)
            ):
                return await self._update_component(
                    data, processes_service, owner.id if owner else owner_id
                )

        return data
