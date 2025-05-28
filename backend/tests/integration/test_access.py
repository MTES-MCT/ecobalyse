import urllib
from typing import Any

import pytest
from httpx import AsyncClient
from litestar.exceptions import PermissionDeniedException
from sqlalchemy.ext.asyncio import (
    AsyncSession,
)
from structlog.testing import capture_logs

from app.config import get_settings
from app.db.models import User
from app.domain.accounts.services import TokenService, UserService

pytestmark = pytest.mark.anyio


@pytest.mark.parametrize(
    ("email", "should_send_email", "expected_status_code"),
    (
        ("superuser@example.com", True, 201),
        ("bademail@test.com", False, 201),
    ),
)
async def test_user_magic_link_login(
    client: AsyncClient, email: str, should_send_email: bool, expected_status_code: int
) -> None:
    with capture_logs() as cap_logs:
        response = await client.post(
            "/api/access/magic_link/login", json={"email": email}
        )
        assert response.status_code == expected_status_code

    if should_send_email:
        settings = get_settings()
        assert any(
            ["demandé un lien de connexion à Ecobalyse" in e["event"] for e in cap_logs]
        )
        assert any(
            [
                f'<p><a href="{settings.email.MAGIC_LINK_URL}/{urllib.parse.quote_plus(email)}/'
                in e["event"]
                for e in cap_logs
            ]
        )
    else:
        assert not any(
            ["demandé un lien de connexion à Ecobalyse" in e["event"] for e in cap_logs]
        )


@pytest.mark.parametrize(
    ("email", "token", "expected_status_code"),
    (
        ("superuser@example1.com", "Test_Password1!_token", 403),
        ("superuser@example.com", "Test_Password1!_token", 201),
        ("user@example.com", "Test_Password1!_token", 403),
        ("user@example.com", "Test_Password2!_token", 201),
        ("inactive@example.com", "Old_Password2!_token", 403),
        ("inactive@example.com", "Old_Password3!_token", 403),
    ),
)
async def test_user_magic_link_validation(
    client: AsyncClient, email: str, token: str, expected_status_code: int
) -> None:
    response = await client.get(
        "/api/access/login", params={"email": email, "token": token}
    )
    assert response.status_code == expected_status_code


async def test_user_login_token_expiration(client: AsyncClient) -> None:
    email = "superuser@example.com"
    token = "Test_Password1!_token"

    response = await client.get(
        "/api/access/login", params={"email": email, "token": token}
    )

    assert response.status_code == 201
    json = response.json()

    assert "access_token" in json
    # Two year expiration
    assert json["expires_in"] == 60 * 60 * 24 * 365 * 2


async def test_user_cant_use_same_token_twice(
    client: AsyncClient,
) -> None:
    email = "superuser@example.com"
    token = "Test_Password1!_token"

    response = await client.get(
        "/api/access/login", params={"email": email, "token": token}
    )

    assert response.status_code == 201

    response = await client.get(
        "/api/access/login", params={"email": email, "token": token}
    )

    assert response.status_code == 403


@pytest.mark.parametrize(
    ("email", "token"),
    (("superuser@example.com", "Test_Password1!_token"),),
)
async def test_user_logout(client: AsyncClient, email: str, token: str) -> None:
    response = await client.get(
        "/api/access/login", params={"email": email, "token": token}
    )
    assert response.status_code == 201
    cookies = dict(response.cookies)

    assert cookies.get("token") is not None

    me_response = await client.get("/api/me")
    assert me_response.status_code == 200

    response = await client.post("/api/access/logout")
    assert response.status_code == 200

    # the user can no longer access the /me route.
    me_response = await client.get("/api/me")
    assert me_response.status_code == 401


async def test_user_profile(
    client: "AsyncClient", user_token_headers: dict[str, str]
) -> None:
    response = await client.get(
        "/api/me",
        headers=user_token_headers,
    )
    assert response.status_code == 200
    json = response.json()

    assert json == {
        "id": json["id"],
        "email": "user@example.com",
        "profile": {
            "emailOptin": False,
            "firstName": "Example",
            "lastName": "User",
            "organization": {
                "name": "Example business organization",
                "siren": "901518415",
                "type": "business",
            },
            "termsAccepted": False,
        },
        "roles": [],
        "isSuperuser": False,
        "isActive": True,
        "isVerified": False,
        "magicLinkSentAt": json["magicLinkSentAt"],
    }


async def test_user_update_profile(
    client: "AsyncClient", user_token_headers: dict[str, str]
) -> None:
    response = await client.patch(
        "/api/me",
        headers=user_token_headers,
        json={"firstName": "test1", "emailOptin": True},
    )
    assert response.status_code == 200
    json = response.json()

    assert json == {
        "id": json["id"],
        "email": "user@example.com",
        "profile": {
            "emailOptin": True,
            "firstName": "test1",
            "lastName": "User",
            "organization": {
                "name": "Example business organization",
                "siren": "901518415",
                "type": "business",
            },
            "termsAccepted": False,
        },
        "roles": [],
        "isSuperuser": False,
        "isActive": True,
        "isVerified": False,
        "magicLinkSentAt": json["magicLinkSentAt"],
    }

    response = await client.patch(
        "/api/me",
        headers=user_token_headers,
        json={"emailOptin": False},
    )
    assert response.status_code == 200
    json = response.json()
    assert not json["profile"]["emailOptin"]


async def test_user_signup_and_login(
    client: "AsyncClient",
    superuser_token_headers: dict[str, str],
) -> None:
    with capture_logs() as cap_logs:
        # Don’t accept the terms
        user_data = {
            "email": "foo@bar.com",
            "firstName": "first name test",
            "lastName": "last name test",
            "organization": {"type": "individual"},
        }
        response = await client.post(
            "/api/access/magic_link/signup",
            json=user_data,
        )

        assert (
            "You need to explicitly accept terms"
            in response.json()["extra"][0]["message"]
        )
        assert response.status_code == 400

        # Don’t provide a NAME
        user_data = {
            "email": "foo@bar.com",
            "firstName": "first name test",
            "lastName": "last name test",
            "organization": {"type": "business"},
        }
        response = await client.post(
            "/api/access/magic_link/signup",
            json=user_data,
        )
        assert (
            "You need to provide an organization name"
            in response.json()["extra"][0]["message"]
        )

        assert response.status_code == 400

        user_data["organization"]["name"] = "Org name"

        # Don’t provide a SIREN
        response = await client.post(
            "/api/access/magic_link/signup",
            json=user_data,
        )
        assert (
            "You need to provide a SIREN number for a business"
            in response.json()["extra"][0]["message"]
        )

        assert response.status_code == 400

        # Bad SIREN
        user_data["organization"]["siren"] = "222222"

        response = await client.post(
            "/api/access/magic_link/signup",
            json=user_data,
        )
        assert "SIREN format is invalid" in response.json()["extra"][0]["message"]

        assert response.status_code == 400

        # Good SIREN
        user_data["organization"]["siren"] = "901518415"

        # Accept the terms
        user_data["termsAccepted"] = True

        response = await client.post(
            "/api/access/magic_link/signup",
            json=user_data,
        )

        json = response.json()

        assert response.status_code == 201

        assert json == {
            "id": json["id"],
            "email": "foo@bar.com",
            "profile": {
                "emailOptin": False,
                "firstName": "first name test",
                "lastName": "last name test",
                "organization": {
                    "name": "Org name",
                    "siren": "901518415",
                    "type": "business",
                },
                "termsAccepted": True,
            },
            "isSuperuser": False,
            "isActive": True,
            "isVerified": False,
            "magicLinkSentAt": None,
            "roles": [
                {
                    "roleId": json["roles"][0]["roleId"],
                    "roleSlug": "application-access",
                    "roleName": "Application Access",
                    "assignedAt": json["roles"][0]["assignedAt"],
                }
            ],
        }

        # Valid individual
        user_data = {
            "email": "foo2@bar.com",
            "firstName": "first name test",
            "lastName": "last name test",
            "organization": {"type": "individual"},
            "termsAccepted": True,
            "emailOptin": True,
        }
        response = await client.post(
            "/api/access/magic_link/signup",
            json=user_data,
        )

        assert response.status_code == 201
        assert response.json()["profile"]["emailOptin"]

        user_data = {
            "email": "foo@bar.com",
            "firstName": "first name test",
            "lastName": "last name test",
            "organization": {"type": "individual"},
            "termsAccepted": True,
        }
        response = await client.post(
            "/api/access/magic_link/signup",
            json=user_data,
        )

        assert response.status_code == 409

    assert {
        "event": "Sending magic link email to foo@bar.com",
        "log_level": "debug",
    } in cap_logs


async def test_magic_link_expiration(
    session: AsyncSession,
    raw_users: list[User | dict[str, Any]],
) -> None:
    async with UserService.new(session) as users_service:
        # Magic link login is ok
        authenticated_user = await users_service.authenticate_magic_token(
            raw_users[1]["email"], "Test_Password2!_token"
        )
        assert authenticated_user.magic_link_sent_at is None
        assert authenticated_user.magic_link_hashed_token is None

        # Magic link is outdated 24H duration by default
        with pytest.raises(PermissionDeniedException, match="Magic link token expired"):
            authenticated_user = await users_service.authenticate_magic_token(
                raw_users[2]["email"], "Test_Password3!_token"
            )

        # Magic link was not generated
        with pytest.raises(
            PermissionDeniedException, match="User not found or password invalid"
        ):
            authenticated_user = await users_service.authenticate_magic_token(
                raw_users[3]["email"], ""
            )


async def test_token_generation(
    session: AsyncSession,
    client: "AsyncClient",
    raw_users: list[User | dict[str, Any]],
) -> None:
    token = None

    async with TokenService.new(session) as token_service:
        async with UserService.new(session) as users_service:
            first_user = raw_users[0]
            secret = "test_secret"
            user = await users_service.get_one_or_none(email=first_user["email"])
            token = await token_service.generate_for_user(user, secret=secret)

            db_token = (await token_service.repository.list())[-1]

            assert token.startswith(
                "eco_api_eyJlbWFpbCI6ICJzdXBlcnVzZXJAZXhhbXBsZS5jb20iLCAiaWQiOiAi"
            )

            payload = await token_service.extract_payload(token)

            assert payload == {
                "email": user.email,
                "id": str(db_token.id),
                "secret": secret,
            }

            assert await token_service.authenticate(secret=secret, token_id=db_token.id)

            with pytest.raises(PermissionDeniedException, match="Invalid token"):
                await token_service.authenticate(
                    secret="bad_secret", token_id=db_token.id
                )

            await token_service.repository.session.commit()

    data = {
        "token": token,
    }
    response = await client.post(
        "/api/tokens/validate",
        json=data,
    )

    assert response.status_code == 201

    bad_data = {
        "token": "bad_token",
    }
    response = await client.post(
        "/api/tokens/validate",
        json=bad_data,
    )

    assert response.status_code == 403


async def test_generate_token_endpoint(
    session: AsyncSession,
    client: "AsyncClient",
    user_token_headers: dict[str, str],
    superuser_token_headers: dict[str, str],
) -> None:
    response = await client.post(
        "/api/tokens",
        headers=user_token_headers,
    )

    assert response.status_code == 201
    data = response.json()
    token = data["token"]
    assert token.startswith("eco_api_eyJlbWFpbCI6ICJ")

    # Generate 2 tokens in total in the db
    response = await client.post(
        "/api/tokens",
        headers=superuser_token_headers,
    )

    assert response.status_code == 201
    data = response.json()
    assert token.startswith("eco_api_eyJlbWFpbCI6ICJ")

    # We need to be authentified
    response = await client.post(
        "/api/tokens",
    )

    assert response.status_code == 401

    response = await client.get(
        "/api/tokens",
        headers=user_token_headers,
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["id"] is not None
    assert data[0]["lastAccessedAt"] is None

    # Use the token once
    response = await client.post(
        "/api/tokens/validate",
        json={"token": token},
    )

    response = await client.get(
        "/api/tokens",
        headers=user_token_headers,
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["id"] is not None
    assert data[0]["lastAccessedAt"] is not None


async def test_token_delete(
    client: "AsyncClient",
    superuser_token_headers: dict[str, str],
    user_token_headers: dict[str, str],
) -> None:
    response = await client.post(
        "/api/tokens",
        headers=user_token_headers,
    )

    assert response.status_code == 201

    # Generate 2 tokens in total in the db
    response = await client.post(
        "/api/tokens",
        headers=superuser_token_headers,
    )

    assert response.status_code == 201

    response = await client.get(
        "/api/tokens",
        headers=superuser_token_headers,
    )

    data = response.json()
    superuser_token_id = data[0]["id"]

    response = await client.get(
        "/api/tokens",
        headers=user_token_headers,
    )

    assert response.status_code == 200
    data = response.json()
    user_token_id = data[0]["id"]

    response = await client.delete(
        "/api/tokens/" + superuser_token_id,
        headers=user_token_headers,
    )
    assert response.status_code == 403

    response = await client.delete(
        "/api/tokens/" + user_token_id,
        headers=user_token_headers,
    )
    assert response.status_code == 200
    assert response.json() is None


async def test_token_validation(
    session: AsyncSession,
    client: "AsyncClient",
    user_token_headers: dict[str, str],
    raw_users: list[User | dict[str, Any]],
) -> None:
    response = await client.post(
        "/api/tokens",
        headers=user_token_headers,
    )

    assert response.status_code == 201
    data = response.json()
    token = data["token"]
    assert token.startswith("eco_api_eyJlbWFpbCI6ICJ")

    # Validate API token for user
    response = await client.post(
        "/api/tokens/validate",
        json=data,
    )

    assert response.status_code == 201

    bearer_token = user_token_headers["Authorization"].replace("Bearer ", "")

    # Validate Bearer token for user
    response = await client.post(
        "/api/tokens/validate",
        json={"token": bearer_token},
    )

    assert response.status_code == 201

    response = await client.post(
        "/api/tokens/validate",
        json={"token": bearer_token + "bad"},
    )

    assert response.status_code == 403
