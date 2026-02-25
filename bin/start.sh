#!/usr/bin/env bash


# Fail if they is an error
set -euo pipefail

ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
cd $ROOT_DIR

# Fix outdated Scalingo DSN to be compatible with asyncpg
DATABASE_URL=$(set -o pipefail; echo "$DATABASE_URL" | sed -e 's/postgres/postgresql+asyncpg/;tx;q100;:x' | sed -e 's/sslmode=/ssl=/;tx;q100;:x')
export DATABASE_URL

# run all three tasks in the background

# express
npm run server:start &

# Run database migrations
uv run backend database upgrade --no-prompt
npm run start:backend &

# nginx
bin/run &

# if the current shell is killed, also terminate all its children
trap "pkill SIGTERM -P $$" SIGTERM

# wait for a single child to finish,
wait -n
# then kill all the other tasks
pkill -P $$
