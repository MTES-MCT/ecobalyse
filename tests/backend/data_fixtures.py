from __future__ import annotations

import datetime
from typing import TYPE_CHECKING, Any
from uuid import UUID

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


@pytest.fixture(name="raw_processes")
def fx_raw_processes() -> list[dict[str, Any]]:
    """Unstructured processes representations."""

    return [
        {
            "activityName": "This process is not linked to a Brightway activity",
            "categories": ["transformation"],
            "comment": "corr2 : inventaires enrichis (substances chimiques)\nAncien identifiant (12/2024): ecobalyse-impression-pigmentaire.",
            "massPerUnit": None,
            "displayName": "Impression (pigmentaire)",
            "elecMJ": 1.61,
            "heatMJ": 10.74,
            "id": UUID("97c209ec-7782-5a29-8c47-af7f17c82d11"),
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
            "scopes": ["textile"],
            "source": "Custom",
            "unit": "kg",
            "waste": 0,
        },
        {
            "activityName": "_22 Vegetable and animal oils and fats, EU27",
            "categories": ["material"],
            "comment": "Location:  Unspecified\nTechnology:  Unspecified\nTime period:  Unspecified",
            "massPerUnit": None,
            "displayName": "_22 Vegetable and animal oils and fats, EU27",
            "elecMJ": 0.0,
            "heatMJ": 0.0,
            "id": UUID("af42fc20-e3ec-5b99-9b9c-83ba6735e597"),
            "impacts": {
                "acd": 0.01570549584,
                "cch": 2.107576844,
                "ecs": 102.5847006401981,
                "etf": 0.46898182729,
                "etf-c": 0.49422404998,
                "fru": 0.0,
                "fwe": 0.0,
                "htc": 0.0,
                "htc-c": 0.0,
                "htn": 5.963651765e-10,
                "htn-c": 1.1052066718e-9,
                "ior": 0.0,
                "ldu": 0.0,
                "mru": 0.0,
                "ozd": 0.0,
                "pco": 0.006508274766,
                "pma": 9.50346722e-8,
                "swe": 0.001544927202,
                "tre": 0.0580423763,
                "wtu": 0.0,
            },
            "location": "EU27",
            "scopes": [],
            "source": "forwast",
            "unit": "kg",
            "waste": 0.0,
        },
        {
            "activityName": "test",
            "categories": ["material", "material_type:organic_fibers"],
            "comment": "Location:  Unspecified\nTechnology:  Unspecified\nTime period:  Unspecified",
            "massPerUnit": None,
            "displayName": "Test process",
            "elecMJ": 0.0,
            "heatMJ": 0.0,
            "id": UUID("d25636af-ab36-4857-a6d0-c66d1e7a281b"),
            "impacts": {
                "acd": 0.01570549584,
                "cch": 2.107576844,
                "ecs": 102.5847006401981,
                "etf": 0.46898182729,
                "etf-c": 0.49422404998,
                "fru": 0.0,
                "fwe": 0.0,
                "htc": 0.0,
                "htc-c": 0.0,
                "htn": 5.963651765e-10,
                "htn-c": 1.1052066718e-9,
                "ior": 0.0,
                "ldu": 0.0,
                "mru": 0.0,
                "ozd": 0.0,
                "pco": 0.006508274766,
                "pma": 9.50346722e-8,
                "swe": 0.001544927202,
                "tre": 0.0580423763,
                "wtu": 0.0,
            },
            "location": None,
            "scopes": [],
            "source": "forwast",
            "unit": "kg",
            "waste": 0.0,
        },
    ]


@pytest.fixture(name="raw_components")
def fx_raw_components() -> list[dict[str, Any]]:
    """Unstructured components representations."""

    return [
        {
            "id": "64fa65b3-c2df-4fd0-958b-83965bd6aa08",
            "name": "Pied 70 cm (plein bois)",
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "scopes": [],
        },
        {
            "id": "ad9d7f23-076b-49c5-93a4-ee1cd7b53973",
            "name": "Dossier plastique (PP)",
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "scopes": [],
        },
        {
            "id": "eda5dd7e-52e4-450f-8658-1876efc62bd6",
            "name": "Assise plastique (PP)",
            "scopes": [],
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
        },
        {
            "id": "6f8d1621-324a-4c00-abe3-f90813d878d2",
            "name": "Pied 90 cm (plein bois)",
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "scopes": [],
        },
        {
            "id": "3d1ba21f-a139-4e1f-8192-082327ad855e",
            "name": "Plateau 200x100 (chêne)",
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "scopes": [],
        },
        {
            "id": "190276e9-5b90-42d6-8fbd-bc7ddfd4c960",
            "name": "Cadre plastique",
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "scopes": [],
        },
        {
            "id": "8ca2ca05-8aec-4121-acaa-7cdcc03150a9",
            "name": "Tissu pour canapé",
            "scopes": ["textile"],
            "elements": [
                {
                    "amount": 1,
                    "material": "af42fc20-e3ec-5b99-9b9c-83ba6735e597",
                    "transforms": ["d25636af-ab36-4857-a6d0-c66d1e7a281b"],
                }
            ],
            "owner_id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
        },
    ]


@pytest.fixture(name="raw_users")
def fx_raw_users() -> list[dict[str, Any]]:
    """Unstructured user representations."""

    return [
        {
            "id": "97108ac1-ffcb-411d-8b1e-d9183399f63b",
            "email": "superuser@example.com",
            "magic_link_token": "Test_Password1!_token",
            "is_superuser": True,
            "is_active": True,
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
            "magic_link_sent_at": datetime.datetime.now(datetime.timezone.utc),
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
            "magic_link_sent_at": datetime.datetime.now(datetime.timezone.utc)
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
