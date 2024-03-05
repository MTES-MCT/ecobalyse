#!/usr/bin/env python3

from bw2data.project import projects
from bw2io.strategies.generic import link_iterable_by_fields
from common.import_ import (
    add_created_activities,
    add_missing_substances,
    import_simapro_csv,
    sync_datapackages,
)
import argparse
import bw2data
import bw2io
import functools

PROJECT = "food"
AGRIBALYSE = "AGB3.1.1.20230306.CSV.zip"  # Agribalyse
GINKO = "CSV_369p_et_298chapeaux_final.csv.zip"  # additional organic processes
PASTOECO = [
    "CONVEN~1.CSV.zip",
    "Cow milk, conventional, highland milk system, pastoral farming system, at farm gate {FR} U.CSV.zip",
    "Cow milk, conventional, lowland milk system, silage maize 47%, at farm gate {FR} U.CSV.zip",
    "Cull cow, conventional, highland milk system, pastoral farming system, at farm gate {FR} U.CSV.zip",
    "Lamb, organic, system number 3, at farm gate {FR} U.CSV.zip",
    "Young suckler bull, label rouge, fattening system, pastoral farming system, at farm gate {FR} U.CSV.zip",
]
CTCPA = "Export emballages_PACK AGB_CTCPA.CSV.zip"
WFLDB = "WFLDB.CSV.zip"
BIOSPHERE = "biosphere3"


ACTIVITIES = "food/activities.json"
#
ACTIVITIES_TO_CREATE = "food/activities_to_create.json"

# excluded strategies and migrations
EXCLUDED = [
    "normalize_simapro_biosphere_names",
    "normalize_biosphere_names",
    "fix_localized_water_flows",  # both agb and ef31 adapted have localized wf
    "simapro-water",
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
GINKO_STRATEGIES = [
    functools.partial(
        link_iterable_by_fields,
        other=bw2data.Database("Agribalyse 3.1.1"),
        kind="technosphere",
    )
]


def main():
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

    # PASTO ECO
    if (db := "PastoEco") not in bw2data.databases:
        for p in PASTOECO:
            import_simapro_csv(p, db, excluded_strategies=EXCLUDED)
    else:
        print(f"{db} already imported")

    # CTCPA
    if (db := "CTCPA") not in bw2data.databases:
        import_simapro_csv(CTCPA, db, excluded_strategies=EXCLUDED)
    else:
        print(f"{db} already imported")

    # WFLDB
    if (db := "WFLDB") not in bw2data.databases:
        import_simapro_csv(WFLDB, db, excluded_strategies=EXCLUDED)
    else:
        print(f"{db} already imported")

    # AGRIBALYSE
    if (db := "Agribalyse 3.1.1") not in bw2data.databases:
        print("first Agribalyse...")
        import_simapro_csv(
            AGRIBALYSE,
            db,
            migrations=AGRIBALYSE_MIGRATIONS,
            excluded_strategies=EXCLUDED,
        )
        print("then Ginko...")
        import_simapro_csv(
            GINKO,
            "Agribalyse 3.1.1",
            excluded_strategies=EXCLUDED,
            migrations=AGRIBALYSE_MIGRATIONS,
            # other_strategies=GINKO_STRATEGIES,
            source="Ginko",
        )
    else:
        print(f"{db} already imported")

    if args.recreate_activities:
        del bw2data.databases["Ecobalyse"]

    if (db := "Ecobalyse") not in bw2data.databases:
        add_created_activities(db, ACTIVITIES_TO_CREATE)
    else:
        print(f"{db} already imported")
    sync_datapackages()


if __name__ == "__main__":
    main()
