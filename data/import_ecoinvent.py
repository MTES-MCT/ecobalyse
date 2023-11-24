#!/usr/bin/env python3

from bw2data.project import projects
from common.import_ import add_missing_substances
from zipfile import ZipFile
import bw2data
import bw2io
import os
import shutil

PROJECT = "textile"
# Ecoinvent
DATAPATH = "./ECOINVENT3.9.1/datasets"
DBNAME = "Ecoinvent 3.9.1"
BIOSPHERE = "biosphere3"


def import_ecoinvent(datapath=DATAPATH, project=PROJECT, dbname=DBNAME):
    """
    Import file at path `datapath` into database named `dbname` in the project
    """
    projects.set_current(project)
    # projects.create_project(project, activate=True, exist_ok=True)

    # unzip
    with ZipFile(datapath) as zf:
        print("### Extracting the zip file...")
        zf.extractall()
        unzipped = datapath[0:-4]

    print(f"### Importing {dbname} database from {unzipped}...")
    ecoinvent = bw2io.importers.SingleOutputEcospold2Importer(
        os.path.join(unzipped, "datasets"), dbname
    )
    shutil.rmtree(unzipped)
    ecoinvent.apply_strategies()
    ecoinvent.add_unlinked_flows_to_biosphere_database()
    ecoinvent.write_database()
    print(f"### Finished importing {dbname}")


def main():
    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()
    add_missing_substances(PROJECT, BIOSPHERE)

    # Import Ecoinvent
    if DBNAME not in bw2data.databases:
        import_ecoinvent()
    else:
        print(f"### {DBNAME} is already imported")


if __name__ == "__main__":
    main()
