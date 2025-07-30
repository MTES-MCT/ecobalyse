from __future__ import annotations

import re
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
from app.domain.processes.schemas import Impacts, Process

if TYPE_CHECKING:
    from advanced_alchemy.service import ModelDictT

__all__ = ("ProcessService",)


# See https://stackoverflow.com/questions/1175208/elegant-python-function-to-convert-camelcase-to-snake-case
def camel_to_snake(name):
    pattern = re.compile(r"(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])")
    return pattern.sub("_", name).lower()


class ProcessService(SQLAlchemyAsyncRepositoryService[m.Process]):
    """Handles database operations for processes."""

    class ProcessRepository(SQLAlchemyAsyncRepository[m.Process]):
        """Process SQLAlchemy Repository."""

        model_type = m.Process

    repository_type = ProcessRepository

    def to_schema_with_removed_impacts(
        self, process: ModelDictT[m.Process], user: ModelDictT[m.User]
    ) -> Process:
        schema_process = self.to_schema(process, schema_type=Process)

        if not user:
            schema_process.impacts = ProcessService.remove_detailed_impacts(
                schema_process.impacts
            )

        return schema_process

    async def to_model_on_create(
        self, data: ModelDictT[m.Process]
    ) -> ModelDictT[m.Process]:
        data = schema_dump(data)
        return await self._populate_with_categories_and_impacts(data, "create")

    match_fields = ["display_name"]

    @staticmethod
    def remove_detailed_impacts(impacts: Impacts) -> Impacts:
        impacts.acd = 0
        impacts.cch = 0
        impacts.etf = 0
        impacts.etf_c = 0
        impacts.fru = 0
        impacts.fwe = 0
        impacts.htc = 0
        impacts.htc_c = 0
        impacts.htn = 0
        impacts.htn_c = 0
        impacts.ior = 0
        impacts.ldu = 0
        impacts.mru = 0
        impacts.ozd = 0
        impacts.pco = 0
        impacts.pma = 0
        impacts.swe = 0
        impacts.tre = 0
        impacts.wtu = 0
        return impacts

    async def _populate_with_categories_and_impacts(
        self,
        data: ModelDictT[m.Team],
        operation: str | None,
    ) -> ModelDictT[m.Team]:
        if operation == "create" and is_dict(data):
            # FIXME: add journal entries

            categories_added: list[str] = data.pop("categories", [])
            data["id"] = data.get("id", uuid4())

            renamed_process = {}
            for key in data:
                if key == "impacts":
                    for impact_key in data[key]:
                        renamed_process[impact_key.replace("-", "_")] = data[key][
                            impact_key
                        ]
                else:
                    renamed_process[camel_to_snake(key)] = data[key]

            data = await super().to_model(renamed_process)
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
