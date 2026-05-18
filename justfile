# https://github.com/casey/just
# Temporary Justfile, used only by the pre-commit and CI
# while we are merging the repositories

set dotenv-load := true
uv := "PYTHONPATH=./data uv"



################################################################################
## Recipes
################################################################################

default:
  @just --list


################################################################################
### Linting & formatting

check-activities:
  {{uv}} run check-jsonschema --schemafile data/schemas/lci-schema.json data/tests/fixtures/lci_catalog/*/* data/lci_catalog/*/*

check-processes *target:
  {{uv}} run check-jsonschema --schemafile data/tests/processes-schema.json data/public/data/processes*.json data/tests/fixtures/processes_impacts_output.json data/tests/snapshots/processes_impacts.json

check-json +target=".":
  {{uv}} run python ./data/bin/json_formatter.py {{target}}

fix-json +target=".":
  {{uv}} run python ./data/bin/json_formatter.py --fix {{target}}

check-python +target=".":
  {{uv}} run ruff check --force-exclude --extend-select I {{target}}
  {{uv}} run ruff format --force-exclude --check {{target}}

fix-python +target=".":
  {{uv}} run ruff check --force-exclude --extend-select I --fix {{target}}
  {{uv}} run ruff format --force-exclude {{target}}

check-all: check-activities check-processes check-json check-python

fix-all: fix-json fix-python


ci: check-all


################################################################################
### Testing

test:
  cd data && {{uv}} run pytest
