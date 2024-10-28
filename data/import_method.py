#!/usr/bin/env python3
import functools
import os
from os.path import dirname, join
from zipfile import ZipFile

import bw2data
import bw2io
from bw2data.project import projects
from bw2io.strategies import (
    drop_unspecified_subcategories,
    # fix_localized_water_flows,
    link_iterable_by_fields,
    match_subcategories,
    # migrate_exchanges,
    # normalize_biosphere_categories,
    normalize_biosphere_names,
    normalize_simapro_biosphere_categories,
    normalize_simapro_biosphere_names,
    normalize_units,
    set_biosphere_type,
)

PROJECT = "default"
# Agribalyse
BIOSPHERE = "biosphere3"
METHODNAME = "Environmental Footprint 3.1 (adapted) patch wtu"  # defined inside the csv
METHODPATH = join("..", "..", "dbfiles", METHODNAME + ".CSV.zip")

# excluded strategies and migrations
EXCLUDED = [
    "normalize_simapro_biosphere_names",
    "normalize_biosphere_names",
    "fix_localized_water_flows",
    "simapro-water",
]


def import_method(project, datapath=METHODPATH, biosphere=BIOSPHERE):
    """
    Import file at path `datapath` linked to biosphere named `dbname`
    """
    print(f"### Importing {datapath}...")
    projects.set_current(project)

    # unzip
    with ZipFile(datapath) as zf:
        print("### Extracting the zip file...")
        zf.extractall(path=dirname(datapath))
        unzipped = datapath[0:-4]

    # projects.create_project(project, activate=True, exist_ok=True)
    ef = bw2io.importers.SimaProLCIACSVImporter(
        unzipped,
        biosphere=biosphere,
        normalize_biosphere=True,
        # normalize_biosphere to align the categories between LCI and LCIA
    )
    os.unlink(unzipped)
    ef.statistics()

    # exclude strategies/migrations in EXCLUDED
    ef.strategies = [
        s for s in ef.strategies if not any([e in repr(s) for e in EXCLUDED])
    ]
    ef.apply_strategies()

    # ef.write_excel(METHODNAME)
    # drop CFs which are not linked to a biosphere substance
    ef.drop_unlinked()
    ef.write_methods()
    print(f"### Finished importing {METHODNAME}\n")


if __name__ == "__main__":
    # Import custom method
    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()

    if len([method for method in bw2data.methods if method[0] == METHODNAME]) == 0:
        import_method(PROJECT)
    else:
        print(f"{METHODNAME} already imported")
