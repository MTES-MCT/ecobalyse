# Ecobalyse Backoffice

## Requirements

- [uv](https://docs.astral.sh/uv/) for Python (it will manage the Python install for you)
- [docker](https://www.docker.com/) for the PostgreSQL database

The web framework used is [Litestar](https://litestar.dev/).

## Install Python dependencies

```bash
uv sync
```

## Database

You can run the container by hand with:

```
docker compose up -d
```

Or you can let `npm run start:dev` do it for you.

### Specify database DSN by hand

You can set the `DATABASE_URL` environment variable to a PostgreSQL DSN (specifying the `asyncpg` driver) if you don’t want to use the default docker database.

For example:

```bash
export DATABASE_URL=postgresql+asyncpg://vjousse@localhost/ecobalyse-data
```

### Migrate to latest version

```bash
uv run backend database upgrade --no-prompt
```

## Run the dev server

```bash
uv run backend run --reload
```

Calling `http://localhost:8000/health` should give you the following JSON:

```json
{
    "database_status":"online",
    "app":"app",
    "version":"0.0.1"
}
```

## Reset DB and load fixtures

If you want you can first reset your docker DB and load the dev fixtures by running this script:

```bash
./bin/reset-docker-db.sh
```

## Backend CLI

### Get all possible commands

```bash
un run backend --help
```
### Get help on a specific command

```bash
un run backend users --help
```

## OpenAPI documentation

[http://localhost:8000/schema](http://localhost:8000/schema)
