from __future__ import annotations

from app.db import models as m
from app.domain.accounts.guards import requires_active_user
from app.domain.generic_contributions import urls
from app.domain.generic_contributions.schemas import (
    GenericContributionCreate,
    GenericContributionResponse,
)
from app.domain.generic_contributions.services import create_generic_contribution_pr
from litestar import Controller, post


class GenericContributionController(Controller):
    tags = ["Generic Contributions"]

    @post(
        operation_id="CreateGenericContributionPullRequest",
        path=urls.GENERIC_EXAMPLES_CONTRIBUTIONS_CREATE,
        guards=[requires_active_user],
    )
    async def create_contribution(
        self,
        current_user: m.User,
        data: GenericContributionCreate,
    ) -> GenericContributionResponse:
        branch_name, pull_request_url = await create_generic_contribution_pr(
            data=data, user=current_user
        )
        return GenericContributionResponse(
            branch_name=branch_name, pull_request_url=pull_request_url
        )
