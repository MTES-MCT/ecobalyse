from __future__ import annotations

from collections.abc import AsyncGenerator, AsyncIterator
from pathlib import Path
from typing import Any

import pytest
from advanced_alchemy.base import UUIDAuditBase
from advanced_alchemy.utils.fixtures import open_fixture_async
from app.config import app as config
from app.config import get_settings
from app.db.models import Component, Process, User
from app.domain.accounts.guards import auth
from app.domain.accounts.services import RoleService, UserService
from app.domain.components.services import ComponentService
from app.domain.processes.services import ProcessService
from httpx import AsyncClient
from litestar import Litestar
from litestar.serialization import decode_json, encode_json
from litestar.testing import AsyncTestClient
from pytest_databases.docker.postgres import PostgresService
from sqlalchemy import event
from sqlalchemy.engine import URL
from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.pool import NullPool

here = Path(__file__).parent
pytestmark = pytest.mark.anyio


@pytest.fixture(name="engine")
async def fx_engine(postgres_service: PostgresService) -> AsyncEngine:
    """Postgresql instance for end-to-end testing.

    Returns:
        Async SQLAlchemy engine instance.
    """

    engine = create_async_engine(
        URL(
            drivername="postgresql+asyncpg",
            username=postgres_service.user,
            password=postgres_service.password,
            host=postgres_service.host,
            port=postgres_service.port,
            database=postgres_service.database,
            query={},  # type:ignore[arg-type]
        ),
        # echo=True,
        future=True,
        poolclass=NullPool,
        json_serializer=encode_json,
        json_deserializer=decode_json,
    )

    @event.listens_for(engine.sync_engine, "connect")
    def _sqla_on_connect(dbapi_connection: Any, _: Any) -> Any:  # pragma: no cover
        """Using msgspec for serialization of the json column values means that the
        output is binary, not `str` like `json.dumps` would output.
        SQLAlchemy expects that the json serializer returns `str` and calls `.encode()` on the value to
        turn it to bytes before writing to the JSONB column. I'd need to either wrap `serialization.to_json` to
        return a `str` so that SQLAlchemy could then convert it to binary, or do the following, which
        changes the behaviour of the dialect to expect a binary value from the serializer.
        See Also https://github.com/sqlalchemy/sqlalchemy/blob/14bfbadfdf9260a1c40f63b31641b27fe9de12a0/lib/sqlalchemy/dialects/postgresql/asyncpg.py#L934  pylint: disable=line-too-long
        """

        def encoder(bin_value: bytes) -> bytes:
            return b"\x01" + bin_value

        def decoder(bin_value: bytes) -> Any:
            # the byte is the \x01 prefix for jsonb used by PostgreSQL.
            # asyncpg returns it when format='binary'
            return decode_json(bin_value[1:])

        dbapi_connection.await_(
            dbapi_connection.driver_connection.set_type_codec(
                "jsonb",
                encoder=encoder,
                decoder=decoder,
                schema="pg_catalog",
                format="binary",
            ),
        )
        dbapi_connection.await_(
            dbapi_connection.driver_connection.set_type_codec(
                "json",
                encoder=encoder,
                decoder=decoder,
                schema="pg_catalog",
                format="binary",
            ),
        )

    return engine


@pytest.fixture(name="sessionmaker")
async def fx_session_maker_factory(
    engine: AsyncEngine,
) -> AsyncGenerator[async_sessionmaker[AsyncSession], None]:
    yield async_sessionmaker(bind=engine, expire_on_commit=False)


@pytest.fixture(name="session")
async def fx_session(
    sessionmaker: async_sessionmaker[AsyncSession],
) -> AsyncGenerator[AsyncSession, None]:
    async with sessionmaker() as session:
        yield session


@pytest.fixture(autouse=True)
async def _seed_db(
    engine: AsyncEngine,
    session: AsyncSession,
    raw_processes: list[Process | dict[str, Any]],
    raw_components: list[Component | dict[str, Any]],
    raw_users: list[User | dict[str, Any]],
) -> AsyncGenerator[None, None]:
    """Populate test database with.

    Args:
        engine: The SQLAlchemy engine instance.
        sessionmaker: The SQLAlchemy sessionmaker factory.
        raw_components: Test components to add to the database
        raw_processes: Test processes to add to the database

    """

    settings = get_settings()
    fixtures_path = Path(settings.db.FIXTURE_PATH)
    metadata = UUIDAuditBase.registry.metadata
    async with engine.begin() as conn:
        await conn.run_sync(metadata.drop_all)
        await conn.run_sync(metadata.create_all)

    async with RoleService.new(session) as service:
        fixture = await open_fixture_async(fixtures_path, "role")
        for obj in fixture:
            _ = await service.repository.get_or_upsert(
                match_fields="name", upsert=True, **obj
            )
        await service.repository.session.commit()

    async with UserService.new(session) as users_service:
        await users_service.create_many(raw_users, auto_commit=True)

    async with ProcessService.new(session) as processes_service:
        await processes_service.create_many(raw_processes, auto_commit=True)

    async with ComponentService.new(session) as components_service:
        await components_service.create_many(raw_components, auto_commit=True)

    yield


@pytest.fixture(autouse=True)
def _patch_db(
    app: "Litestar",
    engine: AsyncEngine,
    sessionmaker: async_sessionmaker[AsyncSession],
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    monkeypatch.setattr(config.alchemy, "session_maker", sessionmaker)
    monkeypatch.setattr(config.alchemy, "engine_instance", engine)


@pytest.fixture(name="client")
async def fx_client(app: Litestar) -> AsyncIterator[AsyncClient]:
    """Async client that calls requests on the app.

    ```text
    ValueError: The future belongs to a different loop than the one specified as the loop argument
    ```
    """
    async with AsyncTestClient(app) as client:
        yield client


@pytest.fixture(name="superuser_token_headers")
def fx_superuser_token_headers() -> dict[str, str]:
    """Valid superuser token.

    ```text
    ValueError: The future belongs to a different loop than the one specified as the loop argument
    ```
    """
    return {
        "Authorization": f"Bearer {auth.create_token(identifier='superuser@example.com')}"
    }


@pytest.fixture(name="other_superuser_token_headers")
def fx_other_superuser_token_headers() -> dict[str, str]:
    """Valid superuser token.

    ```text
    ValueError: The future belongs to a different loop than the one specified as the loop argument
    ```
    """
    return {
        "Authorization": f"Bearer {auth.create_token(identifier='other_superuser@example.com')}"
    }


@pytest.fixture(name="user_token_headers")
def fx_user_token_headers() -> dict[str, str]:
    """Valid user token.

    ```text
    ValueError: The future belongs to a different loop than the one specified as the loop argument
    ```
    """
    return {
        "Authorization": f"Bearer {auth.create_token(identifier='user@example.com')}"
    }
