from typing import TYPE_CHECKING

import pytest
from advanced_alchemy.exceptions import ForeignKeyError
from app.domain.elements.deps import provide_elements_service
from sqlalchemy.ext.asyncio import (
    AsyncSession,
)

if TYPE_CHECKING:
    from httpx import AsyncClient

pytestmark = pytest.mark.anyio


async def test_elements_creation(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
) -> None:
    elements_service = await anext(provide_elements_service(session))

    element = {
        "id": "67e699bc-5c86-4cc6-b6f2-114e12e48717",
        "amount": 1,
        "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
        "transforms": [
            "97c209ec-7782-5a29-8c47-af7f17c82d11",
            "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
        ],
    }

    # Should work as expected
    await elements_service.create(element, auto_commit=True)

    created_element = await elements_service.get_one_or_none(id=element["id"])

    assert created_element is not None
    assert str(created_element.id) == element["id"]
    assert len(created_element.process_transforms) == 2

    # Remove one transform
    element = {
        "id": "67e699bc-5c86-4cc6-b6f2-114e12e48717",
        "amount": 2,
        "material": "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
        "transforms": [
            "97c209ec-7782-5a29-8c47-af7f17c82d11",
        ],
    }

    await elements_service.update(item_id=element["id"], data=element, auto_commit=True)

    updated_element = await elements_service.get_one_or_none(id=element["id"])
    assert len(updated_element.process_transforms) == 1
    assert updated_element.amount == 2
    assert str(updated_element.material.id) == "af42fc20-e3ec-5b99-9b9c-83ba6735e597"

    element = {
        "id": "fad02e60-54a9-4098-8563-376d11c2acf1",
        "amount": 1,
        "material": "f077f20d-6b83-4317-b813-26d8476cc238",
        "transforms": [
            "97c209ec-7782-5a29-8c47-af7f17c82d11",
            "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
        ],
    }

    # Should throw an error as the foreign key of the transforms doesn’t exist
    element = {
        "amount": 1,
        "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
        "transforms": ["2b63e703-942e-4599-832a-b1b15f5b186f"],
    }

    with pytest.raises(
        ForeignKeyError,
        match="A foreign key for transforms is invalid",
    ):
        await elements_service.create(element, auto_commit=True)
