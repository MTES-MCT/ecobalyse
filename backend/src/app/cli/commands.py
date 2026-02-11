from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast
from uuid import UUID

import anyio
import click
import msgspec
import orjson
from advanced_alchemy.filters import OrderBy
from advanced_alchemy.service.typing import (
    convert,
)
from advanced_alchemy.utils.fixtures import open_fixture_async
from app.config import get_settings
from app.config.app import alchemy, default_json_serializer
from app.db import models as m
from app.domain.accounts.deps import provide_users_service
from app.domain.accounts.schemas import (
    OrganizationCreate,
    OrganizationType,
    UserCreate,
)
from app.domain.accounts.services import UserService
from app.domain.components.deps import provide_components_service
from app.domain.components.schemas import (
    JsonComponent,
)
from app.domain.processes.deps import provide_processes_service
from rich import get_console
from sqlalchemy.orm import joinedload, selectinload
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
    organization: str,
    organization_type: OrganizationType,
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
            organization=OrganizationCreate(name=organization, type=organization_type),
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
    organization: str,
    organization_type: OrganizationType = OrganizationType.LOCAL_AUTHORITY,
    superuser: bool = False,
    is_active: bool = True,
) -> None:
    await _create_users(
        f"{email}/{first_name}/{last_name}",
        organization,
        organization_type,
        superuser,
        is_active,
    )


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
    "--organization-type",
    help="Organization of the new user",
    type=click.Choice(OrganizationType),
    required=False,
    show_default=False,
    default=OrganizationType.LOCAL_AUTHORITY,
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
    organization: str,
    organization_type: OrganizationType,
    superuser: bool,
) -> None:
    """Create multiple users."""

    console = get_console()

    console.rule("Create multiple users.")

    anyio.run(
        _create_users,
        cast("str", users),
        organization,
        organization_type,
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
    "--organization-type",
    help="Organization of the new user",
    type=click.Choice(OrganizationType),
    required=False,
    show_default=False,
    default=OrganizationType.LOCAL_AUTHORITY,
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
    organization: str,
    organization_type: OrganizationType,
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
        organization_type,
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


async def load_processes_fixtures(
    db_session, processes_service, processes_data: dict
) -> None:
    """Import/Synchronize Database Fixtures."""

    from structlog import get_logger

    logger = get_logger()

    user = await get_or_create_default_user(db_session)

    processes_fixtures_ids = []

    for process in processes_data:
        process["id"] = UUID(process["id"])
        process["owner"] = user
        processes_fixtures_ids.append(process["id"])

    existing_processes = await processes_service.list()
    existing_processes_ids = [process.id for process in existing_processes]

    processes_to_add = []
    processes_to_update = []
    processes_ids_to_delete = []

    for process_fixture in processes_data:
        if process_fixture["id"] not in existing_processes_ids:
            processes_to_add.append(process_fixture)
        else:
            processes_to_update.append(process_fixture)

    for existing_process in existing_processes:
        if existing_process.id not in processes_fixtures_ids:
            processes_ids_to_delete.append(existing_process.id)

    if processes_to_add:
        await processes_service.create_many(
            data=processes_to_add,
            auto_commit=True,
        )

    if processes_to_update:
        for process_to_update in processes_to_update:
            await processes_service.update(
                item_id=process_to_update["id"],
                data=process_to_update,
                auto_commit=True,
                auto_refresh=True,
                load=[
                    selectinload(m.Process.process_categories).options(
                        joinedload(m.ProcessCategory.processes, innerjoin=True),
                    ),
                ],
            )

    if processes_ids_to_delete:
        await processes_service.delete_many(
            item_ids=processes_ids_to_delete,
            auto_commit=True,
        )

    await logger.ainfo(f"Loaded {len(processes_data)} processes fixtures")
    await logger.ainfo(f"Added: {len(processes_to_add)}")
    await logger.ainfo(f"Updated: {len(processes_to_update)}")
    await logger.ainfo(f"Deleted: {len(processes_ids_to_delete)}")


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
        async with alchemy.get_session() as db_session:
            processes_service = await anext(provide_processes_service(db_session))
            await load_processes_fixtures(
                db_session, processes_service, components_data
            )

    console.rule("Loading processes file.")
    anyio.run(_load_processes_json, json_data)


async def dump_components(db_session, components_service) -> None:
    """Dump components JSON"""

    # Disable ruff check for True equality as this syntax in required by SQLAlchemy
    results = await components_service.list(
        m.Component.published == True,  # noqa: E712
        OrderBy(field_name="name", sort_order="asc"),
        uniquify=True,
    )

    components = convert(
        obj=results,
        type=list[JsonComponent],  # type: ignore[valid-type]
        from_attributes=True,
    )

    # Needed for converting non JSON types to JSON compatibles types using msgspec
    components_dict = msgspec.json.decode(default_json_serializer(components))

    print(json.dumps(components_dict, indent=2, ensure_ascii=False))


@click.group(
    name="json",
    invoke_without_command=False,
    help="Manage JSON extraction.",
)
@click.pass_context
def json_management_group(_: dict[str, Any]) -> None:
    """Manage JSON extraction."""


@json_management_group.command(
    name="dump-components", help="Extract components from the DB into a JSON file."
)
def dump_components_command() -> None:
    """Dump components JSON."""

    async def _dump_components() -> None:
        async with alchemy.get_session() as db_session:
            components_service = await anext(provide_components_service(db_session))
            await dump_components(db_session, components_service)

    anyio.run(_dump_components)
