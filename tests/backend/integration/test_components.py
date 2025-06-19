from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from httpx import AsyncClient

pytestmark = pytest.mark.anyio


async def test_components_create(
    client: "AsyncClient",
    superuser_token_headers: dict[str, str],
    user_token_headers: dict[str, str],
) -> None:
    response = await client.post(
        "/api/components",
        json={
            "name": "New Component",
            "elements": [
                {"amount": 0.91125, "material": "59b42284-3e45-5343-8a20-1d7d66137461"}
            ],
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 201
    assert json["name"] == "New Component"
    assert len(json["elements"]) == 1
    assert len(json["id"]) == 36


async def test_components_access(
    client: "AsyncClient",
    user_token_headers: dict[str, str],
    superuser_token_headers: dict[str, str],
) -> None:
    # Test create access
    response = await client.post(
        "/api/components",
        json={
            "name": "New Component",
            "elements": [
                {"amount": 0.91125, "material": "59b42284-3e45-5343-8a20-1d7d66137461"}
            ],
        },
        headers=user_token_headers,
    )

    assert response.status_code == 403

    # Test update access
    response = await client.patch(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        json={
            "name": "Name Changed",
        },
        headers=user_token_headers,
    )
    assert response.status_code == 403

    # Test delete access
    response = await client.delete(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        headers=user_token_headers,
    )
    assert response.status_code == 403

    # Test update access
    response = await client.patch(
        "/api/components",
        json=[],
    )
    assert response.status_code == 401

    # Test bulk update access
    response = await client.patch(
        "/api/components",
        json=[],
        headers=user_token_headers,
    )
    assert response.status_code == 403

    response = await client.get(
        "/api/components",
    )
    assert response.status_code == 200

    response = await client.get(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
    )
    assert response.status_code == 200


async def test_components_update(
    client: "AsyncClient", superuser_token_headers: dict[str, str]
) -> None:
    response = await client.patch(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        json={
            "name": "Name Changed",
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 200
    assert json["name"] == "Name Changed"
    assert json["elements"] is None


async def test_components_delete(
    client: "AsyncClient",
    superuser_token_headers: dict[str, str],
    user_token_headers: dict[str, str],
) -> None:
    response = await client.delete(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        headers=user_token_headers,
    )
    assert response.status_code == 403

    response = await client.delete(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        headers=superuser_token_headers,
    )
    assert response.status_code == 204

    response = await client.get(
        "/api/components",
        headers=superuser_token_headers,
    )

    assert len(response.json()) == 6


async def test_components_bulk_update(
    client: "AsyncClient", superuser_token_headers: dict[str, str]
) -> None:
    json_content = [
        {
            "elements": [
                {
                    "amount": 0.00022,
                    "material": "07e9e916-e02b-45e2-a298-2b5084de6242",
                }
            ],
            "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
            "name": "Pied 70 cm (plein bois)",
        },
        {
            "elements": [
                {
                    "amount": 0.734063,
                    "material": "3295b2a5-328a-4c00-b046-e2ddeb0da823",
                }
            ],
            "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973",
            "name": "Dossier plastique (PP)",
        },
        {
            "elements": [
                {
                    "amount": 0.91125,
                    "material": "3295b2a5-328a-4c00-b046-e2ddeb0da823",
                }
            ],
            "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6",
            "name": "Assise plastique (PP)",
        },
        {
            "elements": [
                {"amount": 0.89, "material": "07e9e916-e02b-45e2-a298-2b5084de6242"}
            ],
            "name": "Test component",
        },
        {
            "elements": [
                {
                    "amount": 1,
                    "material": "62a4d6fb-3276-4ba5-93a3-889ecd3bff84",
                    "transforms": [
                        "9c478d79-ff6b-45e1-9396-c3bd897faa1d",
                        "da9d1c32-a166-41ab-bac6-f67aff0cf44a",
                    ],
                },
                {
                    "amount": 1,
                    "material": "9dba0e95-0c35-4f8b-9267-62ddf47d4984",
                    "transforms": [
                        "9c478d79-ff6b-45e1-9396-c3bd897faa1d",
                        "ae9cbbad-7982-4f3c-9220-edf27946d347",
                    ],
                },
            ],
            "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            "name": "Tissu pour joli canapé",
        },
    ]
    response = await client.patch(
        "/api/components",
        json=json_content,
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 200

    assert len(json) == len(json_content)
    assert json[-1]["name"] == "Tissu pour joli canapé"

    # Remove everything

    response = await client.patch(
        "/api/components",
        json=[],
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 200

    assert len(json) == 0
