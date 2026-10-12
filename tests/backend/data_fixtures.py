from __future__ import annotations

import datetime
from typing import TYPE_CHECKING, Any

import pytest

from app.domain.accounts.schemas import OrganizationCreate, OrganizationType

if TYPE_CHECKING:
    from litestar import Litestar
    from pytest import MonkeyPatch


pytestmark = pytest.mark.anyio


@pytest.fixture(name="app")
def fx_app(pytestconfig: pytest.Config, monkeypatch: MonkeyPatch) -> Litestar:
    """App fixture.

    Returns:
        An application instance, configured via plugin.
    """
    from app.asgi import create_app

    return create_app()


@pytest.fixture(name="raw_betauser")
def fx_raw_betauser() -> dict[str, Any]:
    """Unstructured user representations."""

    return {
        "id": "d4b534b3-6e6a-42f4-b278-d8145b3b5d59",
        "email": "beta@example.com",
        "name": "Beta User",
        "magic_link_token": "Beta_User_2!_token",
        "is_superuser": False,
        "is_betauser": True,
        "is_active": False,
        "terms_accepted": True,
        "first_name": "Beta",
        "last_name": "User",
        "organization": OrganizationCreate(
            type=OrganizationType.INDIVIDUAL,
        ),
    }


@pytest.fixture(name="raw_users")
def fx_raw_users(raw_betauser) -> list[dict[str, Any]]:
    """Unstructured user representations."""

    users = [
        {
            "id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "email": "superuser@example.com",
            "magic_link_token": "Test_Password1!_token",
            "is_superuser": True,
            "is_active": True,
            "terms_accepted": True,
            "first_name": "Super",
            "last_name": "User",
            "organization": OrganizationCreate(
                name="Super organization",
                type=OrganizationType.ASSOCIATION,
            ),
        },
        {
            "id": "503b826c-78a0-44d9-9122-50a162aad306",
            "email": "other_superuser@example.com",
            "magic_link_token": "Test_Password1!_token_other",
            "is_superuser": True,
            "is_active": True,
            "first_name": "Other Super",
            "last_name": "User",
            "organization": OrganizationCreate(
                name="Super organization",
                type=OrganizationType.ASSOCIATION,
            ),
        },
        {
            "id": "5ef29f3c-3560-4d15-ba6b-a2e5c721e4d2",
            "email": "user@example.com",
            "magic_link_token": "Test_Password2!_token",
            "is_superuser": False,
            "is_active": True,
            "first_name": "Example",
            "last_name": "User",
            "terms_accepted": True,
            "organization": OrganizationCreate(
                name="Example business organization",
                type=OrganizationType.BUSINESS,
                siren="901518415",
            ),
            "magic_link_sent_at": datetime.datetime.now(datetime.UTC),
        },
        {
            "id": "5ef29f3c-3560-4d15-ba6b-a2e5c721e999",
            "email": "test@test.com",
            "magic_link_token": "Test_Password3!_token",
            "is_superuser": False,
            "is_active": True,
            "first_name": "Test",
            "last_name": "User",
            "organization": OrganizationCreate(
                type=OrganizationType.INDIVIDUAL,
            ),
            "magic_link_sent_at": datetime.datetime.now(datetime.UTC)
            - datetime.timedelta(days=2),
        },
        {
            "id": "6ef29f3c-3560-4d15-ba6b-a2e5c721e4d3",
            "email": "another@example.com",
            "is_superuser": False,
            "is_active": True,
            "organization": OrganizationCreate(
                type=OrganizationType.INDIVIDUAL,
            ),
        },
        {
            "id": "7ef29f3c-3560-4d15-ba6b-a2e5c721e4e1",
            "email": "inactive@example.com",
            "name": "Inactive User",
            "magic_link_token": "Old_Password2!_token",
            "is_superuser": False,
            "is_active": False,
            "first_name": "Inactive",
            "last_name": "User",
            "organization": OrganizationCreate(
                type=OrganizationType.INDIVIDUAL,
            ),
        },
    ]
    users.append(raw_betauser)

    return users
