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
)
from sqlalchemy.orm import InstrumentedAttribute

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

    async def _populate_with_journaling(
        self,
        data: ModelDictT[m.Component],
        operation: str | None,
    ) -> ModelDictT[m.Component]:
        has_id = data.get("id") is not None

        owner: m.User | None = data.pop("owner", None)
        input_data = copy.deepcopy(data)

        if (
            operation == "create"
            and is_dict(data)
            or (operation == "upsert" and not has_id)
        ):
            data["id"] = data.get("id", uuid4())

            data = await super().to_model(data)

            if owner:
                owner.journal_entries.append(
                    m.JournalEntry(
                        table_name=m.Component.__tablename__,
                        record_id=data.id,
                        action=m.JournalAction.CREATED,
                        user=owner,
                        value=self.to_schema(data, schema_type=Component),
                    )
                )

        if (
            operation == "update"
            and is_dict(data)
            or (operation == "upsert" and has_id)
        ):
            data = await super().to_model(data)
            if owner:
                owner.journal_entries.append(
                    m.JournalEntry(
                        table_name=m.Component.__tablename__,
                        record_id=data.id,
                        action=m.JournalAction.UPDATED,
                        user=owner,
                        value=input_data
                        if is_dict(input_data)
                        else input_data.to_dict(),
                    )
                )

        return data
