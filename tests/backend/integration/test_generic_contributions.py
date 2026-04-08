from __future__ import annotations

import pytest
from app.db import models as m
from app.domain.generic_contributions.schemas import (
    GenericContributionCreate,
    GenericScope,
)
from app.domain.generic_contributions.services import (
    format_pull_request_body,
)
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload

pytestmark = pytest.mark.anyio


async def test_generic_contributions_requires_authentication(client) -> None:
    response = await client.post(
        "/api/generic/examples/contributions",
        json={
            "scope": "veli",
            "name": "Exemple test",
            "description": "Description test",
            "query": {"components": []},
        },
    )
    assert response.status_code == 401


async def test_generic_contributions_create_pull_request(
    client,
    monkeypatch,
    user_token_headers: dict[str, str],
) -> None:
    async def mock_create_generic_contribution_pr(*, data, user):
        assert data.scope == GenericScope.VELI
        assert data.name == "Exemple test"
        assert "components" in data.query
        assert user.email == "user@example.com"
        return (
            "contrib/veli/test-contrib",
            "https://github.com/MTES-MCT/ecobalyse/pull/123",
        )

    monkeypatch.setattr(
        "app.domain.generic_contributions.controllers.contribution.create_generic_contribution_pr",
        mock_create_generic_contribution_pr,
    )

    response = await client.post(
        "/api/generic/examples/contributions",
        headers=user_token_headers,
        json={
            "scope": "veli",
            "name": "Exemple test",
            "description": "Description test",
            "query": {"components": []},
        },
    )
    assert response.status_code == 201
    assert response.json() == {
        "branchName": "contrib/veli/test-contrib",
        "pullRequestUrl": "https://github.com/MTES-MCT/ecobalyse/pull/123",
    }


async def test_generic_contributions_service_helpers_include_user_identity(
    session: AsyncSession,
) -> None:
    user = await session.scalar(
        select(m.User)
        .options(joinedload(m.User.profile))
        .where(m.User.email == "user@example.com")
    )
    assert user is not None

    body = format_pull_request_body(
        GenericContributionCreate(
            description="Description test",
            name="Mon exemple",
            query={"components": []},
            scope=GenericScope.FOOD2,
        ),
        user,
    )

    assert "food2" in body
    assert "Example User" in body
    assert "Example business organization" in body
    assert '"components": []' in body
