#!/usr/bin/env python3

import argparse
import copy
import functools
from os.path import join

import bw2data
import bw2io
from bw2data.project import projects
from bw2io.strategies.generic import link_technosphere_by_activity_hash
from common.import_ import (
    add_missing_substances,
    import_simapro_csv,
)

PROJECT = "default"
AGRIBALYSE31 = "AGB3.1.1.20230306.CSV.zip"  # Agribalyse 3.1
AGRIBALYSE32 = "AGB32beta_08082024.CSV.zip"  # Agribalyse 3.2
GINKO = "CSV_369p_et_298chapeaux_final.csv.zip"  # additional organic processes
PASTOECO = "pastoeco.CSV.zip"
CTCPA = "Export emballages_PACK AGB_CTCPA.CSV.zip"
WFLDB = "WFLDB.CSV.zip"
BIOSPHERE = "biosphere3"


ACTIVITIES = "food/activities.json"
#
ACTIVITIES_TO_CREATE = "food/activities_to_create.json"

# excluded strategies and migrations
EXCLUDED = [
    "normalize_biosphere_names",
    "fix_localized_water_flows",  # both agb and ef31 adapted have localized wf
    "simapro-water",
]

GINKO_MIGRATIONS = [
    {
        "name": "diesel-fix",
        "description": "Fix Diesel process name",
        "data": {
            "fields": ("name",),
            "data": [
                (
                    (
                        "Diesel {GLO}| market group for | Cut-off, S - Copied from ecoinvent",
                    ),
                    {
                        "name": "Diesel {GLO}| market group for | Cut-off, S - Copied from Ecoinvent U"
                    },
                )
            ],
        },
    }
]
# migrations necessary to link some remaining unlinked technosphere activities
AGRIBALYSE_MIGRATIONS = [
    {
        "name": "agb-technosphere-fixes",
        "description": "Specific technosphere fixes for Agribalyse 3",
        "data": {
            "fields": ["name", "unit"],
            "data": [
                (
                    (
                        "Wastewater, average {Europe without Switzerland}| market for wastewater, average | Cut-off, S - Copied from Ecoinvent U",
                        "l",
                    ),
                    {"unit": "m3", "multiplier": 1e-3},
                ),
                (
                    (
                        "Wastewater, from residence {RoW}| market for wastewater, from residence | Cut-off, S - Copied from Ecoinvent U",
                        "l",
                    ),
                    {"unit": "m3", "multiplier": 1e-3},
                ),
                (
                    (
                        "Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {Europe without Switzerland}| heat production, natural gas, at industrial furnace >100kW | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {RER}| market group for | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Heat, district or industrial, natural gas {RoW}| market for heat, district or industrial, natural gas | Cut-off, S - Copied from Ecoinvent U",
                        "kWh",
                    ),
                    {"unit": "MJ", "multiplier": 3.6},
                ),
                (
                    (
                        "Land use change, perennial crop {BR}| market group for land use change, perennial crop | Cut-off, S - Copied from Ecoinvent U",
                        "m2",
                    ),
                    {"unit": "ha", "multiplier": 1e-4},
                ),
            ]
            + sum(
                [
                    [
                        [
                            (f"Water, river, {country}", "l"),
                            {"unit": "cubic meter", "multiplier": 0.001},
                        ],
                        [
                            (f"Water, well, {country}", "l"),
                            {"unit": "cubic meter", "multiplier": 0.001},
                        ],
                    ]
                    # only ES for AGB, all for Ginko
                    for country in ["ES", "ID", "CO", "CR", "EC", "IN", "BR", "US"]
                ],
                [],
            ),
        },
    }
]


def remove_azadirachtine(db):
    """Remove all exchanges with azadirachtine, except for apples"""
    new_db = []
    for ds in db:
        new_ds = copy.deepcopy(ds)
        new_ds["exchanges"] = [
            exc
            for exc in ds["exchanges"]
            if (
                "azadirachtin" not in exc.get("name", "").lower()
                or ds.get("name", "").lower().startswith("apple")
            )
        ]
        new_db.append(new_ds)
    return new_db


def remove_negative_land_use_on_tomato(db):
    """Remove transformation flows from urban on greenhouses
    that cause negative land-use on tomatoes"""
    new_db = []
    for ds in db:
        new_ds = copy.deepcopy(ds)
        if ds.get("name", "").lower().startswith("plastic tunnel"):
            new_ds["exchanges"] = [
                exc
                for exc in ds["exchanges"]
                if not exc.get("name", "")
                .lower()
                .startswith("transformation, from urban")
            ]
        else:
            pass
        new_db.append(new_ds)
    return new_db


def remove_some_processes(db):
    """Some processes make the whole import fail
    due to inability to parse the Input and Calculated parameters"""
    new_db = []
    for ds in db:
        new_ds = copy.deepcopy(ds)
        if ds.get("simapro metadata", {}).get("Process identifier") not in (
            "EI3CQUNI000025017103662",
        ):
            new_db.append(new_ds)
    return new_db


AGB_STRATEGIES = [remove_negative_land_use_on_tomato]

if __name__ == "__main__":
    """Import Agribalyse and additional processes"""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--recreate-activities",
        action="store_true",
        help="Delete and re-create the created activities",
    )
    args = parser.parse_args()

    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()
    add_missing_substances(PROJECT, BIOSPHERE)

    # AGRIBALYSE 3.1.1
    if (db := "Agribalyse 3.1.1") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", AGRIBALYSE31),
            db,
            migrations=AGRIBALYSE_MIGRATIONS,
            excluded_strategies=EXCLUDED,
            other_strategies=AGB_STRATEGIES,
        )
    else:
        print(f"{db} already imported")

    # AGRIBALYSE 3.2
    if (db := "Agribalyse 3.2 beta 08/08/2024") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", AGRIBALYSE32),
            db,
            migrations=AGRIBALYSE_MIGRATIONS,
            first_strategies=[remove_some_processes],
            excluded_strategies=EXCLUDED,
            other_strategies=AGB_STRATEGIES,
        )
    else:
        print(f"{db} already imported")

    # PASTO ECO
    if (db := "PastoEco") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", PASTOECO),
            db,
            excluded_strategies=EXCLUDED,
            other_strategies=[
                functools.partial(
                    link_technosphere_by_activity_hash,
                    external_db_name="Agribalyse 3.1.1",
                    fields=("name", "unit"),
                )
            ],
        )
    else:
        print(f"{db} already imported")

    # GINKO
    if (db := "Ginko") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", GINKO),
            db,
            excluded_strategies=EXCLUDED,
            other_strategies=[
                remove_negative_land_use_on_tomato,
                remove_azadirachtine,
                functools.partial(
                    link_technosphere_by_activity_hash,
                    external_db_name="Agribalyse 3.1.1",
                    fields=("name", "unit"),
                ),
            ],
            migrations=GINKO_MIGRATIONS + AGRIBALYSE_MIGRATIONS,
        )
    else:
        print(f"{db} already imported")

    # CTCPA
    if (db := "CTCPA") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", CTCPA), db, excluded_strategies=EXCLUDED
        )
    else:
        print(f"{db} already imported")

    # WFLDB
    if (db := "WFLDB") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", WFLDB), db, excluded_strategies=EXCLUDED
        )
    else:
        print(f"{db} already imported")

    if args.recreate_activities:
        if "Ecobalyse" in bw2data.databases:
            del bw2data.databases["Ecobalyse"]
