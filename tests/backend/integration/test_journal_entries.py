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
