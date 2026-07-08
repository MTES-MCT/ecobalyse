# https://github.com/casey/just
# Cheat sheet: https://cheatography.com/linux-china/cheat-sheets/justfile/

set dotenv-load := true

export-script := "data/bin/export.py"
python-cmd-data := "uv run --group data python"
export PYTHONPATH := "$PYTHONPATH:./data/"

################################################################################
## Recipes
################################################################################

default:
    echo $PATH
    @just --list

################################################################################
### Data imports

import-all: import-food import-ecoinvent import-method create-activities sync-datapackages

import-food:
    {{ python-cmd-data }} data/import_food.py

import-ecoinvent:
    {{ python-cmd-data }} data/import_ecoinvent.py

import-method:
    {{ python-cmd-data }} data/import_method.py

create-activities:
    {{ python-cmd-data }} data/create_activities.py

sync-datapackages:
    {{ python-cmd-data }} data/common/sync_datapackages.py

################################################################################
### Data exports

export-all:
    {{ python-cmd-data }} {{ export-script }} processes-legacy
    {{ python-cmd-data }} {{ export-script }} metadata
    {{ python-cmd-data }} {{ export-script }} merge-processes

merge-processes:
    {{ python-cmd-data }} {{ export-script }} merge-processes

export-food:
    {{ python-cmd-data }} {{ export-script }} processes-legacy --scopes food --merge
    {{ python-cmd-data }} {{ export-script }} metadata --scopes food
    {{ python-cmd-data }} {{ export-script }} merge-processes

export-generic:
    {{ python-cmd-data }} {{ export-script }} processes-legacy --scopes object --merge
    {{ python-cmd-data }} {{ export-script }} metadata --scopes generic
    {{ python-cmd-data }} {{ export-script }} merge-processes

export-textile:
    {{ python-cmd-data }} {{ export-script }} processes-legacy --scopes textile --merge
    {{ python-cmd-data }} {{ export-script }} metadata --scopes textile
    {{ python-cmd-data }} {{ export-script }} merge-processes

export-veli:
    {{ python-cmd-data }} {{ export-script }} processes-legacy --scopes veli --merge
    {{ python-cmd-data }} {{ export-script }} merge-processes

export-transports:
    {{ python-cmd-data }} -m common.distances.transports

################################################################################
### Data cleaning

delete-lci-database db:
    {{ python-cmd-data }} -m common.delete_database {{ db }}

delete-lci-methods:
    {{ python-cmd-data }} -m common.delete_methods

################################################################################
### Linting & formatting

check-lci-catalog:
    uv run --group data check-jsonschema --schemafile data/schemas/lci-schema.json data/tests/fixtures/lci_catalog/*/* data/lci_catalog/*/*

check-processes *target:
    uv run --group data check-jsonschema --schemafile data/tests/processes-schema.json data/public/data/processes*.json data/tests/fixtures/processes_legacy_impacts_output.json data/tests/snapshots/processes_legacy_impacts.json

check-json-data +target="data":
    {{ python-cmd-data }} ./data/bin/json_formatter.py {{ target }}

fix-json-data +target="data":
    {{ python-cmd-data }} ./data/bin/json_formatter.py --fix {{ target }}

check-python-data +target="data":
    uv run --group data ruff check --force-exclude {{ target }}
    uv run --group data ruff format --force-exclude --check {{ target }}

fix-python-data +target="data":
    uv run --group data ruff check --force-exclude --fix {{ target }}
    uv run --group data ruff format --force-exclude {{ target }}

check-all-data: check-lci-catalog check-processes check-json-data check-python-data

fix-all-data: fix-json-data fix-python-data

ci-data: check-all-data

################################################################################
### Testing

test-data:
    uv run --group data pytest data
