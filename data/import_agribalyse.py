#!/usr/bin/env python3

from bw2data.project import projects
from subprocess import call
from tqdm import tqdm
from zipfile import ZipFile
import bw2data
import bw2io
import re
import json
from common.export import (
    with_subimpacts,
    search,
    with_corrected_impacts,
    display_changes,
    create_activity,
    delete_exchange,
    new_exchange,
)

PROJECT = "food"
# Agribalyse
DATAPATH = "AGB3.1.1.20230306.CSV.zip"
DBNAME = "Agribalyse 3.1.1"
BIOSPHERE = "biosphere3"


ACTIVITIES = "food/activities.json"
#
ACTIVITIES_TO_CREATE = "food/activities_to_create.json"

# excluded strategies and migrations
EXCLUDED = [
    "normalize_simapro_biosphere_names",
    "normalize_biosphere_names",
    "fix_localized_water_flows",
    "simapro-water",
]

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


def import_agribalyse(
    datapath=DATAPATH,
    project=PROJECT,
    dbname=DBNAME,
    biosphere=BIOSPHERE,
    migrations=AGRIBALYSE_MIGRATIONS,
):
    """
    Import file at path `datapath` into database named `dbname`, and apply provided brightway `migrations`.
    """
    projects.set_current(project)
    # projects.create_project(project, activate=True, exist_ok=True)

    # Core migrations
    print("### Creating core data migrations")
    if len(bw2io.migrations) < 13:
        bw2io.create_core_migrations()
    else:
        print("### Core migrations are already installed")

    print(f"### Importing {dbname} database from {datapath}...")
    with ZipFile(datapath) as zf:
        print("### Extracting the zip file...")
        zf.extractall()
        datapath = datapath[0:-4]

    print("### Patching Agribalyse...")
    # sed is faster than Python
    # `yield` is used as a variable in some Simapro parameters. bw2parameters cannot handle it:
    call("sed -i 's/yield/Yield_/g' " + datapath, shell=True)
    # Fix some errors in Agribalyse:
    call("sed -i 's/01\\/03\\/2005/1\\/3\\/5/g' " + datapath, shell=True)
    call("sed -i 's/0;001172/0,001172/' " + datapath, shell=True)

    print("### Importing Agribalyse...")
    # Do the import and apply "strategies"
    agribalyse = bw2io.importers.simapro_csv.SimaProCSVImporter(
        datapath, dbname, normalize_biosphere=True
    )

    print("### Applying strategies...")
    # exclude strategies/migrations in EXCLUDED
    agribalyse.strategies = [
        s for s in agribalyse.strategies if not any([e in repr(s) for e in EXCLUDED])
    ]

    agribalyse.apply_strategies()

    # Apply provided migrations
    for migration in migrations:
        print(f"### Applying custom migration: {migration['description']}")
        bw2io.Migration(migration["name"]).write(
            migration["data"],
            description=migration["description"],
        )
        agribalyse.migrate(migration["name"])

    agribalyse.statistics()
    print("### Adding unlinked flows and activities...")
    bw2data.Database(biosphere).register()
    agribalyse.add_unlinked_flows_to_biosphere_database(biosphere)
    agribalyse.add_unlinked_activities()
    agribalyse.statistics()
    dsdict = {ds["code"]: ds for ds in agribalyse.data}
    agribalyse.data = list(dsdict.values())

    dqr_pattern = r"The overall DQR of this product is: (?P<overall>[\d.]+) {P: (?P<P>[\d.]+), TiR: (?P<TiR>[\d.]+), GR: (?P<GR>[\d.]+), TeR: (?P<TeR>[\d.]+)}"
    ciqual_pattern = r"\[Ciqual code: (?P<ciqual>[\d_]+)\]"
    location_pattern = r"\{(?P<location>[\w ,\/\-\+]+)\}"
    location_pattern_2 = r"\/\ *(?P<location>[\w ,\/\-]+) U$"

    print("### Applying additional transformations...")
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
    print(f"### Finished importing {DBNAME}")


def add_created_activities(dbname=DBNAME):
    """
    Once the agribalyse database has been imported, add to the database the new activities defined in `ACTIVITIES_TO_CREATE.json`.
    Example: ingredient flour-organic is not in agribalyse so it is created at this step
    """
    with open(ACTIVITIES_TO_CREATE, "r") as f:
        activities_data = json.load(f)

    for activity_data in activities_data:
        activity = search(dbname, activity_data["search"])

        # create a new variant activity
        # Example: this is where we create the flour-organic activity
        activity_variant = create_activity(
            dbname, activity, f"{activity_data['search']} {activity_data['suffix']}"
        )
        seed_activity = search(dbname, activity_data["seed_activity"])
        seed_activity_variant = search(dbname, activity_data["seed_activity_variant"])

        # if the activity has no subactivities, we can directly replace the seed activity with the seed activity variant
        if not activity_data["subactivities"]:
            new_exchange(activity_variant, seed_activity, seed_activity_variant)
            delete_exchange(activity_variant, seed_activity)

        # else we have to iterate through subactivities and create a new variant activity for each subactivity
        # Example: for flour-organic we have to dig through the `global milling process` subactivity before we can replace the wheat activity with the wheat-organic activity
        else:
            for i, act_sub_data in enumerate(activity_data["subactivities"]):
                sub_activity = search(dbname, act_sub_data)

                # create a new sub activity variant
                sub_activity_variant = create_activity(
                    dbname,
                    sub_activity,
                    f"{sub_activity['name']} {activity_data['suffix']}",
                )

                # link the newly create sub_activity_variant to the parent activity_variant
                new_exchange(activity_variant, sub_activity, sub_activity_variant)

                # for the last sub activity, replace the seed activity with the seed activity variant
                # Example: for flour-organic this is where the replace the wheat activity with the wheat-organic activity
                if i == len(activity_data["subactivities"]) - 1:
                    new_exchange(
                        sub_activity_variant, seed_activity, seed_activity_variant
                    )
                    delete_exchange(sub_activity_variant, seed_activity)

                # update the activity_variant (parent activity)
                activity_variant = sub_activity_variant


def main():
    # Import Agribalyse
    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()

    if DBNAME not in bw2data.databases:
        import_agribalyse()
        add_created_activities()
    else:
        print(f"{DBNAME} already imported")


if __name__ == "__main__":
    main()
