from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import timedelta
from typing import (
    TYPE_CHECKING,
    Any,
    Callable,
    Generic,
    Iterable,
    Literal,
    Sequence,
    cast,
)

from app.lib.middleware.custom_auth_middleware import CustomAuthMiddleware
from litestar.enums import MediaType
from litestar.middleware import DefineMiddleware
from litestar.openapi.spec import Components, OAuthFlow, OAuthFlows, SecurityScheme
from litestar.security.jwt import (
    BaseJWTAuth,
    OAuth2Login,
)
from litestar.security.jwt.token import Token
from litestar.status_codes import HTTP_201_CREATED
from litestar.types import (
    ControllerRouterHandler,
    Empty,
    Guard,
    Method,
    Scopes,
    SyncOrAsyncUnion,
    TypeEncodersMap,
)
from typing_extensions import TypeVar

__all__ = ("OAuth2PasswordBearerAuth",)


if TYPE_CHECKING:
    from litestar import Response
    from litestar.connection import ASGIConnection
    from litestar.di import Provide


UserType = TypeVar("UserType")
TokenT = TypeVar("TokenT", bound=Token, default=Token)


@dataclass
class OAuth2PasswordBearerAuth(
    Generic[UserType, TokenT], BaseJWTAuth[UserType, TokenT]
):
    """OAUTH2 Schema for Password Bearer Authentication.

    This class implements an OAUTH2 authentication flow entry point to the library, and it includes all the
    functionality of the :class:`JWTAuth` class and adds support for passing JWT tokens ``HttpOnly`` cookies.

    ``token_url`` is the only additional argument that is required, and it should point at your login route
    """

    token_secret: str
    """Key with which to generate the token hash.

    Notes:
        - This value should be kept as a secret and the standard practice is to inject it into the environment.
    """
    token_url: str
    """The URL for retrieving a new token."""
    retrieve_user_handler: Callable[[Any, ASGIConnection], SyncOrAsyncUnion[Any | None]]
    """Callable that receives the ``auth`` value from the authentication middleware and returns a ``user`` value.

    Notes:
        - User and Auth can be any arbitrary values specified by the security backend.
        - The User and Auth values will be set by the middleware as ``scope["user"]`` and ``scope["auth"]`` respectively.
          Once provided, they can access via the ``connection.user`` and ``connection.auth`` properties.
        - The callable can be sync or async. If it is sync, it will be wrapped to support async.

    """
    revoked_token_handler: (
        Callable[[Any, ASGIConnection], SyncOrAsyncUnion[bool]] | None
    ) = field(default=None)
    """Callable that receives the auth value from the authentication middleware and checks whether the token has been revoked,
    returning True if revoked, False otherwise."""
    guards: Iterable[Guard] | None = field(default=None)
    """An iterable of guards to call for requests, providing authorization functionalities."""
    exclude: str | list[str] | None = field(default=None)
    """A pattern or list of patterns to skip in the authentication middleware."""
    exclude_opt_key: str = field(default="exclude_from_auth")
    """An identifier to use on routes to disable authentication and authorization checks for a particular route."""
    exclude_http_methods: Sequence[Method] | None = field(
        default_factory=lambda: cast("Sequence[Method]", ["OPTIONS", "HEAD"])
    )
    """A sequence of http methods that do not require authentication. Defaults to ['OPTIONS', 'HEAD']"""
    scopes: Scopes | None = field(default=None)
    """ASGI scopes processed by the authentication middleware, if ``None``, both ``http`` and ``websocket`` will be
    processed."""
    route_handlers: Iterable[ControllerRouterHandler] | None = field(default=None)
    """An optional iterable of route handlers to register."""
    dependencies: dict[str, Provide] | None = field(default=None)
    """An optional dictionary of dependency providers."""
    type_encoders: TypeEncodersMap | None = field(default=None)
    """A mapping of types to callables that transform them into types supported for serialization."""
    algorithm: str = field(default="HS256")
    """Algorithm to use for JWT hashing."""
    auth_header: str = field(default="Authorization")
    """Request header key from which to retrieve the token.

    E.g. ``Authorization`` or 'X-Api-Key'.
    """
    default_token_expiration: timedelta = field(
        default_factory=lambda: timedelta(days=1)
    )
    """The default value for token expiration."""
    openapi_security_scheme_name: str = field(default="BearerToken")
    """The value to use for the OpenAPI security scheme and security requirements."""
    oauth_scopes: dict[str, str] | None = field(default=None)
    """Oauth Scopes available for the token."""
    key: str = field(default="token")
    """Key for the cookie."""
    path: str = field(default="/")
    """Path fragment that must exist in the request url for the cookie to be valid.

    Defaults to ``/``.
    """
    domain: str | None = field(default=None)
    """Domain for which the cookie is valid."""
    secure: bool | None = field(default=None)
    """Https is required for the cookie."""
    samesite: Literal["lax", "strict", "none"] = field(default="lax")
    """Controls whether or not a cookie is sent with cross-site requests. Defaults to ``lax``. """
    description: str = field(
        default="OAUTH2 password bearer authentication and authorization."
    )
    """Description for the OpenAPI security scheme."""
    authentication_middleware_class: type[CustomAuthMiddleware] = field(  # pyright: ignore
        default=CustomAuthMiddleware
    )
    """The authentication middleware class to use.

    Must inherit from :class:`JWTCookieAuthenticationMiddleware`
    """
    token_cls: type[Token] = Token
    """Target type the JWT payload will be converted into"""
    accepted_audiences: Sequence[str] | None = None
    """Audiences to accept when verifying the token. If given, and the audience in the
    token does not match, a 401 response is returned
    """
    accepted_issuers: Sequence[str] | None = None
    """Issuers to accept when verifying the token. If given, and the issuer in the
    token does not match, a 401 response is returned
    """
    require_claims: Sequence[str] | None = None
    """Require these claims to be present in the JWT payload. If any of those claims
    is missing, a 401 response is returned
    """
    verify_expiry: bool = True
    """Verify that the value of the ``exp`` (*expiration*) claim is in the future"""
    verify_not_before: bool = True
    """Verify that the value of the ``nbf`` (*not before*) claim is in the past"""
    strict_audience: bool = False
    """Verify that the value of the ``aud`` (*audience*) claim is a single value, and
    not a list of values, and matches ``audience`` exactly. Requires that
    ``accepted_audiences`` is a sequence of length 1
    """

    @property
    def middleware(self) -> DefineMiddleware:
        """Create ``JWTCookieAuthenticationMiddleware`` wrapped in
            :class:`DefineMiddleware <.middleware.base.DefineMiddleware>`.

        Returns:
            An instance of :class:`DefineMiddleware <.middleware.base.DefineMiddleware>`.
        """
        return DefineMiddleware(
            self.authentication_middleware_class,
            algorithm=self.algorithm,
            auth_header=self.auth_header,
            exclude=self.exclude,
            exclude_opt_key=self.exclude_opt_key,
            exclude_http_methods=self.exclude_http_methods,
            retrieve_user_handler=self.retrieve_user_handler,
            revoked_token_handler=self.revoked_token_handler,
            scopes=self.scopes,
            token_secret=self.token_secret,
            token_cls=self.token_cls,
            token_issuer=self.accepted_issuers,
            token_audience=self.accepted_audiences,
            require_claims=self.require_claims,
            verify_expiry=self.verify_expiry,
            verify_not_before=self.verify_not_before,
            strict_audience=self.strict_audience,
        )

    @property
    def oauth_flow(self) -> OAuthFlow:
        """Create an OpenAPI OAuth2 flow for the password bearer authentication scheme.

        Returns:
            An :class:`OAuthFlow <litestar.openapi.spec.oauth_flow.OAuthFlow>` instance.
        """
        return OAuthFlow(
            token_url=self.token_url,
            scopes=self.oauth_scopes,
        )

    @property
    def openapi_components(self) -> Components:
        """Create OpenAPI documentation for the OAUTH2 Password bearer auth scheme.

        Returns:
            An :class:`Components <litestar.openapi.spec.components.Components>` instance.
        """
        return Components(
            security_schemes={
                self.openapi_security_scheme_name: SecurityScheme(
                    type="oauth2",
                    scheme="Bearer",
                    name=self.auth_header,
                    security_scheme_in="header",
                    flows=OAuthFlows(password=self.oauth_flow),  # pyright: ignore[reportGeneralTypeIssues]
                    bearer_format="JWT",
                    description=self.description,
                )
            }
        )

    def login(
        self,
        identifier: str,
        *,
        response_body: Any = Empty,
        response_media_type: str | MediaType = MediaType.JSON,
        response_status_code: int = HTTP_201_CREATED,
        token_expiration: timedelta | None = None,
        token_issuer: str | None = None,
        token_audience: str | None = None,
        token_unique_jwt_id: str | None = None,
        token_extras: dict[str, Any] | None = None,
        send_token_as_response_body: bool = True,
    ) -> Response[Any]:
        """Create a response with a JWT header.

        Args:
            identifier: Unique identifier of the token subject. Usually this is a user ID or equivalent kind of value.
            response_body: An optional response body to send.
            response_media_type: An optional ``Content-Type``. Defaults to ``application/json``.
            response_status_code: An optional status code for the response. Defaults to ``201``.
            token_expiration: An optional timedelta for the token expiration.
            token_issuer: An optional value of the token ``iss`` field.
            token_audience: An optional value for the token ``aud`` field.
            token_unique_jwt_id: An optional value for the token ``jti`` field.
            token_extras: An optional dictionary to include in the token ``extras`` field.
            send_token_as_response_body: If ``True`` the response will be an oAuth2 token response dict.
                Note: if a response body is passed this setting will be ignored.

        Returns:
            A :class:`Response <.response.Response>` instance.
        """
        encoded_token = self.create_token(
            identifier=identifier,
            token_expiration=token_expiration,
            token_issuer=token_issuer,
            token_audience=token_audience,
            token_unique_jwt_id=token_unique_jwt_id,
            token_extras=token_extras,
        )
        expires_in = int(
            (token_expiration or self.default_token_expiration).total_seconds()
        )

        if response_body is not Empty:
            body = response_body
        elif send_token_as_response_body:
            token_dto = OAuth2Login(
                access_token=encoded_token,
                expires_in=expires_in,
                token_type="bearer",  # noqa: S106
            )
            body = asdict(token_dto)
        else:
            body = None

        return self.create_response(
            content=body,
            headers={self.auth_header: self.format_auth_header(encoded_token)},
            cookies=[],
            media_type=response_media_type,
            status_code=response_status_code,
        )
