"""Components Controllers."""

from __future__ import annotations

from app.db import models as m
from app.domain.components.services import ComponentService
from app.lib.deps import create_service_provider
from sqlalchemy.orm import joinedload, selectinload

provide_components_service = create_service_provider(
    ComponentService,
    load=[
        selectinload(m.Component.elements).options(
            joinedload(m.Element.material_process, innerjoin=True)
        ),
    ],
)
