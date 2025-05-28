from __future__ import annotations

from datetime import datetime
from pathlib import Path
from typing import Any, cast

import anyio
import click
import orjson
from advanced_alchemy.utils.fixtures import open_fixture_async
from advanced_alchemy.utils.text import slugify
from rich import get_console
from sqlalchemy import select
from sqlalchemy.orm import load_only
from structlog import get_logger

from app.config import get_settings
from app.config.app import alchemy
from app.db.models import Role, UserRole
from app.domain.accounts.deps import provide_users_service
from app.domain.accounts.schemas import (
    ApiTokenCreate,
    OrganizationCreate,
    OrganizationType,
    UserCreate,
    UserDjangoCreate,
)
from app.domain.accounts.services import RoleService, TokenService
from app.domain.components.services import ComponentService
from app.lib import crypt
from app.lib.deps import create_service_provider


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
    async with RoleService.new(
        statement=select(Role).options(
            load_only(Role.id, Role.slug, Role.name, Role.description)
        ),
        config=alchemy,
    ) as service:
        fixture_data = await open_fixture_async(fixtures_path, "role")
        await service.upsert_many(
            match_fields=["name"], data=fixture_data, auto_commit=True
        )
        await logger.ainfo("loaded roles")


@user_management_group.command(
    name="create-token", help="Create a token for a user from a given secret"
)
@click.option(
    "--email",
    help="Email of the user we want to create the token for",
    type=click.STRING,
    required=True,
    show_default=False,
)
@click.option(
    "--secret",
    help="The secret used to build the token",
    type=click.STRING,
    required=True,
    show_default=False,
)
def create_token(
    email: str,
    secret: str,
) -> None:
    """Create a token."""

    console = get_console()

    async def _create_token(
        email: str,
        secret: str,
    ) -> None:
        logger = get_logger()

        provide_tokens_service = create_service_provider(TokenService)

        async with alchemy.get_session() as db_session:
            users_service = await anext(provide_users_service(db_session))
            tokens_service = await anext(provide_tokens_service(db_session))

            user = await users_service.get_one_or_none(email=email)

            if not user:
                logger.error(f"User with email {email} not found")
                return

            hashed_token = await crypt.get_password_hash(secret)

            token_to_create = ApiTokenCreate(hashed_token=hashed_token, user_id=user.id)

            token = await tokens_service.create(
                data=token_to_create.to_dict(), auto_commit=True
            )

            console.print(f"Token for user {email} created, id: {token.id}")

    console.rule("Create a new token for a given user.")

    anyio.run(
        _create_token,
        cast("str", email),
        cast("str", secret),
    )


@user_management_group.command(
    name="import-django-users", help="Import Django users from JSON file"
)
@click.argument(
    "json_file",
    type=click.File("rb"),
)
def import_django_users(json_file: click.File) -> None:
    """Load users from Django.

    Command used to export users from the Django DB:

    psql -qAtX -h localhost -p 10000 -U ecobalyse_9678 -c "select json_agg(t) FROM (SELECT * from authentication_ecobalyseuser) t;" -o data.json

    Args:
        json file (Path): The path to the JSON file to load exported from psql
    """

    console = get_console()

    json_data = orjson.loads(json_file.read())

    async def _load_users_json(users_data) -> None:
        users_to_create = []

        logger = get_logger()

        for user in users_data:
            users_to_create.append(
                UserDjangoCreate(
                    email=user["email"],
                    is_superuser=user["is_superuser"],
                    is_active=user["is_active"],
                    is_verified=True if user.get("last_login", None) else False,
                    terms_accepted=user["terms_of_use"],
                    first_name=user["first_name"],
                    last_name=user["last_name"],
                    organization=user["organization"],
                    joined_at=datetime.fromisoformat(user["date_joined"]),
                    old_token=user["token"],
                ).to_dict()
            )

        async with alchemy.get_session() as db_session:
            users_service = await anext(provide_users_service(db_session))
            await users_service.upsert_many(
                match_fields=["email"], data=users_to_create, auto_commit=True
            )

            await logger.ainfo(f"{len(users_to_create)} users created or updated.")

    console.rule("Loading Django users file.")
    anyio.run(_load_users_json, json_data)


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


@user_management_group.command(
    name="create-roles",
    help="Create pre-configured application roles and assign to users.",
)
def create_default_roles() -> None:
    """Create the default Roles for the system

    Args:
        email (str): The email address of the user to promote.
    """
    provide_roles_service = create_service_provider(RoleService)
    console = get_console()

    async def _create_default_roles() -> None:
        await load_database_fixtures()
        async with alchemy.get_session() as db_session:
            users_service = await anext(provide_users_service(db_session))
            roles_service = await anext(provide_roles_service(db_session))
            default_role = await roles_service.get_one_or_none(
                slug=slugify(users_service.default_role)
            )
            if default_role:
                all_active_users = await users_service.list(is_active=True)
                for user in all_active_users:
                    if any(r.role_id == default_role.id for r in user.roles):
                        console.print("User %s already has default role", user.email)
                    else:
                        user.roles.append(UserRole(role_id=default_role.id))
                        console.print("Assigned %s default role", user.email)
                        await users_service.repository.update(user)
            await db_session.commit()

    console.rule("Creating default roles.")
    anyio.run(_create_default_roles)


@click.group(
    name="fixtures",
    invoke_without_command=False,
    help="Manage application fixtures.",
)
@click.pass_context
def fixtures_management_group(_: dict[str, Any]) -> None:
    """Manage application components."""


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

    from structlog import get_logger

    from app.domain.processes.services import ProcessService

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
