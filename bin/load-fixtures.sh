#!/usr/bin/env bash

ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
cd $ROOT_DIR

# Fix outdated Scalingo DSN to be compatible with asyncpg
export DATABASE_URL=$(echo "$DATABASE_URL" | sed -e 's/postgres/postgresql+asyncpg/' -e 's/sslmode=prefer/ssl=prefer/')

if [ "$IS_REVIEW_APP" == "true" ]; then
   echo "-> In review app, resetting DB";
   uv run backend database drop-all --no-prompt
   uv run backend database upgrade --no-prompt
   echo "-> Loading components fixtures";
   uv run backend users create-default-user
   uv run backend fixtures load-processes public/data/processes_impacts.json
   uv run backend fixtures load-components public/data/object/components.json
fi

# Test if variable is set
if test -n "${BACKEND_ADMINS:+x}"; then
  uv run backend users create-users --users "$BACKEND_ADMINS" --organization "Ecobalyse" --superuser
fi
