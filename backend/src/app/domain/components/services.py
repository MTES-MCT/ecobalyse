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
from app.domain.components.schemas import Component, ComponentElement
from app.domain.processes.deps import (
    provide_processes_service,
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
        with self.repository.session.no_autoflush:
            has_id = data.get("id") is not None

            owner: m.User | None = data.pop("owner", None)
            input_data = copy.deepcopy(data)
            # elements_service = await anext(
            #     provide_elements_service(self.repository.session)
            # )
            processes_service = await anext(
                provide_processes_service(self.repository.session)
            )

            if (
                operation == "create"
                and is_dict(data)
                or (operation == "upsert" and not has_id)
            ):
                data["id"] = data.get("id", uuid4())
                elements: list[ComponentElement] = data.pop("elements", [])
                model_elements = []
                for element in elements:
                    element_dict = element
                    tranforms_ids = element_dict.pop("transforms")

                    element_dict["material_id"] = element_dict.pop("material")
                    element_dict["component_id"] = data["id"]
                    elt = m.Element(**element_dict)
                    self.repository.session.add(elt)
                    elt.process_transforms.extend(
                        await processes_service.list(m.Process.id.in_(tranforms_ids))
                    )
                    model_elements.append(elt)

                    # from rich.pretty import pprint
                    #
                    # pprint("elt.to_dict()")
                    # pprint(elt.to_dict())
                    #
                    # if len(elt.process_transforms) > 0:
                    #     pprint("pprint(elt.process_transforms[0].to_dict())")
                    #     pprint(elt.process_transforms[0].to_dict())

                data["elements"] = model_elements
                data = await super().to_model(data)

                if owner:
                    value = self.to_schema(data, schema_type=Component)

                    owner.journal_entries.append(
                        m.JournalEntry(
                            table_name=m.Component.__tablename__,
                            record_id=data.id,
                            action=m.JournalAction.CREATED,
                            user=owner,
                            value=value,
                        )
                    )

            if (
                operation == "update"
                and is_dict(data)
                or (operation == "upsert" and has_id)
            ):
                from rich.pretty import pprint

                data["id"] = data.get("id", uuid4())
                elements: list[ComponentElement] = data.pop("elements", [])
                model_elements = []
                for element in elements:
                    element_dict = element.to_dict()
                    tranforms_ids = element_dict.pop("transforms")

                    element_dict["material_id"] = element_dict.pop("material")
                    element_dict["component_id"] = data["id"]
                    elt = m.Element(**element_dict)
                    self.repository.session.add(elt)
                    elt.process_transforms.extend(
                        await processes_service.list(m.Process.id.in_(tranforms_ids))
                    )
                    model_elements.append(elt)

                    # pprint("elt.to_dict()")
                    # pprint(elt.to_dict())
                    #
                    # if len(elt.process_transforms) > 0:
                    #     pprint("pprint(elt.process_transforms[0].to_dict())")
                    #     pprint(elt.process_transforms[0].to_dict())

                data["elements"] = model_elements
                data = await super().to_model(data)
                pprint(data.elements)

                # data = await super().to_model(data)

                # pprint(data)

                # data = await super().to_model(data)
                # data = m.Component(**data)

                # data = await super().get(item_id=data["id"])

                # if name is not None:
                #     data.name = name
                #
                # if comment is not None:
                #     data.comment = comment
                # if scopes is not None:
                #     data.scopes = scopes

                # if elements is not None:
                #     if len(elements) > 0:
                #         # Create the elements
                #
                #         for element in elements:
                #             element_to_add = m.Element(
                #                 amount=element.amount,
                #                 material_id=element.material,
                #                 component=data,
                #             )

                # if element.transforms:
                #     # if (obj := (await session.execute(statement)).scalar_one_or_none()) is None:
                #     process_transforms = await processes_service.list(
                #         m.Process.id.in_(element.transforms)
                #     )
                #
                #     if len(element.transforms) != len(process_transforms):
                #         raise ForeignKeyError(
                #             detail=f"A foreign key for transforms is invalid {element.transforms} {process_transforms}"
                #         )
                #
                #     element_to_add.process_transforms.extend(
                #         process_transforms
                #     )

                # data.elements.append(element_to_add)
                # self.repository.session.add(element_to_add)

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
