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
from app.domain.components.deps import provide_components_service
from app.domain.processes.deps import provide_processes_service
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


async def _create_users(
    users_list_string: str,
    organization: str | None,
    superuser: bool = False,
    is_active: bool = True,
) -> None:
    entries: list[str] = users_list_string.split(",")
    users_to_upsert = []
    for user in entries:
        parts = user.split("/")
        email = parts[0]
        first_name = parts[1]
        last_name = parts[2]

        user_in = UserCreate(
            email=email,
            first_name=first_name,
            last_name=last_name,
            organization=OrganizationCreate(
                name=organization, type=OrganizationType.LOCAL_AUTHORITY
            ),
            is_superuser=superuser,
            is_active=is_active,
            terms_accepted=True,
        )
        users_to_upsert.append(user_in.to_dict())

    console = get_console()

    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))
        user = await users_service.upsert_many(
            data=users_to_upsert, auto_commit=True, match_fields=["email"]
        )
        console.print(f"Users upserted: {[user['email'] for user in users_to_upsert]}")


async def _create_user(
    email: str,
    first_name: str,
    last_name: str,
    organization: str | None,
    superuser: bool = False,
    is_active: bool = True,
) -> None:
    obj_in = UserCreate(
        email=email,
        first_name=first_name,
        last_name=last_name,
        organization=OrganizationCreate(
            name=organization, type=OrganizationType.LOCAL_AUTHORITY
        ),
        is_superuser=superuser,
        is_active=is_active,
        terms_accepted=True,
    )

    console = get_console()

    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))
        user = await users_service.upsert(
            data=obj_in.to_dict(), auto_commit=True, match_fields=["email"]
        )
        console.print(f"User upserted: {user.email}")


@user_management_group.command(
    name="create-default-user", help="Create the default user"
)
@click.option(
    "--first-name",
    help="First name of the new user",
    type=click.STRING,
    required=False,
    show_default=False,
    default="Admin",
)
@click.option(
    "--last-name",
    help="Last name of the new user",
    type=click.STRING,
    required=False,
    show_default=False,
    default="Ecobalyse",
)
@click.option(
    "--organization",
    help="Organization of the new user",
    type=click.STRING,
    required=False,
    show_default=False,
    default="Ecobalyse",
)
def create_default_user(
    first_name: str,
    last_name: str,
    organization: str | None,
) -> None:
    """Create the default user of the app."""

    console = get_console()

    console.rule("Create the default user of the app.")
    superuser = False

    settings = get_settings()

    anyio.run(
        _create_user,
        cast("str", settings.app.DEFAULT_USER_EMAIL),
        cast("str", first_name),
        cast("str", last_name),
        organization,
        cast("bool", superuser),
        # Deactivate default user
        False,
    )


# Here is the format
# email@test.com/Firstname/Lastname,other@email.com/Other first name/Other name
@user_management_group.command(
    name="create-users", help="Create multiple users from a string"
)
@click.option(
    "--users",
    help="Users to be created, format is: email@test.com/Firstname/Lastname,other@email.com/Other first name/Other name",
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
    help="Should create super users",
    type=click.BOOL,
    default=False,
    required=False,
    show_default=False,
    is_flag=True,
)
def create_users(
    users: str,
    organization: str | None,
    superuser: bool | None,
) -> None:
    """Create multiple users."""

    console = get_console()

    console.rule("Create multiple users.")

    anyio.run(
        _create_users,
        cast("str", users),
        organization,
        cast("bool", superuser),
    )


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


async def get_or_create_default_user(db_session):
    logger = get_logger()

    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))

        settings = get_settings()
        user = await users_service.get_one_or_none(
            email=settings.app.DEFAULT_USER_EMAIL
        )
        if not user:
            await logger.awarning(
                f"default super user {settings.app.DEFAULT_USER_EMAIL} not found, creating it"
            )

            await _create_user(
                email=settings.app.DEFAULT_USER_EMAIL,
                first_name="Admin",
                last_name="Ecobalyse",
                organization="Ecobalyse",
                # Not super user
                superuser=False,
                # Deactivate default user
                is_active=False,
            )

            user = await users_service.get_one_or_none(
                email=settings.app.DEFAULT_USER_EMAIL
            )

        return user


async def load_components_fixtures(components_data: dict) -> None:
    """Import/Synchronize Database Fixtures."""

    logger = get_logger()

    async with alchemy.get_session() as db_session:
        user = await get_or_create_default_user(db_session)

        components_service = await anext(provide_components_service(db_session))

        for component in components_data:
            component["owner"] = user

        await components_service.create_many(
            data=components_data,
            auto_commit=True,
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

    from structlog import get_logger

    logger = get_logger()

    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))

        settings = get_settings()
        user = await users_service.get_one_or_none(
            email=settings.app.DEFAULT_USER_EMAIL
        )
        if not user:
            await logger.awarning(
                f"default super user {settings.app.DEFAULT_USER_EMAIL} not found, creating it"
            )

            await _create_user(
                email=settings.app.DEFAULT_USER_EMAIL,
                first_name="Admin",
                last_name="Ecobalyse",
                organization="Ecobalyse",
                # Not super user
                superuser=False,
                # Deactivate default user
                is_active=False,
            )

            user = await users_service.get_one_or_none(
                email=settings.app.DEFAULT_USER_EMAIL
            )

        processes_service = await anext(provide_processes_service(db_session))

        for process in processes_data:
            process["owner"] = user

        await processes_service.create_many(
            data=processes_data,
            auto_commit=True,
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


@click.group(
    name="data",
    invoke_without_command=False,
    help="Manage data operations (migrations, debug, …).",
)
@click.pass_context
def data_management_group(_: dict[str, Any]) -> None:
    """Manage data migrations."""


@data_management_group.command(
    name="migrate-elements", help="Migrate existing elements."
)
def migrate_elements() -> None:
    """Migrate existing elements"""

    console = get_console()

    console.rule("Migrating elements")

    async def _migrate() -> None:
        async with alchemy.get_session() as db_session:
            await _migrate_elements(db_session)

    anyio.run(_migrate)


async def _migrate_elements(db_session) -> None:
    components_service = await anext(provide_components_service(db_session))

    components = await components_service.list()

    user = await get_or_create_default_user(db_session)

    for component in components:
        # Don’t try to add elements to components that already have some
        if component.elements == []:
            if component.elements_json:
                await components_service.update(
                    item_id=component.id,
                    data={
                        "id": component.id,
                        "owner_id": user.id,
                        "elements": component.elements_json,
                    },
                    auto_commit=True,
                )
