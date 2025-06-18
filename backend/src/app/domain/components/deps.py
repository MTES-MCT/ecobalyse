"""Components Controllers."""

from __future__ import annotations

from app.domain.components.services import ComponentService
from app.lib.deps import create_service_provider

provide_components_service = create_service_provider(
    ComponentService,
)
