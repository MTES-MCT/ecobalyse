#!/usr/bin/env python3

from subprocess import call
from zipfile import ZipFile
import bw2calc
import bw2data
import bw2io

PROJECT = "Ecobalyse"
# Ecoinvent
ECOINVENTDB = "Ecoinvent"
ECOINVENT_SPOLD = "./ECOINVENT3.9.1/datasets"
# Agribalyse
AGRIBALYSE_CSV = "AGB3.1.1.20230306.CSV.zip"
AGRIBALYSEDB = "Agribalyse"
BIOSPHERE = "Agribalyse biosphere"  # ??
# EF
EF_CSV = "181-EF3.1_unofficial_interim_for_AGRIBALYSE_WithSubImpactsEcotox_v20.csv"
EFMETHODS = (
    "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)"  # defined inside the csv
)


def import_ecoinvent(data, db):
    """
    Import file at path `data` into database named `db`
    """
    print(f"Importing {db} database from {data}...")
    ecoinvent = bw2io.importers.SingleOutputEcospold2Importer(data, db)
    ecoinvent.apply_strategies()
    ecoinvent.add_unlinked_flows_to_biosphere_database()
    ecoinvent.write_database()
    print("Finished")


def import_agribalyse(data, db, migrations):
    """
    Import file at path `data` into database named `db`, and apply provided brightway `migrations`.
    """
    print(f"Importing {db} database from {data}...")
    with ZipFile(data) as zf:
        print("Extracting the zip file...")
        zf.extractall()
        data = data[0:-4]

    # sed is faster than Python
    # `yield` is used as a variable in some Simapro parameters. bw2parameters cannot handle it:
    call("sed -i 's/yield/Yield_/g' " + data, shell=True)
    # Fix some errors in Agribalyse:
    call("sed -i 's/01\\/03\\/2005/1\\/3\\/5/g' " + data, shell=True)
    call("sed -i 's/0;001172/0,001172/' " + data, shell=True)

    # Do the import and apply "strategies"
    agribalyse = bw2io.importers.simapro_csv.SimaProCSVImporter(data, db)
    agribalyse.apply_strategies()

    # Apply provided migrations
    for migration in migrations:
        print(f"Applying custom migration: {migration['description']}")
        bw2io.Migration(migration["name"]).write(
            migration["data"],
            description=migration["description"],
        )
        agribalyse.migrate(migration["name"])

    agribalyse.statistics()
    unlinked_db = AGRIBALYSEDB + " unlinked flows"
    bw2data.Database(unlinked_db).register()
    agribalyse.add_unlinked_flows_to_biosphere_database(unlinked_db)
    agribalyse.add_unlinked_activities()
    agribalyse.statistics()
    dsdict = {ds["code"]: ds for ds in agribalyse.data}
    agribalyse.data = list(dsdict.values())

    # remove exchanges with no inputs (?!)
    for ds in agribalyse.data:
        for i, e in enumerate(ds.get("exchanges", [])):
            if "input" not in e:
                del ds["exchanges"][i]

    agribalyse.write_database()
    print("Finished")


def import_ef(data, db):
    """
    Import file at path `data` linked to biosphere named `db`
    """
    print(f"Importing {db} database from {data}...")
    ef = bw2io.importers.SimaProLCIACSVImporter(data, biosphere=db)
    ef.statistics()
    ef.write_methods()
    print("Finished")


AGRIBALYSE_MIGRATIONS = [
    {
        "name": "agb-technosphere-fixes",
        "description": "Specific technosphere fixes for Agribalyse 3",
        "data": {
            "fields": ["name", "unit"],
            "data": [
                (
                    (
                        "Wastewater, average {Europe without Switzerland}| market for wastewater, average | Cut-off, S - Copied from Ecoinvent",
                        "litre",
                    ),
                    {"unit": "cubic meter", "multiplier": 1e-3},
                ),
                (
                    (
                        "Wastewater, from residence {RoW}| market for wastewater, from residence | Cut-off, S - Copied from Ecoinvent",
                        "litre",
                    ),
                    {"unit": "cubic meter", "multiplier": 1e-3},
                ),
                (
                    (
                        "Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas | Cut-off, S - Copied from Ecoinvent",
                        "kilowatt hour",
                    ),
                    {"unit": "megajoule", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {Europe without Switzerland}| heat production, natural gas, at industrial furnace >100kW | Cut-off, S - Copied from Ecoinvent",
                        "kilowatt hour",
                    ),
                    {"unit": "megajoule", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {RER}| market group for | Cut-off, S - Copied from Ecoinvent",
                        "kilowatt hour",
                    ),
                    {"unit": "megajoule", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {RoW}| market for heat, district or industrial, natural gas | Cut-off, S - Copied from Ecoinvent",
                        "kilowatt hour",
                    ),
                    {"unit": "megajoule", "multiplier": 3.6},
                ),
                (
                    (
                        "Land use change, perennial crop {BR}| market group for land use change, perennial crop | Cut-off, S - Copied from Ecoinvent",
                        "square meter",
                    ),
                    {"unit": "hectare", "multiplier": 1e-4},
                ),
            ],
        },
    }
]

if __name__ == "__main__":
    bw2data.projects.set_current(PROJECT)
    bw2io.bw2setup()

    # Import Ecoinvent
    if ECOINVENTDB in bw2data.databases:
        print(f"*** already imported: {ECOINVENTDB} ***")
    else:
        import_ecoinvent(ECOINVENT_SPOLD, ECOINVENTDB)

    # Import Agribalyse
    if AGRIBALYSEDB in bw2data.databases:
        print(f"*** already imported {AGRIBALYSEDB} ***")
    else:
        import_agribalyse(AGRIBALYSE_CSV, AGRIBALYSEDB, AGRIBALYSE_MIGRATIONS)

    # Import methods
    if len([method for method in bw2data.methods if method[0] == EFMETHODS]) >= 1:
        print(f"*** already imported {EFMETHODS} ***")
    else:
        import_ef(EF_CSV, BIOSPHERE)

    print("Selecting an activity...")
    activity = bw2data.Database("Ecoinvent").search("cotton knit", limit=1)[0]
    print(f"Activity = {activity}")

    print("Computing LCI of activity")
    lca = bw2calc.LCA({activity: 1})
    lca.lci()
    EFMETHODS = "EF v3.1 EN15804"  # defined inside the csv
    # EFMETHODS = "ReCiPe 2016 v1.03, midpoint (I)'"  # defined inside the csv
    # EFMETHODS = "TRACI v2.1 no LT"
    for method in [method for method in bw2data.methods if method[0] == EFMETHODS]:
        lca.switch_method(method)
        lca.lcia()
        print(f"{method[1]} = {lca.score}")
