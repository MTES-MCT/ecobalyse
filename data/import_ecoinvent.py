#!/usr/bin/env python3


from os.path import join

import bw2data
import bw2io
from bw2data.project import projects
from common.import_ import add_missing_substances, import_simapro_csv

# Ecoinvent
EI391 = "./Ecoinvent3.9.1.CSV.zip"
EI310 = "./Ecoinvent3.10.CSV.zip"
BIOSPHERE = "biosphere3"
PROJECT = "default"


def main():
    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()
    add_missing_substances(PROJECT, BIOSPHERE)

    if (db := "Ecoinvent 3.9.1") not in bw2data.databases:
        import_simapro_csv(join("dbfiles", EI391), db)
    else:
        print(f"{db} already imported")

    if (db := "Ecoinvent 3.10") not in bw2data.databases:
        import_simapro_csv(join("dbfiles", EI310), db)

    else:
        print(f"{db} already imported")


if __name__ == "__main__":
    main()
