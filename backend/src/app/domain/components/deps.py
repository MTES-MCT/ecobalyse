"""Components Controllers."""

from __future__ import annotations

from app.db import models as m
from app.domain.components.services import ComponentService, ScopeService
from app.lib.deps import create_service_provider

provide_components_service = create_service_provider(
    ComponentService,
    load=[m.ComponentModel.scopes],
)

provide_scopes_service = create_service_provider(
    ScopeService,
)
