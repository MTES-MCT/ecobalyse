from __future__ import annotations

import datetime
import urllib.parse
from uuid import UUID

import emails
import structlog
from app.config import get_settings
from app.config.app import alchemy
from app.domain.accounts.deps import provide_users_service
from emails.template import JinjaTemplate as T

logger = structlog.get_logger()


async def send_magic_link_email_task(
    user_id: UUID, user_email: str, token: str
) -> None:
    """Executes when a login link is asked

    Args:
        email: The email we should send the magic link to
    """
    await logger.adebug(f"Sending magic link email to {user_email}")
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
        to=("Test user", user_email),
        render={
            "email": urllib.parse.quote_plus(user_email),
            "token": urllib.parse.quote_plus(token),
            "url": settings.email.MAGIC_LINK_URL,
        },
    )

    await logger.adebug(f"{message.html_body}")

    async with alchemy.get_session() as db_session:
        users_service = await anext(provide_users_service(db_session))
        user = await users_service.get_one_or_none(id=user_id)
        user.magic_link_sent_at = datetime.datetime.now(datetime.timezone.utc)

        await users_service.update(item_id=user.id, data=user.to_dict())

        await logger.adebug(
            f"Sending the email using SMTP {settings.email.SERVER_HOST}"
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
