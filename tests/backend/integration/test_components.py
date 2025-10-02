import json as jsonp
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
        response = await client.get(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        )
        assert response.status_code == 200
        json = response.json()

        assert jsonp.dumps(json["elements"]) == jsonp.dumps(
            [
                {
                    "amount": 1.0,
                    "material": "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
                    "transforms": ["d25636af-ab36-4857-a6d0-c66d1e7a281b"],
                }
            ]
        )

        response = await client.patch(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            json={
                "name": "Name Changed",
                "comment": "Comment changed",
                "scopes": ["object", "food"],
                "elements": [
                    {
                        "amount": 2,
                        "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                        "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
                    }
                ],
            },
            headers=superuser_token_headers,
        )
        json = response.json()

        response = await client.get(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        )
        assert response.status_code == 200

        json = response.json()

        assert json["name"] == "Name Changed"
        assert json["comment"] == "Comment changed"
        assert json["scopes"] == ["object", "food"]
        assert jsonp.dumps(json["elements"]) == jsonp.dumps(
            [
                {
                    "amount": 2.0,
                    "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
                }
            ]
        )

        _ = await journal_entries_service.list()
        # assert len(entries) == 1
        # entry = entries[0]
        # assert entry.action == m.JournalAction.UPDATED
        # assert jsonp.dumps(entry.value) == jsonp.dumps(
        #     {
        #         "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        #         "name": "Name Changed",
        #         "scopes": ["object", "food"],
        #         "comment": "Comment changed",
        #         "elements": [
        #             {
        #                 "amount": 1.0,
        #                 "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
        #                 "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
        #             }
        #         ],
        #     }
        # )
        #
        # response = await client.patch(
        #     "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        #     json={"scopes": ["object"]},
        #     headers=superuser_token_headers,
        # )
        # json = response.json()
        # assert response.status_code == 200
        # assert json["scopes"] == ["object"]
        # assert jsonp.dumps(json["elements"]) == jsonp.dumps(
        #     [
        #         {
        #             "amount": 1.0,
        #             "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
        #             "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
        #         }
        #     ]
        # )
        #
        # entries = await journal_entries_service.list()
        # assert len(entries) == 2
        # entry = entries[1]
        # assert entry.action == m.JournalAction.UPDATED
        # assert entry.value == {
        #     "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        #     "scopes": ["object"],
        # }
        #
        # response = await client.patch(
        #     "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        #     json={"scopes": ["invalid"]},
        #     headers=superuser_token_headers,
        # )
        #
        # entries = await journal_entries_service.list()
        # assert len(entries) == 2
        #
        # assert response.status_code == 400


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
