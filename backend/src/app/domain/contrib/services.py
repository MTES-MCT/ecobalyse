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
    GenericScope,
)
from httpx import AsyncClient
from litestar.exceptions import ValidationException

logger = structlog.get_logger()


def get_examples_path(scope: GenericScope) -> str:
    return f"public/data/{scope.value}/examples.json"


def get_github_api_url(repo: str, path: str) -> str:
    return f"https://api.github.com/repos/{repo}/{path}"


def clean_str(s: str, fallback: str = "") -> str:
    return (s or fallback).strip()


def get_user_full_name(profile: m.UserProfile) -> str:
    first_name = clean_str(profile.first_name)
    last_name = clean_str(profile.last_name)
    return clean_str(" ".join([first_name, last_name]), "Anonyme")


def format_json_string(json_string: str) -> str:
    # Note:  these files are ignored by prettier, so we're safe from formatting conflicts
    # FIXME: this is extracted from the ecobalyse-data repository, we should use a single
    #        source for formatting JSON
    return (
        json.dumps(
            json.loads(json_string), ensure_ascii=False, sort_keys=True, indent=2
        )
        + "\n"
    )


def format_example_contrib_pr(data: ExampleContribCreate, user: m.User) -> str:
    org_name = clean_str(user.profile.organization_name)
    query_as_string = format_json_string(json.dumps(data.query))
    user_full_name = get_user_full_name(user.profile)
    org_info = org_name if org_name else "Non renseignée"
    return "\n".join(
        [
            f"Nouvelle proposition de contribution d’exemple : **{data.name} ({data.scope.value})**",
            "",
            "### Contexte",
            clean_str(data.description),
            "",
            "### Contributeur",
            "",
            f"- Nom : {user_full_name}",
            f"- Organisation : {org_info}",
            "",
            "### Paramètres de l’exemple",
            "```json",
            query_as_string,
            "```",
        ]
    )


async def github_request(
    client: AsyncClient,
    github_settings: GithubSettings,
    method: str,
    path: str,
    json_body: dict | None = None,
) -> dict:
    response = await client.request(
        method=method,
        url=get_github_api_url(github_settings.REPOSITORY, path),
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

    examples_path = get_examples_path(data.scope)
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
        updated_examples_json = format_json_string(json.dumps(examples))
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
