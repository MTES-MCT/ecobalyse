from typing import TYPE_CHECKING, Any
from uuid import UUID

import pytest
from app.cli.commands import load_processes_fixtures
from app.domain.processes.deps import provide_processes_service
from sqlalchemy.ext.asyncio import (
    AsyncSession,
)

if TYPE_CHECKING:
    from httpx import AsyncClient
    from sqlalchemy.ext.asyncio import AsyncSession

pytestmark = pytest.mark.anyio


async def test_load_processes(
    client: "AsyncClient",
    user_token_headers: dict[str, str],
    session: AsyncSession,
    raw_processes: list[dict[str, Any]],
) -> None:
    processes_service = await anext(provide_processes_service(session))
    processes = await processes_service.list()
    initial_processes_nb = len(processes)

    new_process = {
        "activityName": "test",
        "categories": ["transformation"],
        "comment": "",
        "displayName": "Process de test",
        "elecMJ": 1.61,
        "heatMJ": 10.74,
        "id": UUID("216e33b3-f607-41e0-b047-cd42db763c5b"),
        "impacts": {
            "acd": 1,
            "cch": 2,
            "ecs": 2026.16,
            "etf": 1,
            "etf-c": 944.0,
            "fru": 2,
            "fwe": 3,
            "htc": 3,
            "htc-c": 1.11e-11,
            "htn": 2,
            "htn-c": 2.03e-8,
            "ior": 2,
            "ldu": 5,
            "mru": 4,
            "ozd": 2,
            "pco": 7,
            "pma": 7,
            "swe": 7,
            "tre": 5,
            "wtu": 5,
        },
        "location": "GLO",
        "massPerUnit": None,
        "scopes": ["textile"],
        "source": "Custom",
        "unit": "kg",
        "waste": 0,
    }

    # We add a new process
    raw_processes.append(new_process)

    await load_processes_fixtures(session, processes_service, raw_processes)

    response = await client.get(
        "/api/processes/",
        headers=user_token_headers,
    )
    assert response.status_code == 200
    processes = response.json()

    assert initial_processes_nb + 1 == len(processes)

    # We update a process
    raw_processes[-1]["scopes"] = ["textile", "food"]
    raw_processes[-1]["displayName"] = "New test"

    await load_processes_fixtures(session, processes_service, raw_processes)
    await session.commit()

    processes = await processes_service.list()

    assert initial_processes_nb + 1 == len(processes)

    response = await client.get(
        "/api/processes/" + str(raw_processes[-1]["id"]),
        headers=user_token_headers,
    )
    assert response.status_code == 200
    json_response = response.json()

    assert json_response["displayName"] == "New test"
    assert json_response["scopes"] == ["textile", "food"]

    # We remove a process
    last_process_id = raw_processes[-1]["id"]
    raw_processes.pop()

    await load_processes_fixtures(session, processes_service, raw_processes)
    await session.commit()

    response = await client.get(
        "/api/processes/",
        headers=user_token_headers,
    )
    assert response.status_code == 200
    processes = response.json()

    assert initial_processes_nb == len(processes)

    response = await client.get(
        "/api/processes/" + str(last_process_id),
        headers=user_token_headers,
    )
    assert response.status_code == 404
