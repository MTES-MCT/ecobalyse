"""Components Controllers."""

from __future__ import annotations

from typing import TYPE_CHECKING

from app.domain.components.services import ComponentService
from app.lib.deps import create_service_provider

if TYPE_CHECKING:
    pass

# create a hard reference to this since it's used oven
provide_components_service = create_service_provider(
    ComponentService,
)
