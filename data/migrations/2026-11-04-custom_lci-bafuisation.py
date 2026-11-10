#!/usr/bin/env -S uv run --script
"""
Converts custom lcis from EcoInvent to BAFU
https://github.com/MTES-MCT/ecobalyse/issues/2883
"""

import csv
import json

from ecobalyse.json import export_json

from config import DATA_ROOT_DIR
from ecobalyse_data.logging import logger

SCOPES_TO_MIGRATE = {"object", "veli"}
SCOPES_TO_IGNORE = {"food", "food2", "textile", "apparel"}
CUSTOM_LCI_DIR = DATA_ROOT_DIR / "lci_catalog" / "ecobalyse_custom_lci"
CUSTOM_LCI_FILE = DATA_ROOT_DIR / "custom_lci.json"
MAPPING_FILE = DATA_ROOT_DIR / "migrations" / "mapping-ei-bafu-v3.csv"
BAFU_DB_NAME = "BAFU 2025v2"
ECOINVENT_DB_NAME = "Ecoinvent 3.9.1"
FORCED_MIGRATION_LIST = [
    "battery-li-ion-glo",
    "freight-aircraft-longhaul-withlongtails",
    "packaging-material-aluminium",
    "packaging-material-glass",
    "packaging-material-pet",
    "packaging-material-pvc",
    "packaging-material-steel",
    "petrol-e85",
    "steel-market-cz",
    "steel-market-de",
    "steel-market-jp",
]


def parse_mappings_file() -> dict[str, str]:
    mappings = {}
    with open(MAPPING_FILE) as migration_fd:
        mappings_reader = csv.reader(migration_fd)
        for line in mappings_reader:
            # We need to concatenate col. 5 (the bafu name) with col. 9 (the geography)
            mappings[line[0]] = f"{line[5]} {{{line[9]}}} U"
    return mappings


def get_root_lcis_to_migrate() -> set[str]:
    """
    Returns all processes in the `ecobalyse_custom_lci` folder which have one of
    the SCOPES_TO_MIGRATE and none of the `SCOPES_TO_IGNORE` scope.
    """
    to_migrate = set()
    for lci_path in CUSTOM_LCI_DIR.glob("*.json"):
        with open(lci_path, "r") as src_fd:
            activity = json.load(src_fd)
            root_scopes = activity["scopes"]
            for md in activity.get("metadata", []):
                scopes = set(md.get("scopes", root_scopes))
                # Exception for packagings : if they have a SCOPES_TO_MIGRATE scope
                # we migrate them without checking the ignore list
                if scopes & SCOPES_TO_MIGRATE and "packaging" in activity["categories"]:
                    to_migrate.add(activity["activityName"])
                if scopes & SCOPES_TO_MIGRATE and SCOPES_TO_IGNORE.isdisjoint(scopes):
                    to_migrate.add(activity["activityName"])
    return to_migrate


def get_lcis_to_migrate_by_alias(custom_lcis: list[dict]) -> set[str]:
    to_migrate = set()
    for lci in custom_lcis:
        if lci["alias"] in FORCED_MIGRATION_LIST:
            to_migrate.add(lci["newName"])
    return to_migrate


def get_recursive_lcis_to_migrate(
    custom_lcis: list[dict], to_migrate: set[str]
) -> set[str]:
    """
    for all items of `custom_lcis`, if `newName` is part of the `to_migrate` set,
    we add all its descendants whose `database` is `Ecobalyse_custom_lci` to the
    set.

    For ex: if `to_migrate` is equal to `{A}`,
    and the A process looks like:
    ```
    {
      "activityCreationType": "from_scratch",
      "exchanges": [
        {
          "database": "Ecobalyse_custom_lci",
          "name": "B"
        }
      ],
      "newName": "A"
    }
    ```
    and the C process looks like:
    ```
    {
      "activityCreationType": "from_scratch",
      "exchanges": [
        {
            "database": "Ecobalyse_custom_lci",
            "name": "C"
        }
      ],
      "newName": "B"
    }
    ```
    then this function will return the set `{A, B, C}`
    """
    for lci in custom_lcis:
        if lci["newName"] in to_migrate:
            if lci["activityCreationType"] == "from_existing":
                if lci.get("database") != BAFU_DB_NAME:
                    assert False, f"Can’t migrate {lci['alias']}"
                continue
            assert lci["activityCreationType"] == "from_scratch"

            root_db = lci.get("database")
            for exc in lci["exchanges"]:
                if exc.get("database", root_db) == "Ecobalyse_custom_lci":
                    to_migrate |= get_recursive_lcis_to_migrate(
                        custom_lcis, {exc["name"]}
                    )
    return to_migrate


def migrate_custom_lci(custom_lcis: list[dict], mappings) -> list[dict]:
    # these custom lcis need migration because are referenced in the
    # CUSTOM_LCI_DIR folder, and don’t have one of the ignored scopes
    to_migrate = get_root_lcis_to_migrate()
    # and we add to the list processes identified manually
    to_migrate |= get_lcis_to_migrate_by_alias(custom_lcis)

    logger.debug(f"custom lcis which need migration directly: {to_migrate}")

    # these custom lcis need migration because they are referenced by another
    # process which needs migration
    to_migrate_recursive = get_recursive_lcis_to_migrate(custom_lcis, to_migrate.copy())
    logger.debug(
        f"custom lcis which need migration indirectly: {to_migrate_recursive - to_migrate}"
    )
    for lci in custom_lcis:
        if lci["newName"] in to_migrate_recursive:
            if lci["activityCreationType"] == "from_existing":
                # `from_existing` processes should already have been migrated
                # if we find a non-BAFU one, it’s an error
                if lci.get("database") != BAFU_DB_NAME:
                    logger.error(
                        f"Can’t migrate `from_existing` process {lci['newName']}"
                    )
                    assert False
                continue
            root_db = lci.get("database")
            exchanges = lci["exchanges"]
            for exc in exchanges:
                # if the DB is not specified, we take the root db
                exc_db = exc.get("database", root_db)
                if exc_db == ECOINVENT_DB_NAME:
                    try:
                        ei_name = exc["name"]
                        bafu_name = mappings[ei_name]
                        exc["name"] = bafu_name
                        exc["database"] = BAFU_DB_NAME
                        logger.debug(f"Mapping `{ei_name}` to `{bafu_name}`")
                    except KeyError:
                        logger.error(
                            f"No mapping found for {ei_name} in '{lci['newName']}'"
                        )

    return custom_lcis


def clean_dbs(custom_lcis: list[dict]):
    # `"database"` can be specified either at the root of a custom_lci,
    # or for each exchange. Now that we have migrated some EI processes,
    # let’s do some cleanup.
    # Note: that could be generalized, but we only want to change BAFU
    # inconsistencies right now. The rest will be the job of
    # https://github.com/MTES-MCT/ecobalyse/pull/2973

    # Pass 1 : if all exchange DBs are BAFU, set the root DB to BAFU
    for lci in custom_lcis:
        root_db = lci.get("database")
        exchanges = lci.get("exchanges", [])
        dbs = {exc.get("database") for exc in exchanges}
        if len(dbs) == 1 and next(iter(dbs)) == BAFU_DB_NAME:
            # all exchange dbs are identical, overwrite the root one
            lci["database"] = BAFU_DB_NAME

    # Pass 2: if the root DB is BAFU, remove DB specification from exchanges
    # where it’s BAFU too
    for lci in custom_lcis:
        root_db = lci.get("database")
        if root_db == BAFU_DB_NAME:
            exchanges = lci.get("exchanges", [])
            for exc in exchanges:
                if exc.get("database") == BAFU_DB_NAME:
                    del exc["database"]
            lci["exchanges"] = exchanges

    # Pass 3: if the root DB is EcoInvent and all of the children exchanges
    # specify a different DB, remove the root DB specification
    for lci in custom_lcis:
        root_db = lci.get("database")
        if (
            lci["activityCreationType"] == "from_scratch"
            and root_db == ECOINVENT_DB_NAME
        ):
            exchanges = lci.get("exchanges", [])
            dbs = {exc.get("database") for exc in exchanges}
            if ECOINVENT_DB_NAME not in dbs and None not in dbs:
                del lci["database"]

    return custom_lcis


def list_ei_items(custom_lcis: list[dict]):
    """Print the custom_lci.json items with an ecoinvent database."""
    for lci in custom_lcis:
        dbs = {exc.get("database") for exc in lci.get("exchanges", [])}
        dbs.add(lci.get("database"))
        if ECOINVENT_DB_NAME in dbs:
            logger.debug(lci["alias"])


def main():
    with open(CUSTOM_LCI_FILE) as fd:
        custom_lcis = json.load(fd)
        list_ei_items(custom_lcis)
        mappings = parse_mappings_file()

        custom_lcis = migrate_custom_lci(custom_lcis, mappings)
        custom_lcis = clean_dbs(custom_lcis)

    with open(CUSTOM_LCI_FILE, "w") as fd:
        export_json(custom_lcis, CUSTOM_LCI_FILE)


if __name__ == "__main__":
    main()
