#!/usr/bin/env python3
from bw2data.project import projects
import bw2data
import bw2io
import sys
import functools
from bw2io.strategies import (
    drop_unspecified_subcategories,
    fix_localized_water_flows,
    link_iterable_by_fields,
    match_subcategories,
    migrate_exchanges,
    normalize_biosphere_categories,
    normalize_biosphere_names,
    normalize_simapro_biosphere_categories,
    normalize_simapro_biosphere_names,
    normalize_units,
    set_biosphere_type,
)


PROJECT = sys.argv[1]
# Agribalyse
BIOSPHERE = "biosphere3"
METHODPATH = "Environmental Footprint 3.1 (adapted) patch wtu.CSV"
METHODNAME = "Environmental Footprint 3.1 (adapted) patch wtu"  # defined inside the csv

# excluded strategies and migrations
EXCLUDED_FOOD = [
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
    projects.set_current(PROJECT)
    # projects.create_project(project, activate=True, exist_ok=True)
    ef = bw2io.importers.SimaProLCIACSVImporter(
        datapath,
        biosphere=biosphere,
        normalize_biosphere=False if project == "textile" else True
        # normalize_biosphere to align the categories between LCI and LCIA
    )
    ef.statistics()
    # exclude strategies/migrations in EXCLUDED
    if project == "food":
        ef.strategies = [
            s for s in ef.strategies if not any([e in repr(s) for e in EXCLUDED_FOOD])
        ]
    if project == "textile":
        # ef.write_excel("before")
        ef.strategies = [
            normalize_units,
            set_biosphere_type,
            # fix_localized_water_flows,  # adding it leads to 60m3
            drop_unspecified_subcategories,
            functools.partial(normalize_biosphere_categories, lcia=True),
            functools.partial(normalize_biosphere_names, lcia=True),
            functools.partial(migrate_exchanges, migration="simapro-water"),
            normalize_simapro_biosphere_names,  # removing avoid multiple CFs
            normalize_simapro_biosphere_categories,
            functools.partial(
                link_iterable_by_fields,
                other=(
                    obj
                    for obj in bw2data.Database(ef.biosphere_name)
                    if obj.get("type") == "emission"
                ),
                # fields=("name", "unit", "categories"),
                kind="biosphere",
            ),
            functools.partial(match_subcategories, biosphere_db_name=ef.biosphere_name),
        ]
    ef.apply_strategies()
    # ef.write_excel("after")
    # add unlinked CFs to the biosphere database
    # ef.add_missing_cfs()  # uncomment and get zero impacts on Food!
    # drop CFs which are not linked to a biosphere substance since they are not used by any activity
    ef.drop_unlinked()
    ef.write_methods()
    print(f"### Finished importing {METHODNAME}")


def main():
    # Import custom method
    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()

    if len([method for method in bw2data.methods if method[0] == METHODNAME]) == 0:
        import_method()
    else:
        print(f"{METHODNAME} already imported")


if __name__ == "__main__":
    main()
