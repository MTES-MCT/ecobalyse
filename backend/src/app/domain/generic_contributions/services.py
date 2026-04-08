from __future__ import annotations

import base64
import json
import os
from uuid import uuid4

from app.db import models as m
from app.domain.generic_contributions.schemas import (
    GenericContributionCreate,
    GenericScope,
)
from httpx import AsyncClient
from litestar.exceptions import ValidationException

SCOPED_EXAMPLES_PATH = {
    GenericScope.FOOD2: "public/data/food2/examples.json",
    GenericScope.OBJECT: "public/data/object/examples.json",
    GenericScope.VELI: "public/data/veli/examples.json",
}


def get_examples_path(scope: GenericScope) -> str:
    return SCOPED_EXAMPLES_PATH[scope]


def get_github_api_url(repo: str, path: str) -> str:
    return f"https://api.github.com/repos/{repo}/{path}"


def clean_str(s: str) -> str:
    return (s or "").strip()


def get_user_full_name(user: m.User) -> str:
    first_name = clean_str(user.profile.first_name)
    last_name = clean_str(user.profile.last_name)
    full_name = clean_str(" ".join([first_name, last_name]))
    if full_name:
        return full_name
    else:
        return "Anonyme"


def format_json_string(json_string: str) -> str:
    # FIXME: this is extracted from the ecobalyse-data repository, we should use a single
    # source for formatting JSON
    return (
        json.dumps(
            json.loads(json_string), ensure_ascii=False, sort_keys=True, indent=2
        )
        + "\n"
    )


def format_pull_request_body(data: GenericContributionCreate, user: m.User) -> str:
    org_name = clean_str(user.profile.organization_name)
    query_as_string = format_json_string(json.dumps(data.query))
    user_full_name = get_user_full_name(user)
    org_info = org_name if org_name else "Non renseignée"
    return "\n".join(
        [
            "## Verticale",
            data.scope.value,
            "",
            "## Contexte",
            clean_str(data.description),
            "",
            "## Contributeur",
            "",
            f"- Nom : {user_full_name}",
            f"- Organisation : {org_info}",
            "",
            "## Données de l‘exemple",
            "```json",
            query_as_string,
            "```",
        ]
    )


async def github_request(
    client: AsyncClient,
    method: str,
    url: str,
    token: str,
    json_body: dict | None = None,
) -> dict:
    response = await client.request(
        method=method,
        url=url,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        json=json_body,
    )
    if response.is_success:
        return response.json()
    else:
        error_detail = f"GitHub API error ({response.status_code}): {response.text}"
        raise ValidationException(detail=error_detail)


async def create_generic_contribution_pr(
    data: GenericContributionCreate,
    user: m.User,
) -> tuple[str, str]:
    description = data.description.strip()
    name = data.name.strip()

    if not name:
        raise ValidationException(detail="Un nom de contribution est requis")
    if not description:
        raise ValidationException(
            detail="Une description de la contribution est requise"
        )

    github_token = os.getenv("GITHUB_TOKEN", "")
    github_repository = os.getenv("GITHUB_REPOSITORY", "MTES-MCT/ecobalyse")
    github_base_branch = os.getenv("GITHUB_BASE_BRANCH", "master")

    if not github_token:
        raise ValidationException(
            detail="Le serveur n’est pas configuré pour créer des pull requests"
        )

    examples_path = get_examples_path(data.scope)
    example_id = str(uuid4())
    branch_name = f"contrib/{data.scope.value}/{example_id[:8]}"

    pull_request_title = f"feat({data.scope.value}): add “{name}” example"
    pull_request_body = format_pull_request_body(data, user)
    commit_message = pull_request_title

    async with AsyncClient(timeout=10) as client:
        base_ref = await github_request(
            client,
            "GET",
            get_github_api_url(
                github_repository, f"git/ref/heads/{github_base_branch}"
            ),
            github_token,
        )
        base_sha = base_ref["object"]["sha"]

        # create the branch for the contrib
        await github_request(
            client,
            "POST",
            get_github_api_url(github_repository, "git/refs"),
            github_token,
            json_body={"ref": f"refs/heads/{branch_name}", "sha": base_sha},
        )

        # get the target file content to update
        file_content = await github_request(
            client,
            "GET",
            get_github_api_url(
                github_repository, f"contents/{examples_path}?ref={github_base_branch}"
            ),
            github_token,
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
        updated_examples_json = format_json_string(json.dumps(examples))
        updated_examples_base64 = base64.b64encode(
            updated_examples_json.encode("utf-8")
        ).decode("utf-8")

        # commit to the branch
        await github_request(
            client,
            "PUT",
            get_github_api_url(github_repository, f"contents/{examples_path}"),
            github_token,
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
            "POST",
            get_github_api_url(github_repository, "pulls"),
            github_token,
            json_body={
                "title": pull_request_title,
                "head": branch_name,
                "base": github_base_branch,
                "body": pull_request_body,
            },
        )

    return branch_name, pull_request["html_url"]
