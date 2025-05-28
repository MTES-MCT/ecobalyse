from __future__ import annotations

import datetime
import urllib.parse

import emails
import structlog
from emails.template import JinjaTemplate as T
from litestar.events import listener

from app.config import get_settings
from app.config.app import alchemy
from app.db.models import User
from app.domain.accounts.deps import provide_users_service

logger = structlog.get_logger()


@listener("send_magic_link_email")
async def send_magic_link_email_event_handler(user: User, token: str) -> None:
    """Executes when a login link is asked

    Args:
        email: The email we should send the magic link to
    """
    await logger.adebug(f"Sending magic link email to {user.email}")
    settings = get_settings()

    message = emails.html(
        subject=T("Lien de connexion à Ecobalyse"),
        html=T(
            """<p>Vous avez reçu cet e-mail car vous avez demandé un lien de connexion à Ecobalyse.</p>
            <p>Veuillez cliquer sur le lien suivant pour vous connecter :</p>
            <p><a href="{{ url }}/{{ email }}/{{ token }}">Se connecter à Ecobalyse</a></p>
            <p>L'équipe Ecobalyse</p>"""
        ),
        text=T("""Vous avez reçu cet e-mail car vous avez demandé un lien de connexion à Ecobalyse.
            Veuillez cliquer sur le lien suivant pour vous connecter : {{ url }}/{{ email }}/{{ token }}
            L'équipe Ecobalyse"""),
        mail_from=("Ecobalyse", settings.email.FROM),
    )

    message.send(
        to=("Test user", user.email),
        render={
            "email": urllib.parse.quote_plus(user.email),
            "token": urllib.parse.quote_plus(token),
            "url": settings.email.MAGIC_LINK_URL,
        },
    )

    await logger.adebug(f"{message.html_body}")

    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))
        user = await users_service.get_one_or_none(id=user.id)
        user.magic_link_sent_at = datetime.datetime.now(datetime.timezone.utc)

        await users_service.update(item_id=user.id, data=user.to_dict())
        await db_session.commit()

    if not settings.email.SERVER_HOST:
        await logger.adebug("No email SERVER_HOST configured don’t send the email.")
    else:
        await logger.adebug(
            f"Sending the email using SMTP {settings.email.SERVER_HOST} and user {settings.email.SERVER_USER}"
        )
        message.send(
            to=user.email,
            smtp={
                "host": settings.email.SERVER_HOST,
                "user": settings.email.SERVER_USER,
                "port": settings.email.SERVER_PORT,
                "password": settings.email.SERVER_PASSWORD,
                "timeout": settings.email.SERVER_TIMEOUT,
                "tls": settings.email.SERVER_USE_TLS,
                "fail_silently": False,
            },
        )
