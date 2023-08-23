#!/usr/bin/env python3

from bw2data.project import projects
import bw2data
import bw2io

PROJECT = "Ecobalyse"
# Ecoinvent
DATAPATH = "./ECOINVENT3.9.1/datasets"
DBNAME = "Ecoinvent 3.9.1"
BIOSPHERE = "biosphere3"
# Method (See bw2data.methods for available methods)
METHODNAME = "EF v3.1"


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
    # biosphere
    projects.create_project(PROJECT, activate=True, exist_ok=True)
    if BIOSPHERE not in bw2data.databases:
        print("### Creating default biosphere")
        bw2io.create_default_biosphere3()
    else:
        print(f"### {BIOSPHERE} database is already imported")

    # EF v3.1
    if METHODNAME not in set([m[0] for m in bw2data.methods]):
        print("### Creating default LCIA methods")
        bw2io.create_default_lcia_methods()
    else:
        print(f"### {METHODNAME} already imported")

    # Core migrations
    print("### Creating core data migrations")
    if len(bw2io.migrations) < 13:
        bw2io.create_core_migrations()
    else:
        print("### Core migrations are already installed")

    # Import Ecoinvent
    if DBNAME not in bw2data.databases:
        import_ecoinvent()
    else:
        print(f"### {DBNAME} is already imported")


if __name__ == "__main__":
    main()
