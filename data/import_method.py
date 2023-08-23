#!/usr/bin/env python3

from bw2data.project import projects
import bw2data
import bw2io

# import functools

PROJECT = "Ecobalyse"
# Agribalyse
DATAPATH = "AGB3.1.1.20230306.CSV.zip"
DBNAME = "Agribalyse 3.1.1"
BIOSPHERE = DBNAME + " biosphere"
METHODPATH = "Environmental Footprint 3.1 (adapted) patch wtu.CSV"
METHODNAME = "Environmental Footprint 3.1 (adapted) patch wtu"  # defined inside the csv

# excluded strategies and migrations
EXCLUDED = [
    "normalize_simapro_biosphere_names",
    "normalize_biosphere_names",
    "fix_localized_water_flows",
    "simapro-water",
]


def import_method(datapath=METHODPATH, project=PROJECT, biosphere=BIOSPHERE):
    """
    Import file at path `datapath` linked to biosphere named `dbname`
    """
    print(f"### Importing {datapath}...")
    projects.create_project(project, activate=True, exist_ok=True)
    bw2data.config.p["biosphere_database"] = biosphere
    ef = bw2io.importers.SimaProLCIACSVImporter(
        datapath,
        biosphere=biosphere,
        normalize_biosphere=True
        # normalize_biosphere to align the categories between LCI and LCIA
    )
    ef.statistics()
    # exclude strategies/migrations in EXCLUDED
    ef.strategies = [
        s for s in ef.strategies if not any([e in repr(s) for e in EXCLUDED])
    ]
    ef.apply_strategies()
    # add unlinked CFs to the biosphere database
    # ef.add_missing_cfs()
    # drop CFs which are not linked to a biosphere substance since they are not used by any activity
    ef.drop_unlinked()
    ef.write_methods()
    print(f"### Finished importing {METHODNAME}")


def main():
    # Import custom method
    projects.create_project(PROJECT, activate=True, exist_ok=True)
    if len([method for method in bw2data.methods if method[0] == METHODNAME]) == 0:
        import_method()
    else:
        print(f"{METHODNAME} already imported")


if __name__ == "__main__":
    main()
