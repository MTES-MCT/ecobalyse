from __future__ import annotations

from dataclasses import dataclass
from typing import (
    TYPE_CHECKING,
    Any,
    Generic,
)

from litestar import Response
from litestar.security.jwt import (
    BaseJWTAuth,
    OAuth2PasswordBearerAuth,
)
from litestar.security.jwt.token import Token
from typing_extensions import TypeVar

if TYPE_CHECKING:
    from litestar.enums import MediaType, OpenAPIMediaType
    from litestar.types import (
        ResponseCookies,
    )

UserType = TypeVar("UserType")
AuthType = TypeVar("AuthType")

__all__ = ("CustomOAuth2PasswordBearerAuth",)


UserType = TypeVar("UserType")
TokenT = TypeVar("TokenT", bound=Token, default=Token)


@dataclass
class CustomOAuth2PasswordBearerAuth(
    OAuth2PasswordBearerAuth, Generic[UserType, TokenT], BaseJWTAuth[UserType, TokenT]
):
    def create_response(
        self,
        content: Any | None,
        status_code: int,
        media_type: MediaType | OpenAPIMediaType | str,
        headers: dict[str, Any] | None = None,
        cookies: ResponseCookies | None = None,
    ) -> Response[Any]:
        """Create a response object.

        Handles setting the type encoders mapping on the response.

        Args:
            content: A value for the response body that will be rendered into bytes string.
            status_code: An HTTP status code.
            media_type: A value for the response 'Content-Type' header.
            headers: A string keyed dictionary of response headers. Header keys are insensitive.
            cookies: A list of :class:`Cookie <litestar.datastructures.Cookie>` instances to be set under
                the response 'Set-Cookie' header.

        Returns:
            A response object.
        """

        # Remove cookies from response
        return Response(
            content=content,
            status_code=status_code,
            media_type=media_type,
            headers=headers,
            cookies=[],
            type_encoders=self.type_encoders,
        )
