import json as jsonp
import warnings
from typing import TYPE_CHECKING
from uuid import UUID

import pytest
from app.db import models as m
from app.domain.components.deps import provide_components_service
from app.domain.journal_entries.services import JournalEntryService
from sqlalchemy.ext.asyncio import (
    AsyncSession,
)

if TYPE_CHECKING:
    from httpx import AsyncClient

pytestmark = pytest.mark.anyio


async def test_components_api_create(
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
                {
                    "amount": 0.91125,
                    "material": "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    "transforms": ["d25636af-ab36-4857-a6d0-c66d1e7a281b"],
                }
            ],
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 201
    assert json["name"] == "New Component"
    assert json["comment"] == "A comment"
    assert len(json["elements"]) == 1
    assert json["elements"][0]["transforms"] == ["d25636af-ab36-4857-a6d0-c66d1e7a281b"]

    assert len(json["id"]) == 36

    async with JournalEntryService.new(session) as journal_entries_service:
        entries = await journal_entries_service.list()
        assert len(entries) == 8
        entry = entries[7]
        assert entry.action == m.JournalAction.CREATED
        assert entry.value == json


async def test_components_db_create(
    session: AsyncSession,
) -> None:
    json = [
        {
            "elements": [
                {
                    "amount": 0.42,
                    "material": "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    "transforms": ["d25636af-ab36-4857-a6d0-c66d1e7a281b"],
                }
            ],
            "id": "a3963ed9-410d-4f4a-adec-992a2b59277e",
            "name": "Test composant",
            "scopes": ["object"],
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
        },
        {
            "elements": [
                {
                    "amount": 29,
                    "material": "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    "transforms": ["d25636af-ab36-4857-a6d0-c66d1e7a281b"],
                }
            ],
            "id": "c8d08b9d-c150-4441-a4f7-3f15c59e982c",
            "name": "Test composant 2",
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "scopes": ["object"],
        },
    ]

    with warnings.catch_warnings():
        warnings.simplefilter("error")
        components_service = await anext(provide_components_service(session))
        results = await components_service.create_many(data=json, auto_commit=True)
        assert len(results) == 2

        assert results[0].elements[0].transforms == [
            UUID("d25636af-ab36-4857-a6d0-c66d1e7a281b")
        ]


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
            "published": True,
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 201
    assert json["name"] == "New Component"
    assert json["scopes"] == scopes
    assert json["published"]

    async with JournalEntryService.new(session) as journal_entries_service:
        entries = await journal_entries_service.list()
        assert len(entries) == 8
        entry = entries[7]
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
    json = response.json()
    assert len(json) == 7

    response = await client.get(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
    )
    assert response.status_code == 200
    assert response.json() == {
        "comment": None,
        "elements": [
            {
                "amount": 1.0,
                "material": "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
                "transforms": [
                    "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                ],
            },
        ],
        "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        "name": "Tissu pour canapé",
        "published": False,
        "scopes": [
            "textile",
        ],
    }


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

        assert not json["published"]

        response = await client.patch(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            json={
                "name": "Name Changed",
                "comment": "Comment changed",
                "scopes": ["object", "food"],
                "published": True,
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

        assert response.status_code == 200

        json = response.json()

        assert json["name"] == "Name Changed"
        assert json["comment"] == "Comment changed"
        assert json["scopes"] == ["object", "food"]
        assert json["published"]
        assert jsonp.dumps(json["elements"]) == jsonp.dumps(
            [
                {
                    "amount": 2.0,
                    "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
                }
            ]
        )

        response = await client.patch(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            json={
                "elements": [
                    {
                        "amount": 3,
                        "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
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
        assert jsonp.dumps(json["elements"]) == jsonp.dumps(
            [
                {
                    "amount": 3.0,
                    "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    "transforms": [],
                }
            ]
        )

        entries = await journal_entries_service.list()
        assert len(entries) == 9
        entry = entries[7]
        assert entry.action == m.JournalAction.UPDATED
        assert jsonp.dumps(entry.value) == jsonp.dumps(
            {
                "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
                "name": "Name Changed",
                "scopes": ["object", "food"],
                "comment": "Comment changed",
                "elements": [
                    {
                        "amount": 2.0,
                        "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                        "transforms": ["97c209ec-7782-5a29-8c47-af7f17c82d11"],
                    }
                ],
                "published": True,
            }
        )

        response = await client.patch(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            json={"scopes": ["object"]},
            headers=superuser_token_headers,
        )
        json = response.json()
        assert response.status_code == 200
        assert json["scopes"] == ["object"]
        assert json["elements"] == []

        entries = await journal_entries_service.list()
        assert len(entries) == 10
        entry = entries[9]
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
        assert len(entries) == 10

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
        assert len(entries) == 7

        response = await client.delete(
            "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            headers=superuser_token_headers,
        )
        assert response.status_code == 204

        entries = await journal_entries_service.list()
        assert len(entries) == 8
        assert entries[7].action == "deleted"

        response = await client.get(
            "/api/components",
            headers=superuser_token_headers,
        )

        assert len(response.json()) == 6


async def test_components_preserve_transformations_order(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
) -> None:
    # Creates a component with two transforms
    # and asserts the returned value preserves the transforms list order
    response = await client.post(
        "/api/components",
        json={
            "name": "New Component",
            "comment": "A comment",
            "elements": [
                {
                    "amount": 0.91125,
                    "material": "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    "transforms": [
                        "97c209ec-7782-5a29-8c47-af7f17c82d11",
                        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    ],
                }
            ],
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 201
    assert json["elements"][0]["transforms"] == [
        "97c209ec-7782-5a29-8c47-af7f17c82d11",
        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
    ]

    # Creates an identical component with the inverted transforms
    # and asserts the returned value preserves the transforms list order

    response = await client.post(
        "/api/components",
        json={
            "name": "New Component",
            "comment": "A comment",
            "elements": [
                {
                    "amount": 0.91125,
                    "material": "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    "transforms": [
                        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                        "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    ],
                }
            ],
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 201
    assert json["elements"][0]["transforms"] == [
        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
        "97c209ec-7782-5a29-8c47-af7f17c82d11",
    ]


async def test_components_preserve_transformations_order_on_update(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
) -> None:
    # NB: this test seems redundant with the previous one
    # (test_components_preserve_transformations_order), but before implementing
    # the ordering, the previous one was already successful, probably because
    # on creation, the default ordering of PG was the expected one.

    # Updates a component, passing it two transforms
    # and asserts the returned value preserves the transforms list order

    response = await client.patch(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        json={
            "name": "Name Changed",
            "comment": "Comment changed",
            "scopes": ["object", "food"],
            "published": True,
            "elements": [
                {
                    "amount": 2,
                    "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    "transforms": [
                        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                        "97c209ec-7782-5a29-8c47-af7f17c82d11",
                    ],
                }
            ],
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 200
    assert json["elements"][0]["transforms"] == [
        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
        "97c209ec-7782-5a29-8c47-af7f17c82d11",
    ]

    # Updates the component again, passing it the two transforms in an inverted order
    # and asserts the returned value preserves the transforms list order

    response = await client.patch(
        "/api/components/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
        json={
            "name": "Name Changed",
            "comment": "Comment changed",
            "scopes": ["object", "food"],
            "published": True,
            "elements": [
                {
                    "amount": 2,
                    "material": "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    "transforms": [
                        "97c209ec-7782-5a29-8c47-af7f17c82d11",
                        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
                    ],
                }
            ],
        },
        headers=superuser_token_headers,
    )
    json = response.json()
    assert response.status_code == 200
    assert json["elements"][0]["transforms"] == [
        "97c209ec-7782-5a29-8c47-af7f17c82d11",
        "d25636af-ab36-4857-a6d0-c66d1e7a281b",
    ]
