#!/usr/bin/env bash

# Be sure to exit as soon as something goes wrong
set -eo pipefail

# If we’re not on the CI, clean and bootstrap the DB using docker
if [ -z "$CI" ]; then
  ./bin/check-db.sh
  docker compose exec -T db dropdb --if-exists -U ecobalyse ecobalyse_test
  docker compose exec -T db createdb -U ecobalyse ecobalyse_test
fi

uv run backend database upgrade --no-prompt && uv run backend fixtures load-test
npm start
