from __future__ import annotations

import base64
import json
from uuid import uuid4

import structlog
from app.config.base import GithubSettings
from app.db import models as m
from app.domain.contrib.schemas import (
    ExampleContribCreate,
    ExampleContribResponse,
)
from app.lib.json import format_json
from httpx import AsyncClient
from litestar.exceptions import ValidationException

logger = structlog.get_logger()


def format_example_contrib_pr(data: ExampleContribCreate, user: m.User) -> str:
    return f"""Nouvelle proposition de contribution d’exemple : **{data.name} ({data.scope.value})**

### Contexte

{data.description.strip()}

### Contributeur

- Nom : {user.profile.full_name}
- Organisation : {user.profile.organization_info}

### Paramètres de l’exemple

```json
{format_json(data.query)}
```
"""


async def github_request(
    client: AsyncClient,
    github_settings: GithubSettings,
    method: str,
    path: str,
    json_body: dict | None = None,
) -> dict:
    response = await client.request(
        method=method,
        url=f"{github_settings.API_URL}/repos/{github_settings.REPOSITORY}/{path}",
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {github_settings.TOKEN}",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        json=json_body,
    )
    if response.is_success:
        return response.json()
    else:
        error_detail = f"GitHub API error ({response.status_code}): {response.text}"
        raise ValidationException(detail=error_detail)


async def create_example_contrib_pr(
    data: ExampleContribCreate,
    github_settings: GithubSettings,
    user: m.User,
) -> ExampleContribResponse:
    description = data.description.strip()
    name = data.name.strip()

    if not name:
        raise ValidationException(detail="Un nom de contribution est requis")
    elif not description:
        raise ValidationException(
            detail="Une description de la contribution est requise"
        )
    elif not github_settings.TOKEN:
        raise ValidationException(
            detail="Le serveur n’est pas configuré pour créer des pull requests"
        )

    examples_path = github_settings.EXAMPLES_PATH_TEMPLATE.format(
        scope=data.scope.value
    )
    example_id = str(uuid4())
    branch_name = f"contrib/{data.scope.value}/{example_id[:8]}"

    pull_request_title = f"feat({data.scope.value}): add “{name}” example"
    pull_request_body = format_example_contrib_pr(data, user)
    commit_message = pull_request_title

    async with AsyncClient(timeout=10) as client:
        base_ref = await github_request(
            client,
            github_settings,
            "GET",
            f"git/ref/heads/{github_settings.BASE_BRANCH}",
        )
        base_sha = base_ref["object"]["sha"]

        # create the branch for the contrib
        await github_request(
            client,
            github_settings,
            "POST",
            "git/refs",
            json_body={"ref": f"refs/heads/{branch_name}", "sha": base_sha},
        )

        # get the target file content to update
        file_content = await github_request(
            client,
            github_settings,
            "GET",
            f"contents/{examples_path}?ref={github_settings.BASE_BRANCH}",
        )
        file_sha = file_content["sha"]
        decoded_content = base64.b64decode(file_content["content"]).decode("utf-8")
        examples = json.loads(decoded_content)

        # append the new example to the examples list
        examples.append(
            {
                "category": "",  # Note: example categories are currently unused
                "id": example_id,
                "name": name,
                "query": data.query,
                "scope": data.scope.value,
            }
        )
        updated_examples_json = format_json(examples)
        updated_examples_base64 = base64.b64encode(
            updated_examples_json.encode("utf-8")
        ).decode("utf-8")

        # commit to the branch
        await github_request(
            client,
            github_settings,
            "PUT",
            f"contents/{examples_path}",
            json_body={
                "message": commit_message,
                "content": updated_examples_base64,
                "branch": branch_name,
                "sha": file_sha,
            },
        )

        # create the pull request
        pull_request = await github_request(
            client,
            github_settings,
            "POST",
            "pulls",
            json_body={
                "title": pull_request_title,
                "head": branch_name,
                "base": github_settings.BASE_BRANCH,
                "body": pull_request_body,
            },
        )

        # assign reviewing team, if any
        if github_settings.REVIEWING_TEAM:
            await github_request(
                client,
                github_settings,
                "POST",
                f"pulls/{pull_request['number']}/requested_reviewers",
                json_body={"team_reviewers": [github_settings.REVIEWING_TEAM]},
            )

    return ExampleContribResponse(
        branch_name=branch_name, pull_request_url=pull_request["html_url"]
    )
