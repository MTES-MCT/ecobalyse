#!/usr/bin/env python3

# from bw2io.strategies.simapro import fix_localized_water_flows
# from bw2io.strategies import migrate_exchanges
import bw2data
import bw2io

# import functools

PROJECT = "Ecobalyse"
# Agribalyse
DATAPATH = "AGB3.1.1.20230306.CSV.zip"
DBNAME = "Agribalyse 3.1.1"
BIOSPHERE = DBNAME + " biosphere"
METHODPATH = "Environmental Footprint 3.1 (adapted).CSV"
METHODNAME = "Environmental Footprint 3.1 (adapted)"  # defined inside the csv


def import_method(datapath=METHODPATH, project=PROJECT, biosphere=BIOSPHERE):
    """
    Import file at path `datapath` linked to biosphere named `dbname`
    """
    print(f"### Importing {datapath}...")
    bw2data.projects.set_current(project)
    bw2data.config.p["biosphere_database"] = biosphere
    ef = bw2io.importers.SimaProLCIACSVImporter(
        datapath,
        biosphere=biosphere,
        normalize_biosphere=True
        # normalize_biosphere to align the categories between LCI and LCIA
    )
    ef.statistics()
    ef.strategies = [
        s
        for s in ef.strategies
        if "water" not in repr(s)
        and "normalize_simapro_biosphere_names" not in repr(s)
        and "normalize_biosphere_names" not in repr(s)
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
    if len([method for method in bw2data.methods if method[0] == METHODNAME]) == 0:
        import_method()
    else:
        print(f"{METHODNAME} already imported")


if __name__ == "__main__":
    main()
