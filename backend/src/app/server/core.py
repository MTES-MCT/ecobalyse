from __future__ import annotations

from typing import TypeVar

from app.domain.accounts.services import UserRoleService
from click import Group
from litestar.config.app import AppConfig
from litestar.di import Provide
from litestar.openapi.config import OpenAPIConfig
from litestar.openapi.plugins import ScalarRenderPlugin
from litestar.plugins import CLIPluginProtocol, InitPluginProtocol
from litestar.security.jwt import OAuth2Login

T = TypeVar("T")


class ApplicationCore(InitPluginProtocol, CLIPluginProtocol):
    """Application core configuration plugin.

    This class is responsible for configuring the main Litestar application with our routes, guards, and various plugins

    """

    __slots__ = "app_slug"
    app_slug: str

    def on_cli_init(self, cli: Group) -> None:
        from app.cli.commands import (
            fixtures_management_group,
            json_management_group,
            user_management_group,
        )
        from app.config import get_settings

        settings = get_settings()
        self.app_slug = settings.app.slug
        cli.add_command(fixtures_management_group)
        cli.add_command(user_management_group)
        cli.add_command(json_management_group)

    def on_app_init(self, app_config: AppConfig) -> AppConfig:
        """Configure application for use with SQLAlchemy.

        Args:
            app_config: The :class:`AppConfig <litestar.config.app.AppConfig>` instance.
        """

        from uuid import UUID

        from app.__about__ import __version__ as current_version
        from app.config import app as config
        from app.config import get_settings
        from app.db import models as m
        from app.domain.accounts.controllers import AccessController
        from app.domain.accounts.deps import provide_user
        from app.domain.accounts.guards import auth as jwt_auth
        from app.domain.accounts.services import RoleService, UserService
        from app.domain.components.controllers import ComponentController
        from app.domain.components.services import ComponentService
        from app.domain.journal_entries.controllers import JournalEntryController
        from app.domain.journal_entries.services import JournalEntryService
        from app.domain.processes.controllers import ProcessController
        from app.domain.processes.services import ProcessService
        from app.domain.system.controllers import SystemController
        from app.server import plugins
        from litestar.enums import RequestEncodingType
        from litestar.params import Body

        settings = get_settings()
        self.app_slug = settings.app.slug
        app_config.debug = settings.app.DEBUG

        app_config.openapi_config = OpenAPIConfig(
            title=settings.app.NAME,
            version=current_version,
            components=[jwt_auth.openapi_components],
            security=[jwt_auth.security_requirement],
            use_handler_docstrings=True,
            render_plugins=[ScalarRenderPlugin(version="latest")],
        )

        # jwt auth (updates openapi config)
        app_config = jwt_auth.on_app_init(app_config)

        # security
        app_config.cors_config = config.cors

        # plugins
        app_config.plugins.extend(
            [
                plugins.structlog,
                plugins.alchemy,
                plugins.problem_details,
            ]
        )

        # routes
        app_config.route_handlers.extend(
            [
                AccessController,
                ComponentController,
                JournalEntryController,
                ProcessController,
                SystemController,
            ],
        )

        # signatures
        app_config.signature_namespace.update(
            {
                "RequestEncodingType": RequestEncodingType,
                "OAuth2Login": OAuth2Login,
                "Body": Body,
                "m": m,
                "UUID": UUID,
                "ComponentService": ComponentService,
                "ProcessService": ProcessService,
                "JournalEntryService": JournalEntryService,
                "RoleService": RoleService,
                "UserService": UserService,
                "UserRoleService": UserRoleService,
            },
        )

        dependencies = {
            "current_user": Provide(provide_user),
        }
        app_config.dependencies.update(dependencies)

        return app_config
