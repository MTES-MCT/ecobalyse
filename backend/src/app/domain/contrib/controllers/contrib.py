from __future__ import annotations

from app.config import get_settings
from app.db import models as m
from app.domain.accounts.guards import requires_active_user
from app.domain.contrib import urls
from app.domain.contrib.schemas import ExampleContribCreate, ExampleContribResponse
from app.domain.contrib.services import create_example_contrib_pr
from litestar import Controller, post

settings = get_settings()


class ExampleContribController(Controller):
    tags = ["Contrib", "Examples"]

    @post(
        operation_id="CreateExampleContrib",
        path=urls.CONTRIB_EXAMPLES,
        guards=[requires_active_user],
    )
    async def create_example_contrib(
        self,
        current_user: m.User,
        data: ExampleContribCreate,
    ) -> ExampleContribResponse:
        return await create_example_contrib_pr(
            data=data,
            github_settings=settings.github,
            user=current_user,
        )
