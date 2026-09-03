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

import-all: import-food import-ecoinvent import-bafu import-method create-activities

import-food:
    {{ python-cmd-data }} data/import_food.py

import-ecoinvent:
    {{ python-cmd-data }} data/import_ecoinvent.py

import-bafu:
    {{ python-cmd-data }} data/import_bafu.py

import-method:
    {{ python-cmd-data }} data/import_method.py

create-activities:
    {{ python-cmd-data }} data/create_activities.py

# Compare the impacts we publish with the ones VoLCA computes on the same source files
compare-volca:
    uv run --group data --group volca python data/bin/compare_volca.py

################################################################################
### Data exports

export-all:
    {{ python-cmd-data }} {{ export-script }} processes-legacy
    {{ python-cmd-data }} {{ export-script }} metadata
    {{ python-cmd-data }} {{ export-script }} merge-processes

generate-taxonomy-with-aliases:
    {{ python-cmd-data }} data/bin/generate_taxonomy_with_aliases.py

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

compute-distances:
    {{ python-cmd-data }} -m common.distances.compute_distances

export-transports:
    {{ python-cmd-data }} -m common.distances.transports

# Export a Brightway db: `just export-bw-db ecospold1 --activities` or `just export-bw-db simapro`
export-bw-db *args:
    {{ python-cmd-data }} ./data/bin/export_bw_db.py {{ args }}

################################################################################
### Data cleaning

delete-lci-database db:
    {{ python-cmd-data }} -m common.delete_database {{ db }}

delete-lci-methods:
    {{ python-cmd-data }} -m common.delete_methods

################################################################################
### Linting & formatting

check-lci-catalog:
    uv run --group data check-jsonschema --schemafile schemas/lci-schema.json data/tests/fixtures/lci_catalog/*/* data/lci_catalog/*/*

check-processes:
    uv run --group data check-jsonschema --schemafile schemas/processes-schema.json data/export/processes*.json data/tests/fixtures/processes_legacy_impacts_output.json data/tests/snapshots/processes_legacy_impacts.json

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
