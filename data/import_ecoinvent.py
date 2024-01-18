#!/usr/bin/env python3

from bw2data.project import projects
from common.import_ import add_missing_substances
from import_agribalyse import import_simapro_csv
import bw2data
import bw2io

PROJECT = "textile"
# Ecoinvent
DATAPATH = "./Ecoinvent3.9.1.CSV.zip"
BIOSPHERE = "biosphere3"


def main():
    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()
    add_missing_substances(PROJECT, BIOSPHERE)

    if (db := "Ecoinvent 3.9.1") not in bw2data.databases:
        import_simapro_csv(DATAPATH, db)
    else:
        print(f"{db} already imported")


if __name__ == "__main__":
    main()
