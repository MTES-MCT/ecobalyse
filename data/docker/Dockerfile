# https://docs.astral.sh/uv/guides/integration/docker/#getting-started
FROM ghcr.io/astral-sh/uv:trixie-slim
RUN export DEBIAN_FRONTEND="noninteractive" && apt-get update && apt-get upgrade -y && apt-get install gosu just
RUN useradd -m -s /bin/bash -d /app eb

USER eb
WORKDIR /app

COPY pyproject.toml uv.lock* ./
ENV UV_LINK_MODE=copy
RUN --mount=type=cache,target=/root/.cache/uv uv sync --locked --compile-bytecode

# TODO: we could copy everything, and then rely on a `.dockerignore` file to exclude the
# uneeded files, but as long as the repository is not reorganized, it’s easier and clearer
# to do it in this “opt-in” way.
COPY justfile settings.toml *.py activities_to_create.json simapro-biosphere.json impacts.json /app
COPY lci_catalog /app/lci_catalog
COPY --exclude=**/__pycache__ bin /app/bin
COPY --exclude=**/__pycache__ common /app/common
COPY --exclude=**/__pycache__ ecobalyse_data /app/ecobalyse_data
COPY --exclude=**/__pycache__ food /app/food
COPY --exclude=**/__pycache__ models /app/models
COPY public /app/public
COPY docker/entrypoint.sh ./

USER root
ENTRYPOINT ["./entrypoint.sh"]
