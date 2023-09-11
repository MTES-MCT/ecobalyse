#!/usr/bin/env python3

from bw2data.project import projects
import bw2data
import bw2io

PROJECT = "Textile"
# Ecoinvent
DATAPATH = "./ECOINVENT3.9.1/datasets"
DBNAME = "Ecoinvent 3.9.1"
BIOSPHERE = "biosphere3"


def import_ecoinvent(datapath=DATAPATH, project=PROJECT, dbname=DBNAME):
    """
    Import file at path `datapath` into database named `dbname` in the project
    """
    projects.create_project(project, activate=True, exist_ok=True)

    print(f"### Importing {dbname} database from {datapath}...")
    ecoinvent = bw2io.importers.SingleOutputEcospold2Importer(datapath, dbname)
    ecoinvent.apply_strategies()
    ecoinvent.add_unlinked_flows_to_biosphere_database()
    ecoinvent.write_database()
    print(f"### Finished importing {dbname}")


def main():
    projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.config.p["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()

    # Import Ecoinvent
    if DBNAME not in bw2data.databases:
        import_ecoinvent()
    else:
        print(f"### {DBNAME} is already imported")


if __name__ == "__main__":
    main()
