#!/usr/bin/env python3


from os.path import join

import bw2data
import bw2io
from bw2data.project import projects
from common.import_ import add_missing_substances, import_simapro_csv

# Ecoinvent
EI391 = "./Ecoinvent3.9.1.CSV.zip"
EI310 = "./Ecoinvent3.10.CSV.zip"
WOOL = "./wool.CSV.zip"
BIOSPHERE = "biosphere3"
PROJECT = "default"
EXCLUDED = [
    "fix_localized_water_flows",  # both agb and ef31 adapted have localized wf
    "simapro-water",
]


def organic_cotton_irrigation(db):
    """add irrigation to the organic cotton"""
    for ds in db:
        if ds.get("simapro metadata", {}).get("Process identifier") in (
            "MTE00149000081182217968",  # EI 3.9.1
            "EI3ARUNI000011519618166",  # EI 3.10
        ):
            # add: irrigation//[IN] market for irrigation;m3;0.75;Undefined;0;0;0;;
            ds["exchanges"].append(
                {
                    "amount": 0.75,
                    "categories": ("Materials/fuels",),
                    "comment": "",
                    "loc": 0.75,
                    "name": "irrigation//[IN] market for irrigation",
                    "negative": False,
                    "type": "technosphere",
                    "uncertainty type": 2,
                    "unit": "cubic meter",
                }
            )
    return db


STRATEGIES = [organic_cotton_irrigation]


def use_unit_processes(db):
    """the woolmark dataset comes with dependent processes
    which are set as system processes.
    EI3.10 has these processes but as unit processes.
    So we change the name such as the linking be done"""
    for ds in db:
        for exc in ds["exchanges"]:
            if exc["name"].endswith("Cut-off, S"):
                exc["name"].replace("Cut-off, S", "Cut-off, U")
    return db


def main():
    projects.set_current(PROJECT)
    # projects.create_project(PROJECT, activate=True, exist_ok=True)
    bw2data.preferences["biosphere_database"] = BIOSPHERE
    bw2io.bw2setup()
    add_missing_substances(PROJECT, BIOSPHERE)

    if (db := "Ecoinvent 3.9.1") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", EI391),
            db,
            first_strategies=STRATEGIES,
            excluded_strategies=EXCLUDED,
        )
    else:
        print(f"{db} already imported")

    if (db := "Ecoinvent 3.10") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", EI310),
            db,
            first_strategies=STRATEGIES,
            excluded_strategies=EXCLUDED,
        )

    else:
        print(f"{db} already imported")

    if (db := "Woolmark") not in bw2data.databases:
        import_simapro_csv(
            join("..", "..", "dbfiles", WOOL),
            db,
            first_strategies=[use_unit_processes],
            external_db="Ecoinvent 3.10",  # wool is linked with EI 3.10
            excluded_strategies=EXCLUDED,
        )
    else:
        print(f"{db} already imported")


if __name__ == "__main__":
    main()
