from __future__ import annotations

from typing import TYPE_CHECKING, Any, ClassVar, cast
from uuid import uuid4

from advanced_alchemy.extensions.litestar import service
from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.repository.typing import (
    ModelT,
)
from advanced_alchemy.service import (
    ModelDictT,
    SQLAlchemyAsyncRepositoryService,
    is_dict,
    schema_dump,
)

from app.db import models as m
from app.domain.processes.deps import (
    provide_processes_service,
)

if TYPE_CHECKING:
    from uuid import UUID

__all__ = ("ComponentService",)


class ComponentService(SQLAlchemyAsyncRepositoryService[m.Component]):
    """Handles database operations for components."""

    class ComponentRepository(SQLAlchemyAsyncRepository[m.Component]):
        """Component SQLAlchemy Repository."""

        model_type = m.Component

    repository_type = ComponentRepository

    match_fields: ClassVar[list[str]] = ["name"]

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

    async def delete_with_user(
        self,
        item_id: Any,
        user: m.User,
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
            ),
        )

    async def _create_component(
        self, data: ModelDictT[m.Component], processes_service, owner_id: UUID
    ):
        if not service.is_dict(data):
            return data

        if "published" not in data:
            data["published"] = False

        data["id"] = data.get("id", uuid4())
        data["value"] = data.copy()

        model = await super().to_model(data)

        self.repository.session.add(
            m.JournalEntry(
                table_name=m.Component.__tablename__,
                record_id=model.id,
                action=m.JournalAction.CREATED,
                user_id=owner_id,
                value=data["value"],
            )
        )

        return model

    async def _update_component(
        self, data: ModelDictT[m.Component], processes_service, owner_id: UUID
    ):

        if not service.is_dict(data):
            return data

        data["id"] = data.get("id", uuid4())
        data["value"] = data.copy()

        model = await super().to_model(data)

        # Avoid SAWarning: Object of type <Process> not in session, add operation along 'ProcessCategory.processes' won't proceed
        # By merging the process we are creating into the existing session
        model = await self.repository.session.merge(model)

        assert owner_id

        entry = m.JournalEntry(
            table_name=m.Component.__tablename__,
            record_id=model.id,
            action=m.JournalAction.UPDATED,
            user_id=owner_id,
            value=data["value"],
        )
        self.repository.session.add(entry)

        return model

    async def _populate_with_journaling(
        self,
        data: ModelDictT[m.Component],
        operation: str | None,
    ) -> ModelDictT[m.Component]:

        if not service.is_dict(data):
            return data

        has_id = data.get("id") is not None

        owner: m.User | None = data.pop("owner", None)
        owner_id: UUID = owner.id if owner else data.pop("owner_id")

        processes_service = await anext(
            provide_processes_service(self.repository.session)
        )

        with self.repository.session.no_autoflush:
            if (
                operation == "create"
                and is_dict(data)
                or (operation == "upsert" and not has_id)
            ):
                return await self._create_component(data, processes_service, owner_id)

            if (
                operation == "update"
                and is_dict(data)
                or (operation == "upsert" and has_id)
            ):
                return await self._update_component(data, processes_service, owner_id)

        return data
