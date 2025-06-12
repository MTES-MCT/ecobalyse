from litestar.connection.request import Request


def get_host(request: Request) -> None | str:
    host = dict(request.scope.get("headers", [])).get(b"host")

    if host:
        return host.decode("utf-8")


def get_scheme(request: Request) -> None | str:
    return request.scope.get("scheme")


def get_base_url(request: Request) -> None | str:
    host = get_host(request)
    scheme = get_scheme(request)
    return f"{scheme}://{host}"
