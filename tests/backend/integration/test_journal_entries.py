from typing import TYPE_CHECKING, Any
from uuid import uuid4

import pytest
from app.db import models as m
from app.db.models import Process
from app.domain.accounts.services import UserService
from app.domain.journal_entries.services import JournalEntryService
from app.domain.processes.services import ProcessService
from sqlalchemy.ext.asyncio import (
    AsyncSession,
)

if TYPE_CHECKING:
    from httpx import AsyncClient

pytestmark = pytest.mark.anyio


async def test_processes_journal(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
    other_superuser_token_headers: dict[str, str],
    raw_processes: list[Process | dict[str, Any]],
) -> None:
    async with (
        ProcessService.new(session) as processes_services,
        UserService.new(session) as users_service,
    ):
        raw_process = raw_processes[0]
        raw_process["id"] = uuid4()

        user = await users_service.get_one_or_none(email="superuser@example.com")
        raw_process["owner"] = user

        await processes_services.create(raw_process, auto_commit=True)

        response = await client.get("/api/journal", headers=superuser_token_headers)
        json_response = response.json()
        assert response.status_code == 200

        assert len(json_response) == 1

        response = await client.get(
            "/api/journal/process", headers=superuser_token_headers
        )
        json_response = response.json()
        assert response.status_code == 200

        assert len(json_response) == 1
        assert json_response[0]["value"]["sourceId"] == raw_process["sourceId"]
        assert json_response[0]["value"]["impacts"] == raw_process["impacts"]


async def test_components_journal(
    client: "AsyncClient",
    session: AsyncSession,
    superuser_token_headers: dict[str, str],
    other_superuser_token_headers: dict[str, str],
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
                "scopes": ["food"],
            },
        ]

        response = await client.patch(
            "/api/components",
            json=json_content,
            headers=superuser_token_headers,
        )
        assert response.status_code == 200

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

        json_content = [
            {
                "elements": [
                    {
                        "amount": 0.00022,
                        "material": "07e9e916-e02b-45e2-a298-2b5084de6242",
                    }
                ],
                "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
                "name": "Pied 70 cm (plein bois) - Test",
            },
        ]

        # Ensure that we have entries with different users
        response = await client.patch(
            "/api/components",
            json=json_content,
            headers=other_superuser_token_headers,
        )

        # Remove everything

        response = await client.patch(
            "/api/components",
            json=[],
            headers=superuser_token_headers,
        )
        assert response.status_code == 200

        entries = await journal_entries_service.list()
        assert len(entries) == 14

        response = await client.get("/api/journal", headers=superuser_token_headers)
        json_response = response.json()
        assert response.status_code == 200

        assert len(json_response) == 14

        response = await client.get(
            "/api/journal/component", headers=superuser_token_headers
        )
        json_response = response.json()
        assert response.status_code == 200

        assert len(json_response) == 14

        response = await client.get(
            "/api/journal/unknown", headers=superuser_token_headers
        )
        json_response = response.json()
        assert response.status_code == 200

        assert len(json_response) == 0

        response = await client.get(
            "/api/journal/component/8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            headers=superuser_token_headers,
        )
        json_response = response.json()
        assert response.status_code == 200

        assert len(json_response) == 2

        assert json_response[0]["action"] == m.JournalAction.DELETED
        assert json_response[1]["action"] == m.JournalAction.UPDATED
