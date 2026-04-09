from __future__ import annotations

import pytest
from app.db import models as m
from app.domain.contrib.schemas import ContribCreate, ContribResponse, GenericScope
from app.domain.contrib.services import format_pull_request_body
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload

pytestmark = pytest.mark.anyio


async def test_contrib_requires_authentication(client) -> None:
    response = await client.post(
        "/api/contrib/examples",
        json={
            "scope": "veli",
            "name": "Veli example",
            "description": "Veli example description",
            "query": {"components": []},
        },
    )
    assert response.status_code == 401


async def test_contrib_create_pull_request(
    client,
    monkeypatch,
    user_token_headers: dict[str, str],
) -> None:
    async def mock_create_contrib_pr(*, data, github_settings, user):
        assert data.scope == GenericScope.VELI
        assert data.name == "Veli example"
        assert "components" in data.query
        assert isinstance(github_settings.REPOSITORY, str)
        assert user.email == "user@example.com"
        return ContribResponse(
            branch_name="contrib/veli/test-contrib",
            pull_request_url="https://github.com/MTES-MCT/ecobalyse/pull/123",
        )

    monkeypatch.setattr(
        "app.domain.contrib.controllers.contrib.create_contrib_pr",
        mock_create_contrib_pr,
    )

    response = await client.post(
        "/api/contrib/examples",
        headers=user_token_headers,
        json={
            "scope": "veli",
            "name": "Veli example",
            "description": "Veli example description",
            "query": {"components": []},
        },
    )
    assert response.status_code == 201
    assert response.json() == {
        "branchName": "contrib/veli/test-contrib",
        "pullRequestUrl": "https://github.com/MTES-MCT/ecobalyse/pull/123",
    }


async def test_contrib_service_helpers_include_user_identity(
    session: AsyncSession,
) -> None:
    user = await session.scalar(
        select(m.User)
        .options(joinedload(m.User.profile))
        .where(m.User.email == "user@example.com")
    )
    assert user is not None

    body = format_pull_request_body(
        ContribCreate(
            description="Food2 example description",
            name="Food2 example",
            query={"components": []},
            scope=GenericScope.FOOD2,
        ),
        user,
    )

    # user identity checks
    assert "Example User" in body
    assert "Example business organization" in body
