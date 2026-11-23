#!/usr/bin/env -S uv run --script
"""
Converts lcis from EcoInvent to BAFU
https://github.com/MTES-MCT/ecobalyse/issues/2882
"""

import csv
import json

from ecobalyse.json import export_json

from config import DATA_ROOT_DIR, settings
from ecobalyse_data.logging import logger


def migrate_lci_catalog(mappings):
    lci_catalog = DATA_ROOT_DIR / "lci_catalog"
    logger.debug(f"-> Loading lci_catalog {lci_catalog}")
    source_dirs = [lci_catalog / "ecoinvent-3-11", lci_catalog / "ecoinvent-3-9-1"]
    dest_dir = lci_catalog / "bafu-2026-1"
    for source_dir in source_dirs:
        for lci_path in source_dir.glob("*.json"):
            if lci_path.is_file():
                with open(lci_path, "r", encoding="utf-8") as src_fd:
                    activity = json.load(src_fd)
                    scopes = activity["scopes"]
                    if "object" in scopes or "veli" in scopes or "textile" in scopes:
                        logger.debug(f"Migrating {lci_path}")
                        activity["source"] = settings.bw.BAFU
                        activity["activityNameEI"] = activity["activityName"]
                        if source_dir.name.endswith("ecoinvent-3-11"):
                            # processes in the ecoinvent-3-11 folder have a name
                            # ending with " | Cut-off, U", which is absent in
                            # the mapping
                            ei_name = activity["activityName"][:-13]
                        else:
                            ei_name = activity["activityName"]
                        try:
                            activity["activityName"] = mappings[ei_name]
                            export_json(activity, dest_dir / lci_path.name)
                        except KeyError:
                            # let’s just ignore unmapped ones for now
                            # they are probably in custom_lci.json
                            logger.debug(f"⚠️ unmapped {lci_path}")
                        lci_path.unlink()


def main():
    mappings = {}
    with open(
        DATA_ROOT_DIR / "migrations" / "2026-10-27-ei_to_bafu.csv"
    ) as migration_fd:
        mappings_reader = csv.reader(migration_fd)
        for line in mappings_reader:
            mappings[line[0]] = line[6]
    migrate_lci_catalog(mappings)


if __name__ == "__main__":
    main()
