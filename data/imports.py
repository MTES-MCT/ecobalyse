#!/usr/bin/env python3

from bw2io.migrations import create_core_migrations
from subprocess import call
from zipfile import ZipFile
import bw2data
import bw2io

PROJECT = "Ecobalyse"
# Ecoinvent
ECOINVENTDB = "Ecoinvent 3.9.1"
ECOINVENT_SPOLD = "./ECOINVENT3.9.1/datasets"
# Agribalyse
AGRIBALYSE_CSV = "AGB3.1.1.20230306.CSV.zip"
AGRIBALYSEDB = "Agribalyse 3.1.1"
AGBIOSPHERE = AGRIBALYSEDB + " biosphere"
BIOSPHERE = "biosphere3"
# EF
EF_CSV = "181-EF3.1_unofficial_interim_for_AGRIBALYSE_WithSubImpactsEcotox_v20.csv"
EFMETHODS = (
    "EF 3.1 Method interim for AGRIBALYSE (Subimpacts)"  # defined inside the csv
)


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
AGRIBALYSE_PACKAGINGS = [
    "PS",
    "LDPE",
    "PP",
    "Cardboard",
    "No packaging",
    "Already packed - PET",
    "Glass",
    "Steel",
    "PVC",
    "PET",
    "Paper",
    "HDPE",
    "Already packed - PP/PE",
    "Already packed - Aluminium",
    "Already packed - Steel",
    "Already packed - Glass",
    "Corrugated board and aluminium packaging",
    "Corrugated board and LDPE packaging",
    "Aluminium",
    "PP/PE",
    "Corrugated board and PP packaging",
]
AGRIBALYSE_STAGES = ["at consumer", "at packaging", "at supermarket", "at distribution"]
AGRIBALYSE_TRANSPORT_TYPES = [
    "Chilled",
    "Ambient (average)",
    "Ambient (long)",
    "Ambient (short)",
    "Frozen",
]
AGRIBALYSE_PREPARATION_MODES = [
    "Oven",
    "No preparation",
    "Microwave",
    "Boiling",
    "Chilled at consumer",
    "Pan frying",
    "Water cooker",
    "Deep frying",
]


def import_ecoinvent(data=ECOINVENT_SPOLD, project=PROJECT, db=ECOINVENTDB):
    """
    Import file at path `data` into biosphere database named `db`
    """
    print(f"Importing {db} database from {data}...")
    bw2data.projects.set_current(project)
    ecoinvent = bw2io.importers.SingleOutputEcospold2Importer(data, db)
    ecoinvent.apply_strategies()
    ecoinvent.add_unlinked_flows_to_biosphere_database()
    ecoinvent.write_database()
    print("Finished")


def import_agribalyse(
    data=AGRIBALYSE_CSV,
    project=PROJECT,
    db=AGRIBALYSEDB,
    migrations=AGRIBALYSE_MIGRATIONS,
):
    """
    Import file at path `data` into database named `db`, and apply provided brightway `migrations`.
    """
    bw2data.projects.set_current(project)
    create_core_migrations()
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
    bw2data.projects.set_current(project)
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
    unlinked_db = AGRIBALYSEDB + " biosphere"
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

    import re
    from tqdm import tqdm

    dqr_pattern = r"The overall DQR of this product is: (?P<overall>[\d.]+) {P: (?P<P>[\d.]+), TiR: (?P<TiR>[\d.]+), GR: (?P<GR>[\d.]+), TeR: (?P<TeR>[\d.]+)}"
    ciqual_pattern = r"\[Ciqual code: (?P<ciqual>[\d_]+)\]"
    location_pattern = r"\{(?P<location>[\w ,\/\-\+]+)\}"
    location_pattern_2 = r"\/\ *(?P<location>[\w ,\/\-]+) U$"

    for activity in tqdm(agribalyse):
        # Getting activities locations
        if activity.get("location") is None:
            match = re.search(pattern=location_pattern, string=activity["name"])
            if match is not None:
                activity["location"] = match["location"]
            else:
                match = re.search(pattern=location_pattern_2, string=activity["name"])
                if match is not None:
                    activity["location"] = match["location"]
                elif ("French production," in activity["name"]) or (
                    "French production mix," in activity["name"]
                ):
                    activity["location"] = "FR"
                elif "CA - adapted for maple syrup" in activity["name"]:
                    activity["location"] = "CA"
                elif ", IT" in activity["name"]:
                    activity["location"] = "IT"
                elif ", TR" in activity["name"]:
                    activity["location"] = "TR"
                elif "/GLO" in activity["name"]:
                    activity["location"] = "GLO"

        # Getting products CIQUAL code when relevant
        if "ciqual" in activity["name"].lower():
            match = re.search(pattern=ciqual_pattern, string=activity["name"])
            activity["ciqual_code"] = match["ciqual"] if match is not None else ""

        # Putting SimaPro metadata in the activity fields directly and removing references to SimaPro
        if "simapro metadata" in activity:
            for sp_field, value in activity["simapro metadata"].items():
                if value != "Unspecified":
                    activity[sp_field] = value

            # Getting the Data Quality Rating of the data when relevant
            if "Comment" in activity["simapro metadata"]:
                match = re.search(
                    pattern=dqr_pattern, string=activity["simapro metadata"]["Comment"]
                )

                if match:
                    activity["DQR"] = {
                        "overall": float(match["overall"]),
                        "P": float(match["P"]),
                        "TiR": float(match["TiR"]),
                        "GR": float(match["GR"]),
                        "TeR": float(match["TeR"]),
                    }

            del activity["simapro metadata"]

        # Getting activity tags
        name_without_spaces = activity["name"].replace(" ", "")
        for packaging in AGRIBALYSE_PACKAGINGS:
            if f"|{packaging.replace(' ', '')}|" in name_without_spaces:
                activity["packaging"] = packaging

        for stage in AGRIBALYSE_STAGES:
            if f"|{stage.replace(' ', '')}" in name_without_spaces:
                activity["stage"] = stage

        for transport_type in AGRIBALYSE_TRANSPORT_TYPES:
            if f"|{transport_type.replace(' ', '')}|" in name_without_spaces:
                activity["transport_type"] = transport_type

        for preparation_mode in AGRIBALYSE_PREPARATION_MODES:
            if f"|{preparation_mode.replace(' ', '')}|" in name_without_spaces:
                activity["preparation_mode"] = preparation_mode

        if "simapro name" in activity:
            del activity["simapro name"]

        if "filename" in activity:
            del activity["filename"]
    agribalyse.write_database()
    print("Finished")


def import_ef(data=EF_CSV, project=PROJECT, db=BIOSPHERE):
    """
    Import file at path `data` linked to biosphere named `db`
    """
    print(f"Importing {db} database from {data}...")
    bw2data.projects.set_current(project)
    ef = bw2io.importers.SimaProLCIACSVImporter(data, biosphere=db)
    ef.statistics()
    ef.write_methods()
    print("Finished")


if __name__ == "__main__":
    bw2data.projects.set_current(PROJECT)
    # bw2io.bw2setup()

    # Import Ecoinvent
    if ECOINVENTDB in bw2data.databases:
        print(f"*** already imported: {ECOINVENTDB} ***")
    else:
        import_ecoinvent()

    # Import Agribalyse
    if AGRIBALYSEDB in bw2data.databases:
        print(f"*** already imported {AGRIBALYSEDB} ***")
    else:
        import_agribalyse()

    # Import methods
    if len([method for method in bw2data.methods if method[0] == EFMETHODS]) >= 1:
        print(f"*** already imported {EFMETHODS} ***")
    else:
        import_ef()
