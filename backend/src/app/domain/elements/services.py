from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import uuid4

from advanced_alchemy.exceptions import ForeignKeyError
from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.service import (
    SQLAlchemyAsyncRepositoryService,
    is_dict,
    schema_dump,
)
from app.db import models as m
from app.domain.processes.deps import (
    provide_processes_service,
)

if TYPE_CHECKING:
    from advanced_alchemy.service import ModelDictT

__all__ = ("ElementService",)


class ElementService(SQLAlchemyAsyncRepositoryService[m.Element]):
    """Handles database operations for elements."""

    class ElementRepository(SQLAlchemyAsyncRepository[m.Element]):
        """Element SQLAlchemy Repository."""

        model_type = m.Element

    repository_type = ElementRepository

    async def to_model_on_create(
        self, data: ModelDictT[m.Element]
    ) -> ModelDictT[m.Element]:
        data = schema_dump(data)
        return await self._populate_with_transforms(data, "create")

    async def to_model_on_update(
        self, data: ModelDictT[m.Element]
    ) -> ModelDictT[m.Element]:
        data = schema_dump(data)
        return await self._populate_with_transforms(data, "update")

    async def _populate_with_transforms(
        self,
        data: ModelDictT[m.Element],
        operation: str | None,
    ) -> ModelDictT[m.Element]:
        processes_service = await anext(
            provide_processes_service(self.repository.session)
        )

        if operation == "create" and is_dict(data):
            transforms_added: list[str] = data.pop("transforms", [])
            data["id"] = data.get("id", uuid4())
            data["material_id"] = data.pop("material")

            data = await super().to_model(data)

            if transforms_added:
                to_extend = await processes_service.list(
                    m.Process.id.in_(transforms_added)
                )
                if len(to_extend) != len(transforms_added):
                    raise ForeignKeyError(
                        detail=f"A foreign key for transforms is invalid {to_extend} {transforms_added}"
                    )

                data.process_transforms.extend(to_extend)

        if operation == "update" and is_dict(data):
            transforms_updated: list[str] = data.pop("transforms", [])
            material_id = data.pop("material")
            amount = data.pop("amount")

            data = await super().get(item_id=data["id"])
            data.material_id = material_id
            data.amount = amount

            if transforms_updated:
                existing_transforms = [
                    transform.id for transform in data.process_transforms
                ]
                transforms_to_remove = [
                    transform
                    for transform in data.process_transforms
                    if transform.id not in transforms_updated
                ]
                transforms_to_add = [
                    transform
                    for transform in transforms_updated
                    if transform not in existing_transforms
                ]

                for transform_rm in transforms_to_remove:
                    data.process_transforms.remove(transform_rm)

                data.process_transforms.extend(
                    await processes_service.list(m.Process.id.in_(transforms_to_add))
                )
        return data
