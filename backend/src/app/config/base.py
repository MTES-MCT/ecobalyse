from __future__ import annotations

import binascii
import json
import os
import sys
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path
from typing import TYPE_CHECKING, Any, Final, TypeVar, cast
from uuid import UUID

from advanced_alchemy.utils.text import slugify
from litestar.data_extractors import RequestExtractorField
from litestar.types import Empty, EmptyType, TypeDecodersSequence
from litestar.utils.module_loader import module_to_os_path
from sqlalchemy import event
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine
from sqlalchemy.pool import NullPool

from ._utils import get_config_val, get_env

if TYPE_CHECKING:
    from collections.abc import Callable

    from litestar.data_extractors import ResponseExtractorField

DEFAULT_MODULE_NAME = "app.asgi"
BASE_DIR: Final[Path] = module_to_os_path(DEFAULT_MODULE_NAME)

T = TypeVar("T")


class UUIDEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, UUID):
            # if the obj is uuid, we simply return the value of uuid
            return str(obj)
        return json.JSONEncoder.default(self, obj)


def encode_json(value: Any, serializer: Callable[[Any], Any] | None = None) -> bytes:
    """Encode a value into JSON.

    Args:
        value: Value to encode
        serializer: Optional callable to support non-natively supported types.

    Returns:
        JSON as bytes

    Raises:
        SerializationException: If error encoding ``obj``.
    """

    # We have a pydantic model to encode
    if not isinstance(value, dict):
        value = value.model_dump(by_alias=True)

    return json.dumps(value, cls=UUIDEncoder, indent=2, sort_keys=True)


def decode_json(  # type: ignore[misc]
    value: str | bytes,
    target_type: type[T] | EmptyType = Empty,  # pyright: ignore
    type_decoders: TypeDecodersSequence | None = None,
    strict: bool = True,
) -> Any:
    """Decode a JSON string/bytes into an object.

    Args:
        value: Value to decode
        target_type: An optional type to decode the data into
        type_decoders: Optional sequence of type decoders
        strict: Whether type coercion rules should be strict. Setting to False enables
            a wider set of coercion rules from string to non-string types for all values

    Returns:
        An object

    Raises:
        SerializationException: If error decoding ``value``.
    """

    if target_type is Empty:
        return value
    return target_type.model_validate_json(value)


@dataclass
class DatabaseSettings:
    ECHO: bool = field(default_factory=get_env("DATABASE_ECHO", False))
    """Enable SQLAlchemy engine logs."""
    ECHO_POOL: bool = field(default_factory=get_env("DATABASE_ECHO_POOL", False))
    """Enable SQLAlchemy connection pool logs."""
    POOL_DISABLED: bool = field(
        default_factory=get_env("DATABASE_POOL_DISABLED", False)
    )
    """Disable SQLAlchemy pool configuration."""
    POOL_MAX_OVERFLOW: int = field(
        default_factory=get_env("DATABASE_MAX_POOL_OVERFLOW", 10)
    )
    """Max overflow for SQLAlchemy connection pool"""
    POOL_SIZE: int = field(default_factory=get_env("DATABASE_POOL_SIZE", 5))
    """Pool size for SQLAlchemy connection pool"""
    POOL_TIMEOUT: int = field(default_factory=get_env("DATABASE_POOL_TIMEOUT", 30))
    """Time in seconds for timing connections out of the connection pool."""
    POOL_RECYCLE: int = field(default_factory=get_env("DATABASE_POOL_RECYCLE", 300))
    """Amount of time to wait before recycling connections."""
    POOL_PRE_PING: bool = field(
        default_factory=get_env("DATABASE_PRE_POOL_PING", False)
    )
    """Optionally ping database before fetching a session from the connection pool."""
    URL: str = field(
        default_factory=get_env(
            "DATABASE_URL",
            "postgresql+asyncpg://ecobalyse@localhost:5433/ecobalyse_dev",
        )
    )
    """SQLAlchemy Database URL."""
    MIGRATION_CONFIG: str = field(
        default_factory=get_env(
            "DATABASE_MIGRATION_CONFIG", f"{BASE_DIR}/db/migrations/alembic.ini"
        )
    )
    """The path to the `alembic.ini` configuration file."""
    MIGRATION_PATH: str = field(
        default_factory=get_env("DATABASE_MIGRATION_PATH", f"{BASE_DIR}/db/migrations")
    )
    """The path to the `alembic` database migrations."""
    MIGRATION_DDL_VERSION_TABLE: str = field(
        default_factory=get_env("DATABASE_MIGRATION_DDL_VERSION_TABLE", "ddl_version")
    )
    """The name to use for the `alembic` versions table name."""
    FIXTURE_PATH: str = field(
        default_factory=get_env("DATABASE_FIXTURE_PATH", f"{BASE_DIR}/db/fixtures")
    )
    """The path to JSON fixture files to load into tables."""
    _engine_instance: AsyncEngine | None = None
    """SQLAlchemy engine instance generated from settings."""

    @property
    def engine(self) -> AsyncEngine:
        return self.get_engine()

    def get_engine(self) -> AsyncEngine:
        if self._engine_instance is not None:
            return self._engine_instance
        if self.URL.startswith("postgresql+asyncpg"):
            engine = create_async_engine(
                url=self.URL,
                future=True,
                # Used for jsonb fields
                json_serializer=encode_json,
                json_deserializer=decode_json,
                echo=self.ECHO,
                echo_pool=self.ECHO_POOL,
                max_overflow=self.POOL_MAX_OVERFLOW,
                pool_size=self.POOL_SIZE,
                pool_timeout=self.POOL_TIMEOUT,
                pool_recycle=self.POOL_RECYCLE,
                pool_pre_ping=self.POOL_PRE_PING,
                pool_use_lifo=True,  # use lifo to reduce the number of idle connections
                poolclass=NullPool if self.POOL_DISABLED else None,
            )
            """Database session factory.

            See [`async_sessionmaker()`][sqlalchemy.ext.asyncio.async_sessionmaker].
            """

        elif self.URL.startswith("sqlite+aiosqlite"):
            engine = create_async_engine(
                url=self.URL,
                future=True,
                json_serializer=encode_json,
                json_deserializer=decode_json,
                echo=self.ECHO,
                echo_pool=self.ECHO_POOL,
                pool_recycle=self.POOL_RECYCLE,
                pool_pre_ping=self.POOL_PRE_PING,
                pool_size=self.POOL_SIZE,
            )
            """Database session factory.

            See [`async_sessionmaker()`][sqlalchemy.ext.asyncio.async_sessionmaker].
            """

            @event.listens_for(engine.sync_engine, "connect")
            def _sqla_on_connect(
                dbapi_connection: Any, _: Any
            ) -> Any:  # pragma: no cover
                """Override the default begin statement.  The disables the built in begin execution."""
                dbapi_connection.isolation_level = None

            @event.listens_for(engine.sync_engine, "begin")
            def _sqla_on_begin(dbapi_connection: Any) -> Any:  # pragma: no cover
                """Emits a custom begin"""
                dbapi_connection.exec_driver_sql("BEGIN")
        else:
            engine = create_async_engine(
                url=self.URL,
                future=True,
                json_serializer=encode_json,
                json_deserializer=decode_json,
                echo=self.ECHO,
                echo_pool=self.ECHO_POOL,
                max_overflow=self.POOL_MAX_OVERFLOW,
                pool_size=self.POOL_SIZE,
                pool_timeout=self.POOL_TIMEOUT,
                pool_recycle=self.POOL_RECYCLE,
                pool_pre_ping=self.POOL_PRE_PING,
                pool_use_lifo=True,  # use lifo to reduce the number of idle connections
                poolclass=NullPool if self.POOL_DISABLED else None,
            )
        self._engine_instance = engine
        return self._engine_instance


@dataclass
class LogSettings:
    """Logger configuration"""

    # https://stackoverflow.com/a/1845097/6560549
    EXCLUDE_PATHS: str = r"\A(?!x)x"
    """Regex to exclude paths from logging."""
    HTTP_EVENT: str = "HTTP"
    """Log event name for logs from Litestar handlers."""
    INCLUDE_COMPRESSED_BODY: bool = False
    """Include 'body' of compressed responses in log output."""
    LEVEL: int = field(default_factory=get_env("LOG_LEVEL", 30))
    """Stdlib log levels.

    Only emit logs at this level, or higher.
    """
    OBFUSCATE_COOKIES: set[str] = field(
        default_factory=lambda: {"session", "XSRF-TOKEN"}
    )
    """Request cookie keys to obfuscate."""
    OBFUSCATE_HEADERS: set[str] = field(
        default_factory=lambda: {"Authorization", "X-API-KEY", "X-XSRF-TOKEN"}
    )
    """Request header keys to obfuscate."""
    REQUEST_FIELDS: list[RequestExtractorField] = field(
        default_factory=get_env(
            "LOG_REQUEST_FIELDS",
            [
                "path",
                "method",
                "query",
                "path_params",
            ],
            list[RequestExtractorField],
        ),
    )
    """Attributes of the [Request][litestar.connection.request.Request] to be
    logged."""
    RESPONSE_FIELDS: list[ResponseExtractorField] = field(
        default_factory=cast(
            "Callable[[],list[ResponseExtractorField]]",
            get_env(
                "LOG_RESPONSE_FIELDS",
                ["status_code"],
            ),
        )
    )
    """Attributes of the [Response][litestar.response.Response] to be
    logged."""
    WORKER_EVENT: str = "Worker"
    """Log event name for logs from SAQ worker."""
    SAQ_LEVEL: int = field(default_factory=get_env("SAQ_LOG_LEVEL", 50))
    """Level to log SAQ logs."""
    SQLALCHEMY_LEVEL: int = field(default_factory=get_env("SQLALCHEMY_LOG_LEVEL", 30))
    """Level to log SQLAlchemy logs."""
    ASGI_ACCESS_LEVEL: int = field(default_factory=get_env("ASGI_ACCESS_LOG_LEVEL", 30))
    """Level to log uvicorn access logs."""
    ASGI_ERROR_LEVEL: int = field(default_factory=get_env("ASGI_ERROR_LOG_LEVEL", 30))
    """Level to log uvicorn error logs."""


def _get_sentry_environment():
    # We use the `NODE_ENV` envvar here even though we are on the Python side, as
    # we want to synchronise the sentry environment value with the one set on the
    # front end.
    if get_config_val("IS_REVIEW_APP", None):
        return "review-app"
    else:
        return get_config_val("NODE_ENV", None)


@dataclass
class AppSettings:
    """Application configuration"""

    APP_LOC: str = "app.asgi:create_app"
    """Path to app executable, or factory."""
    URL: str = field(default_factory=get_env("APP_URL", "http://localhost:8000"))
    """The frontend base URL"""
    DEBUG: bool = field(default_factory=get_env("LITESTAR_DEBUG", False))
    """Run `Litestar` with `debug=True`."""
    SECRET_KEY: str = field(
        default_factory=get_env(
            "SECRET_KEY", binascii.hexlify(os.urandom(32)).decode(encoding="utf-8")
        ),
    )
    """Application secret key."""
    NAME: str = field(default_factory=lambda: "app")
    """Application name."""
    ALLOWED_CORS_ORIGINS: list[str] | str = field(
        default_factory=get_env("ALLOWED_CORS_ORIGINS", ["*"], list[str])
    )
    """Allowed CORS Origins"""
    CSRF_COOKIE_NAME: str = field(
        default_factory=get_env("CSRF_COOKIE_NAME", "XSRF-TOKEN")
    )
    """CSRF Cookie Name"""
    CSRF_COOKIE_SECURE: bool = field(
        default_factory=get_env("CSRF_COOKIE_SECURE", False)
    )
    """CSRF Secure Cookie"""
    JWT_ENCRYPTION_ALGORITHM: str = field(default_factory=lambda: "HS256")
    """JWT Encryption Algorithm"""

    DEFAULT_TOKEN_EXPIRATION_DAYS: int = field(
        default_factory=get_env("DEFAULT_TOKEN_EXPIRATION_DAYS", 365 * 2)
    )
    """The default value for token expiration."""

    DEFAULT_TOKEN_VALIDATION_CACHE_SECONDS: int = field(
        default_factory=get_env("DEFAULT_TOKEN_VALIDATION_CACHE_SECONDS", 20)
    )
    """The default value for token expiration."""

    DEFAULT_USER_EMAIL: str = field(
        default_factory=get_env("DEFAULT_USER_EMAIL", "admin@ecobalyse.dev")
    )
    """The default super user email"""

    SENTRY_DSN: str = field(default_factory=get_env("SENTRY_DSN", ""))
    """Sentry DSN"""

    SENTRY_ENVIRONMENT: str = field(default_factory=_get_sentry_environment)
    """The `environment` value expected by Sentry (production, development, …)"""

    @property
    def slug(self) -> str:
        """Return a slugified name.

        Returns:
            `self.NAME`, all lowercase and hyphens instead of spaces.
        """
        return slugify(self.NAME)

    def __post_init__(self) -> None:
        # Check if the ALLOWED_CORS_ORIGINS is a string.
        if isinstance(self.ALLOWED_CORS_ORIGINS, str):
            # Check if the string starts with "[" and ends with "]", indicating a list.
            if self.ALLOWED_CORS_ORIGINS.startswith(
                "["
            ) and self.ALLOWED_CORS_ORIGINS.endswith("]"):
                try:
                    # Safely evaluate the string as a Python list.
                    self.ALLOWED_CORS_ORIGINS = json.loads(self.ALLOWED_CORS_ORIGINS)
                except (SyntaxError, ValueError):
                    # Handle potential errors if the string is not a valid Python literal.
                    msg = "ALLOWED_CORS_ORIGINS is not a valid list representation."
                    raise ValueError(msg) from None
            else:
                # Split the string by commas into a list if it is not meant to be a list representation.
                self.ALLOWED_CORS_ORIGINS = [
                    host.strip() for host in self.ALLOWED_CORS_ORIGINS.split(",")
                ]


@dataclass
class ServerSettings:
    """Server configurations."""

    HOST: str = field(default_factory=get_env("LITESTAR_HOST", "0.0.0.0"))  # noqa: S104
    """Server network host."""
    PORT: int = field(default_factory=get_env("LITESTAR_PORT", 8000))
    """Server port."""
    KEEPALIVE: int = field(default_factory=get_env("LITESTAR_KEEPALIVE", 65))
    """Seconds to hold connections open (65 is > AWS lb idle timeout)."""
    RELOAD: bool = field(default_factory=get_env("LITESTAR_RELOAD", False))
    """Turn on hot reloading."""
    RELOAD_DIRS: list[str] = field(
        default_factory=get_env("LITESTAR_RELOAD_DIRS", [f"{BASE_DIR}"])
    )
    """Directories to watch for reloading."""


@dataclass
class EmailSettings:
    """Email configurations."""

    FROM: str = field(
        default_factory=get_env("EMAIL_FROM", "contact@ecobalyse.beta.gouv.fr")
    )  # noqa: S104
    """From email value."""
    SERVER_HOST: str = field(default_factory=get_env("EMAIL_SERVER_HOST", None))
    """Email server host."""
    SERVER_USER: str = field(default_factory=get_env("EMAIL_SERVER_USER", None))
    """Email server user."""
    SERVER_PASSWORD: str = field(default_factory=get_env("EMAIL_SERVER_PASSWORD", None))
    """Email server password."""
    SERVER_TIMEOUT: int = field(default_factory=get_env("EMAIL_SERVER_TIMEOUT", 5))
    """Email server timeout."""
    SERVER_PORT: int = field(default_factory=get_env("EMAIL_SERVER_PORT", 587))
    """Email server port."""

    SERVER_USE_TLS: bool = field(default_factory=get_env("EMAIL_SERVER_USE_TLS", True))

    """Disable SQLAlchemy pool configuration."""
    MAGIC_LINK_DURATION: str = field(
        default_factory=get_env("EMAIL_MAGIC_LINK_DURATION", 60 * 60 * 24)
    )
    """Email magic link duration in seconds. 24H by default."""


@dataclass
class GithubSettings:
    API_URL: str = field(
        default_factory=get_env("GITHUB_API_URL", "https://api.github.com")
    )
    BASE_BRANCH: str = field(default_factory=get_env("GITHUB_BASE_BRANCH", "master"))
    REPOSITORY: str = field(
        default_factory=get_env("GITHUB_REPOSITORY", "MTES-MCT/ecobalyse")
    )
    REVIEWING_TEAM: str = field(default_factory=get_env("GITHUB_REVIEWING_TEAM", ""))
    TOKEN: str = field(default_factory=get_env("GITHUB_TOKEN", ""))


@dataclass
class Settings:
    app: AppSettings = field(default_factory=AppSettings)
    db: DatabaseSettings = field(default_factory=DatabaseSettings)
    email: EmailSettings = field(default_factory=EmailSettings)
    github: GithubSettings = field(default_factory=GithubSettings)
    log: LogSettings = field(default_factory=LogSettings)
    server: ServerSettings = field(default_factory=ServerSettings)

    def is_test_env(self) -> bool:
        return "pytest" in sys.modules

    @classmethod
    def from_env(cls, dotenv_filename: str = ".env") -> Settings:
        env_file = Path(f"{os.curdir}/{dotenv_filename}")
        if env_file.is_file():
            from dotenv import load_dotenv

            load_dotenv(env_file, override=True)
        return Settings()


@lru_cache(maxsize=1, typed=True)
def get_settings() -> Settings:
    return Settings.from_env()
