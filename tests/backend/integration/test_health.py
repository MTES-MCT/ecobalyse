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


async def test_sentry_check(
    client: AsyncClient,
    user_token_headers: dict[str, str],
    superuser_token_headers: dict[str, str],
) -> None:
    response = await client.get("/check-sentry")
    assert response.status_code == 401

    response = await client.get(
        "/check-sentry",
        headers=user_token_headers,
    )
    assert response.status_code == 403

    # Only superuser can generate an error
    response = await client.get(
        "/check-sentry",
        headers=superuser_token_headers,
    )
    assert response.status_code == 500
