import logging
import sys
from functools import lru_cache
from typing import Any, Callable, cast

import structlog
from advanced_alchemy.extensions.litestar.exception_handler import (
    ConflictError,
    DuplicateKeyError,
    ForeignKeyError,
    IntegrityError,
    InternalServerException,
)
from litestar.config.compression import CompressionConfig
from litestar.config.cors import CORSConfig
from litestar.config.csrf import CSRFConfig
from litestar.logging.config import (
    LoggingConfig,
    StructLoggingConfig,
    default_logger_factory,
    default_structlog_standard_lib_processors,
)
from litestar.middleware.logging import LoggingMiddlewareConfig
from litestar.plugins.problem_details import (
    ProblemDetailsConfig,
    ProblemDetailsException,
)
from litestar.plugins.sqlalchemy import (
    AlembicAsyncConfig,
    AsyncSessionConfig,
    SQLAlchemyAsyncConfig,
)
from litestar.plugins.structlog import StructlogConfig
from litestar.serialization.msgspec_hooks import _msgspec_json_encoder
from litestar.status_codes import HTTP_409_CONFLICT, HTTP_500_INTERNAL_SERVER_ERROR
from structlog.types import Processor
from structlog.typing import EventDict

from .base import get_settings

settings = get_settings()

compression = CompressionConfig(backend="gzip")
csrf = CSRFConfig(
    secret=settings.app.SECRET_KEY,
    cookie_secure=settings.app.CSRF_COOKIE_SECURE,
    cookie_name=settings.app.CSRF_COOKIE_NAME,
)
cors = CORSConfig(allow_origins=cast("list[str]", settings.app.ALLOWED_CORS_ORIGINS))
alchemy = SQLAlchemyAsyncConfig(
    engine_instance=settings.db.get_engine(),
    before_send_handler="autocommit",
    session_config=AsyncSessionConfig(expire_on_commit=False),
    alembic_config=AlembicAsyncConfig(
        version_table_name=settings.db.MIGRATION_DDL_VERSION_TABLE,
        script_config=settings.db.MIGRATION_CONFIG,
        script_location=settings.db.MIGRATION_PATH,
    ),
)


def convert_sqlalchemy_exceptions_conflict_to_problem_details(
    exc: ConflictError,
) -> ProblemDetailsException:
    return ProblemDetailsException(detail=exc.detail, status_code=HTTP_409_CONFLICT)


def convert_sqlalchemy_exceptions_internal_to_problem_details(
    exc: InternalServerException,
) -> ProblemDetailsException:
    return ProblemDetailsException(
        detail=exc.detail, status_code=HTTP_500_INTERNAL_SERVER_ERROR
    )


problem_details = ProblemDetailsConfig(
    enable_for_all_http_exceptions=True,
    exception_to_problem_detail_map={
        DuplicateKeyError: convert_sqlalchemy_exceptions_conflict_to_problem_details,
        IntegrityError: convert_sqlalchemy_exceptions_conflict_to_problem_details,
        ForeignKeyError: convert_sqlalchemy_exceptions_conflict_to_problem_details,
        InternalServerException: convert_sqlalchemy_exceptions_internal_to_problem_details,
    },
)


@lru_cache
def _is_tty() -> bool:
    return bool(sys.stderr.isatty() or sys.stdout.isatty())


def default_json_serializer(value: EventDict, **_: Any) -> bytes:
    return _msgspec_json_encoder.encode(value)


def default_structlog_processors(
    as_json: bool = True,
    json_serializer: Callable[[Any], Any] = default_json_serializer,
) -> list[Processor]:  # pyright: ignore
    """Set the default processors for structlog.

    Returns:
        An optional list of processors.
    """
    try:
        import structlog
        from structlog.dev import RichTracebackFormatter

        if as_json:
            return [
                structlog.contextvars.merge_contextvars,
                structlog.processors.add_log_level,
                structlog.processors.format_exc_info,
                structlog.processors.TimeStamper(fmt="iso"),
                structlog.processors.JSONRenderer(serializer=json_serializer),
            ]
        return [
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.dev.ConsoleRenderer(
                colors=True,
                exception_formatter=RichTracebackFormatter(width=80, show_locals=False),
            ),
        ]

    except ImportError:
        return []


_render_as_json = False
_structlog_default_processors = default_structlog_processors(as_json=_render_as_json)
_structlog_default_processors.insert(1, structlog.processors.EventRenamer("message"))

_structlog_standard_lib_processors = default_structlog_standard_lib_processors(
    as_json=_render_as_json
)
_structlog_standard_lib_processors.insert(
    1, structlog.processors.EventRenamer("message")
)

log = StructlogConfig(
    structlog_logging_config=StructLoggingConfig(
        log_exceptions="always",
        processors=_structlog_default_processors,
        logger_factory=default_logger_factory(as_json=_render_as_json),
        standard_lib_logging_config=LoggingConfig(
            root={
                "level": logging.getLevelName(settings.log.LEVEL),
                "handlers": ["queue_listener"],
            },
            formatters={
                "standard": {
                    "()": structlog.stdlib.ProcessorFormatter,
                    "processors": _structlog_standard_lib_processors,
                },
            },
            loggers={
                "saq": {
                    "propagate": False,
                    "level": settings.log.SAQ_LEVEL,
                    "handlers": ["queue_listener"],
                },
                "sqlalchemy.engine": {
                    "propagate": False,
                    "level": settings.log.SQLALCHEMY_LEVEL,
                    "handlers": ["queue_listener"],
                },
                "sqlalchemy.pool": {
                    "propagate": False,
                    "level": settings.log.SQLALCHEMY_LEVEL,
                    "handlers": ["queue_listener"],
                },
            },
        ),
    ),
    middleware_logging_config=LoggingMiddlewareConfig(
        request_log_fields=settings.log.REQUEST_FIELDS,
        response_log_fields=settings.log.RESPONSE_FIELDS,
    ),
)
