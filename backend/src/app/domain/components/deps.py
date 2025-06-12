"""Components Controllers."""

from __future__ import annotations

from app.domain.components.services import ComponentService
from app.lib.deps import create_service_provider

provide_components_service = create_service_provider(
    ComponentService,
    load=[m.ComponentModel.scopes],
)

provide_scopes_service = create_service_provider(
    ScopeService,
)
