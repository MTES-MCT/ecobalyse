"""Elements Controllers."""

from __future__ import annotations

from app.db import models as m
from app.domain.elements.services import ElementService
from app.lib.deps import create_service_provider

provide_elements_service = create_service_provider(
    ElementService,
    load=[m.Element.process_transforms],
)
