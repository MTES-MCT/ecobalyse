docker compose exec -T db dropdb --if-exists -U ecobalyse ecobalyse_dev
docker compose exec -T db createdb -U ecobalyse ecobalyse_dev
uv run backend database upgrade --no-prompt
uv run backend users create-default-user
uv run backend fixtures load-components public/data/object/components.json
