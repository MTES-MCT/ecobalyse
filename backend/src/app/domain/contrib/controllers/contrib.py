from __future__ import annotations

from app.db import models as m
from app.domain.accounts.guards import requires_active_user
from app.domain.contrib import urls
from app.domain.contrib.schemas import ContribCreate, ContribResponse
from app.domain.contrib.services import create_contrib_pr
from litestar import Controller, post


class ContribController(Controller):
    tags = ["Contrib"]

    @post(
        operation_id="CreateContrib",
        path=urls.CONTRIB_EXAMPLES,
        guards=[requires_active_user],
    )
    async def create_contrib(
        self,
        current_user: m.User,
        data: ContribCreate,
    ) -> ContribResponse:
        branch_name, pull_request_url = await create_contrib_pr(
            data=data, user=current_user
        )
        return ContribResponse(
            branch_name=branch_name, pull_request_url=pull_request_url
        )
