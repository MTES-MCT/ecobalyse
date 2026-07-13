# Score history

Tracks the evolution of score over time. For every new commit to master
scores are computed for textile examples and food ingredients.
If the score changes, the new rows are appended to the score_history PostgreSQL
table.


## How to run in local

### Prerequisites

1. `npm start`

2. Make a tunnel to the Scalingo score database

   ```bash
   scalingo --app ecobalyse-data db-tunnel DATABASE_URL
   ```
   you can find DATABASE_URL in the scalingo env var

3. Build the SCORE_DB_URL from the Scalingo `DATABASE_URL`

   ```bash
   export SCORE_DB_URL="postgresql+psycopg://<user>:<password>@localhost:10000/<dbname>?sslmode=prefer"
   ```

### Run

```bash
uv run python bin/score_history/score_history.py \
    http://localhost:8001 \
    "$(git branch --show-current)" \
    "$(git rev-parse HEAD)" \
    "$SCORE_DB_URL"
```

| Argument | Meaning |
|---|---|
| `API_URL` | Base URL of the API (`http://localhost:8001`) |
| `BRANCH_NAME` | Branch label stored in the `branch` column |
| `LAST_COMMIT_HASH` | Commit to score. Truncated to 7 characters |
| `SCALING_POSTGRESQL_SCORE_URL` | SQLAlchemy database URL |

Running in local will insert to the production database.
To test without writing to it, add the `--dry-run` flag

## Table schema

See `create_table_score_history.sql`. One row per
product × lifecycle step × (impact or complement)

- For each row we have the `value` and `norm_value_ecs` columns.
  - `value` is before weighting/normalization (eg. 5 kgCO2eq for climate change `cch`)
  - `norm_value_ecs` is after in UI points  (eg. 100 UI points for `cch`)
    .`norm_value_ecs = 1e6 * value * weighting / normalization`
  - `ecs` impacts have 0 in `norm_value_ecs`. Indeed `ecs` is already normalized so `value` is enough.
- For ingredient rows, the `ecs` row's `value` includes the complements.
  summing `norm_value_ecs` over an ingredient's other rows gives the
  same total.
