from __future__ import annotations

from typing import TYPE_CHECKING
from uuid import uuid4

from advanced_alchemy.repository import (
    SQLAlchemyAsyncRepository,
)
from advanced_alchemy.service import (
    SQLAlchemyAsyncRepositoryService,
    is_dict,
    schema_dump,
)
from app.db import models as m

if TYPE_CHECKING:
    from advanced_alchemy.service import ModelDictT

__all__ = ("ProcessService",)


class ProcessService(SQLAlchemyAsyncRepositoryService[m.Process]):
    """Handles database operations for processes."""

    class ProcessRepository(SQLAlchemyAsyncRepository[m.Process]):
        """Process SQLAlchemy Repository."""

        model_type = m.Process

    repository_type = ProcessRepository

    async def to_model_on_create(self, data: ModelDictT[m.Team]) -> ModelDictT[m.Team]:
        data = schema_dump(data)
        return await self._populate_with_owner_and_tags(data, "create")

    match_fields = ["display_name"]

    async def _populate_with_owner_and_tags(
        self,
        data: ModelDictT[m.Team],
        operation: str | None,
    ) -> ModelDictT[m.Team]:
        if operation == "create" and is_dict(data):
            # FIXME: add journal entries

            categories_added: list[str] = data.pop("categories", [])
            data["id"] = data.get("id", uuid4())
            data = await super().to_model(data)
            if categories_added:
                data.process_categories.extend(
                    [
                        await m.ProcessCategory.as_unique_async(
                            self.repository.session,
                            name=category_text,
                        )
                        for category_text in categories_added
                    ],
                )

        return data
