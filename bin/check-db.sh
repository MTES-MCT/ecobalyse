#!/usr/bin/env bash

CONTAINER_NAME="ecobalyse_dev_db"

DB_ENV_VAR_NAME="DATABASE_URL"

# Check if the db variable is not set
if [ -z "${!DB_ENV_VAR_NAME}" ]; then
  # Set the environment variable
  export DATABASE_URL="postgresql+asyncpg://ecobalyse@localhost:5433/ecobalyse_dev"
  echo "$DB_ENV_VAR_NAME was not set. It has been set to '$DATABASE_URL'."
else
  echo "$DB_ENV_VAR_NAME is already set to '${!DB_ENV_VAR_NAME}'."
fi

# Extract the port from the DATABASE_URL
PORT=$(echo $DATABASE_URL | sed -n 's/.*:\([0-9]*\).*/\1/p')
# Extract the host from the DATABASE_URL
HOST=$(echo $DATABASE_URL | sed -n 's/.*@\(.*\):\(.*\).*/\1/p')

# Check if the PostgreSQL server is up and running using bash /dev/tcp internals
if (echo > /dev/tcp/"$HOST"/"$PORT") >/dev/null 2>&1; then
  echo "✅ PostgreSQL server is up and running on host $HOST and port $PORT."
  exit 0
else
  echo "🔴 PostgreSQL server is not reachable on host $HOST and port $PORT."

  if [ "$( docker container inspect -f '{{.State.Status}}' $CONTAINER_NAME )" != "running" ]; then
    echo "ℹ️ Docker container '$CONTAINER_NAME' is not running, trying to start it in the background."
    docker compose up -d
    exit 0
  fi

  exit 1
fi
