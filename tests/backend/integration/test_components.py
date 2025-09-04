from typing import TYPE_CHECKING

import pytest
from app.db import models as m
from app.domain.journal_entries.services import JournalEntryService
from sqlalchemy.ext.asyncio import (
    AsyncSession,
)

if TYPE_CHECKING:
    from httpx import AsyncClient

pytestmark = pytest.mark.anyio


async def test_components_create(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
) -> None:
    response = await client.post(
        "/api/components",
        json={
            "name": "New Component",
            "comment": "A comment",
            "elements": [
                {"amount": 0.91125, "material": "97c209ec-7782-5a29-8c47-af7f17c82d11"}
            ],
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 201
    assert json["name"] == "New Component"
    assert json["comment"] == "A comment"
    assert len(json["elements"]) == 1

    assert len(json["id"]) == 36

    async with JournalEntryService.new(session) as journal_entries_service:
        entries = await journal_entries_service.list()
        assert len(entries) == 1
        entry = entries[0]
        assert entry.action == m.JournalAction.CREATED
        json["elements"][0]["transforms"] = []
        assert entry.value == json


async def test_components_create_with_scopes(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
) -> None:
    scopes = ["food", "textile", "veli"]
    response = await client.post(
        "/api/components",
        json={
            "name": "New Component",
            "elements": [
                {"amount": 0.91125, "material": "97c209ec-7782-5a29-8c47-af7f17c82d11"}
            ],
            "scopes": scopes,
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 201
    assert json["name"] == "New Component"
    assert json["scopes"] == scopes

    async with JournalEntryService.new(session) as journal_entries_service:
        entries = await journal_entries_service.list()
        assert len(entries) == 1
        entry = entries[0]
        assert entry.action == m.JournalAction.CREATED
        assert entry.table_name == m.Component.__tablename__

        json["elements"][0]["transforms"] = []
        assert entry.value == json


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
                {"amount": 0.91125, "material": "97c209ec-7782-5a29-8c47-af7f17c82d11"}
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
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
) -> None:
    async with JournalEntryService.new(session) as journal_entries_service:
        response = await client.patch(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            json={
                "name": "Name Changed",
                "comment": "Comment changed",
                "scopes": ["object", "food"],
            },
            headers=superuser_token_headers,
        )
        json = response.json()
        assert response.status_code == 200
        assert json["name"] == "Name Changed"
        assert json["comment"] == "Comment changed"
        assert json["elements"] is None
        assert json["scopes"] == ["object", "food"]

        entries = await journal_entries_service.list()
        assert len(entries) == 1
        entry = entries[0]
        assert entry.action == m.JournalAction.UPDATED
        assert entry.value == {
            "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            "name": "Name Changed",
            "comment": "Comment changed",
            "scopes": ["object", "food"],
        }

        response = await client.patch(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            json={"scopes": ["object"]},
            headers=superuser_token_headers,
        )
        json = response.json()
        assert response.status_code == 200
        assert json["scopes"] == ["object"]

        entries = await journal_entries_service.list()
        assert len(entries) == 2
        entry = entries[1]
        assert entry.action == m.JournalAction.UPDATED
        assert entry.value == {
            "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            "scopes": ["object"],
        }

        response = await client.patch(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            json={"scopes": ["invalid"]},
            headers=superuser_token_headers,
        )

        entries = await journal_entries_service.list()
        assert len(entries) == 2

        assert response.status_code == 400


async def test_components_delete(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
    user_token_headers: dict[str, str],
) -> None:
    async with JournalEntryService.new(session) as journal_entries_service:
        response = await client.delete(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            headers=user_token_headers,
        )
        assert response.status_code == 403

        entries = await journal_entries_service.list()
        assert len(entries) == 0

        response = await client.delete(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            headers=superuser_token_headers,
        )
        assert response.status_code == 204

        entries = await journal_entries_service.list()
        assert len(entries) == 1
        assert entries[0].action == "deleted"

        response = await client.get(
            "/api/components",
            headers=superuser_token_headers,
        )

        assert len(response.json()) == 6


async def test_components_bulk_update(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
) -> None:
    async with JournalEntryService.new(session) as journal_entries_service:
        json_content = [
            {
                "elements": [
                    {
                        "amount": 0.00022,
                        "material": "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    }
                ],
                "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                "name": "Pied 70 cm (plein bois)",
            },
            {
                "elements": [
                    {
                        "amount": 0.734063,
                        "material": "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
                    }
                ],
                "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973",
                "name": "Dossier plastique (PP)",
            },
            {
                "elements": [
                    {
                        "amount": 0.91125,
                        "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    }
                ],
                "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6",
                "name": "Assise plastique (PP)",
            },
            {
                "elements": [
                    {"amount": 0.89, "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b"}
                ],
                "name": "Test component",
            },
            {
                "elements": [
                    {
                        "amount": 1,
                        "material": "97c209ec-7782-5a29-8c47-af7f17c82d11",
                        "transforms": [
                            "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
                            "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                        ],
                    },
                    {
                        "amount": 1,
                        "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                        "transforms": [
                            "97c209ec-7782-5a29-8c47-af7f17c82d11",
                            "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
                        ],
                    },
                ],
                "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
                "name": "Tissu pour joli canapé",
                "comment": "Un commentaire",
                "scopes": ["food"],
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
        assert json[-1]["comment"] == "Un commentaire"
        assert json[-1]["scopes"] == ["food"]

        entries = await journal_entries_service.list()

        assert (
            len([entry for entry in entries if entry.action == m.JournalAction.DELETED])
            == 3
        )
        assert (
            len([entry for entry in entries if entry.action == m.JournalAction.UPDATED])
            == 4
        )
        assert (
            len([entry for entry in entries if entry.action == m.JournalAction.CREATED])
            == 1
        )

        # Remove everything

        response = await client.patch(
            "/api/components",
            json=[],
            headers=superuser_token_headers,
        )
        json = response.json()
        assert response.status_code == 200

        assert len(json) == 0
