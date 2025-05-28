import pytest
from app.__about__ import __version__
from httpx import AsyncClient

pytestmark = pytest.mark.anyio


async def test_health(client: AsyncClient) -> None:
    response = await client.get("/health")
    assert response.status_code == 200

    expected = {
        "database_status": "online",
        "app": "app",
        "version": __version__,
    }

    assert response.json() == expected
