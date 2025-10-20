from typing import TYPE_CHECKING

import pytest
from app.cli.commands import _migrate_elements
from app.domain.components.deps import provide_components_service
from sqlalchemy.ext.asyncio import (
    AsyncSession,
)

if TYPE_CHECKING:
    from httpx import AsyncClient
    from sqlalchemy.ext.asyncio import AsyncSession

pytestmark = pytest.mark.anyio


async def test_migrate_elements(client: "AsyncClient", session: AsyncSession) -> None:
    components_service = await anext(provide_components_service(session))
    components = await components_service.list()

    assert len(components) == 7

    for component in components:
        if str(component.id) == "190276e9-5b90-42d6-8fbd-bc7ddfd4c960":
            assert component.elements_json == [
                {
                    "amount": 3,
                    "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
                }
            ]
            assert component.elements == []

    # Migrate elements
    await _migrate_elements(session)

    components = await components_service.list()

    for component in components:
        if str(component.id) == "190276e9-5b90-42d6-8fbd-bc7ddfd4c960":
            assert component.elements_json == [
                {
                    "amount": 3,
                    "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
                }
            ]
            assert len(component.elements) == 1
