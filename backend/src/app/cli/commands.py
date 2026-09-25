from __future__ import annotations

from pathlib import Path
from typing import cast

import anyio
import click
from advanced_alchemy.utils.fixtures import open_fixture_async
from rich import get_console
from structlog import get_logger

from app.config import get_settings
from app.config.app import alchemy
from app.domain.accounts.deps import provide_users_service
from app.domain.accounts.schemas import (
    OrganizationCreate,
    OrganizationType,
    UserCreate,
)
from app.domain.accounts.services import UserService


@click.group(
    name="users",
    invoke_without_command=False,
    help="Manage application users and roles.",
)
@click.pass_context
def user_management_group(_) -> None:
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
    betauser: bool = False,
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
            is_betauser=betauser,
            is_superuser=superuser,
            is_active=is_active,
            terms_accepted=True,
        )
        users_to_upsert.append(user_in.model_dump())

    console = get_console()

    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))
        await users_service.upsert_many(
            data=users_to_upsert, auto_commit=True, match_fields=["email"]
        )
        console.print(f"Users upserted: {[user for user in users_to_upsert]}")


async def _create_user(
    email: str,
    first_name: str,
    last_name: str,
    organization: str,
    organization_type: OrganizationType = OrganizationType.LOCAL_AUTHORITY,
    betauser: bool = False,
    superuser: bool = False,
    is_active: bool = True,
) -> None:
    await _create_users(
        f"{email}/{first_name}/{last_name}",
        organization=organization,
        organization_type=organization_type,
        betauser=betauser,
        superuser=superuser,
        is_active=is_active,
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
    "--betauser",
    help="Should create beta users",
    type=click.BOOL,
    default=False,
    required=False,
    show_default=False,
    is_flag=True,
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
    betauser: bool,
    superuser: bool,
) -> None:
    """Create multiple users."""

    console = get_console()

    console.rule("Create multiple users.")

    anyio.run(
        _create_users,
        users,
        organization,
        organization_type,
        betauser,
        superuser,
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
@click.option(
    "--betauser",
    help="Is a betauser",
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
    betauser: bool,
    superuser: bool,
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
        first_name,
        last_name,
        organization,
        organization_type,
        betauser,
        superuser,
    )


async def _set_betauser(user_email: str, betauser: bool) -> None:

    console = get_console()
    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))
        user = await users_service.get_one_or_none(email=user_email)

        if not user:
            raise click.ClickException("User not found")

        await users_service.update(
            item_id=user.id, data={"is_betauser": betauser}, auto_commit=True
        )

        console.print(f"Beta status updated to {betauser} for '{user_email}'")


@user_management_group.command(
    name="set-betauser", help="Set betauser status for an user"
)
@click.argument(
    "email",
    type=click.STRING,
)
@click.argument("beta_status", type=click.BOOL)
def set_betauser(
    email: str,
    beta_status: bool,
) -> None:
    """Create a user."""

    console = get_console()

    console.rule(f"Set user beta status to {beta_status}.")

    anyio.run(_set_betauser, email, beta_status)


@click.group(
    name="fixtures",
    invoke_without_command=False,
    help="Manage application fixtures.",
)
@click.pass_context
def fixtures_management_group(_) -> None:
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

    users_service = await anext(provide_users_service(db_session))

    settings = get_settings()
    user = await users_service.get_one_or_none(email=settings.app.DEFAULT_USER_EMAIL)
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
