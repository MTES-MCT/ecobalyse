from __future__ import annotations

from pathlib import Path
from typing import Any, cast

import anyio
import click
import orjson
from advanced_alchemy.utils.fixtures import open_fixture_async
from app.config import get_settings
from app.config.app import alchemy
from app.domain.accounts.deps import provide_users_service
from app.domain.accounts.schemas import (
    OrganizationCreate,
    OrganizationType,
    UserCreate,
)
from app.domain.accounts.services import UserService
from app.domain.components.services import ComponentService
from rich import get_console
from structlog import get_logger


@click.group(
    name="users",
    invoke_without_command=False,
    help="Manage application users and roles.",
)
@click.pass_context
def user_management_group(_: dict[str, Any]) -> None:
    """Manage application users."""


async def load_database_fixtures() -> None:
    """Import/Synchronize Database Fixtures."""

    settings = get_settings()
    logger = get_logger()
    fixtures_path = Path(settings.db.FIXTURE_PATH)
    async with UserService.new(
        config=alchemy,
    ) as service:
        fixture_data = await open_fixture_async(fixtures_path, "user")
        await service.create_many(data=fixture_data, auto_commit=True)
        await logger.ainfo("loaded users")


@user_management_group.command(name="create-user", help="Create a user")
@click.option(
    "--email",
    help="Email of the new user",
    type=click.STRING,
    required=False,
    show_default=False,
)
@click.option(
    "--first-name",
    help="First name of the new user",
    type=click.STRING,
    required=True,
    show_default=False,
)
@click.option(
    "--last-name",
    help="Last name of the new user",
    type=click.STRING,
    required=True,
    show_default=False,
)
@click.option(
    "--organization",
    help="Organization of the new user",
    type=click.STRING,
    required=False,
    show_default=False,
    default="Ecobalyse",
)
@click.option(
    "--superuser",
    help="Is a superuser",
    type=click.BOOL,
    default=False,
    required=False,
    show_default=False,
    is_flag=True,
)
def create_user(
    email: str,
    first_name: str,
    last_name: str,
    organization: str | None,
    superuser: bool | None,
) -> None:
    """Create a user."""

    console = get_console()

    async def _create_user(
        email: str,
        first_name: str,
        last_name: str,
        organization: str | None,
        superuser: bool = False,
    ) -> None:
        obj_in = UserCreate(
            email=email,
            first_name=first_name,
            last_name=last_name,
            organization=OrganizationCreate(
                name=organization, type=OrganizationType.LOCAL_AUTHORITY
            ),
            is_superuser=superuser,
            terms_accepted=True,
        )
        async with alchemy.get_session() as db_session:
            users_service = await anext(provide_users_service(db_session))
            user = await users_service.create(data=obj_in.to_dict(), auto_commit=True)
            console.print(f"User created: {user.email}")

    console.rule("Create a new application user.")
    email = email or click.prompt("Email")
    superuser = superuser or click.prompt(
        "Create as superuser?", show_default=True, type=click.BOOL
    )

    anyio.run(
        _create_user,
        cast("str", email),
        cast("str", first_name),
        cast("str", last_name),
        organization,
        cast("bool", superuser),
    )


@click.group(
    name="fixtures",
    invoke_without_command=False,
    help="Manage application fixtures.",
)
@click.pass_context
def fixtures_management_group(_: dict[str, Any]) -> None:
    """Manage application components."""


@fixtures_management_group.command(name="load-test", help="Create fixtures for tests")
def load_test_fixtures() -> None:
    """Load fixtures for tests."""

    console = get_console()

    async def _load_test_fixtures() -> None:
        await load_database_fixtures()

    console.rule("Loading test fixtures.")
    anyio.run(_load_test_fixtures)


async def load_components_fixtures(components_data: dict) -> None:
    """Import/Synchronize Database Fixtures."""

    logger = get_logger()
    async with ComponentService.new(config=alchemy, uniquify=True) as service:
        await service.upsert_many(
            match_fields=["name"], data=components_data, auto_commit=True, uniquify=True
        )
        await logger.ainfo("loaded components fixtures")


@fixtures_management_group.command(
    name="load-components", help="Load components from JSON file."
)
@click.argument(
    "json_file",
    type=click.File("rb"),
)
def load_components_json(json_file: click.File) -> None:
    """Load components json.

    Args:
        component json file (Path): The path to the JSON file to load.
    """

    console = get_console()

    json_data = orjson.loads(json_file.read())

    async def _load_components_json(components_data) -> None:
        await load_components_fixtures(components_data)

    console.rule("Loading components file.")
    anyio.run(_load_components_json, json_data)


async def load_processes_fixtures(processes_data: dict) -> None:
    """Import/Synchronize Database Fixtures."""

    from app.domain.processes.services import ProcessService
    from structlog import get_logger

    logger = get_logger()
    async with ProcessService.new(config=alchemy, uniquify=True) as service:
        await service.upsert_many(
            match_fields=["name"], data=processes_data, auto_commit=True, uniquify=True
        )
        await logger.ainfo("loaded processes fixtures")


@fixtures_management_group.command(
    name="load-processes", help="Load processes from JSON file."
)
@click.argument(
    "json_file",
    type=click.File("rb"),
)
def load_processes_json(json_file: click.File) -> None:
    """Load processes json.

    Args:
        processes json file (Path): The path to the JSON file to load.
    """

    console = get_console()

    json_data = orjson.loads(json_file.read())

    async def _load_processes_json(components_data) -> None:
        await load_processes_fixtures(components_data)

    console.rule("Loading processes file.")
    anyio.run(_load_processes_json, json_data)
