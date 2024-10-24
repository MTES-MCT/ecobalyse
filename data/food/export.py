#!/usr/bin/env python

"""Ingredients and processes export for food"""

import os
import sys
from os.path import dirname

import bw2calc
import bw2data
from bw2data.project import projects
from common import (
    fix_unit,
    order_json,
    remove_detailed_impacts,
    with_aggregated_impacts,
    with_corrected_impacts,
)
from common.export import (
    IMPACTS_JSON,
    cached_search,
    check_ids,
    compare_impacts,
    compute_impacts,
    csv_export_impact_comparison,
    display_changes,
    export_json,
    find_id,
    load_json,
    plot_impacts,
    progress_bar,
)
from common.impacts import impacts as impacts_py
from frozendict import frozendict

from food.ecosystemic_services.ecosystemic_services import (
    compute_animal_ecosystemic_services,
    compute_vegetal_ecosystemic_services,
    load_ecosystemic_dic,
    load_ugb_dic,
)

PROJECT_ROOT_DIR = dirname(dirname(dirname(__file__)))
ECOBALYSE_DATA_DIR = os.environ.get("ECOBALYSE_DATA_DIR")
if not ECOBALYSE_DATA_DIR:
    print(
        "\n🚨 ERROR: For the export to work properly, you need to specify ECOBALYSE_DATA_DIR env variable. It needs to point to the https://github.com/MTES-MCT/ecobalyse-private/ repository. Please, edit your .env file accordingly."
    )
    sys.exit(1)

# Configuration
PROJECT = "default"
DEFAULT_DB = "Agribalyse 3.1.1"
ACTIVITIES_FILE = f"{PROJECT_ROOT_DIR}/data/food/activities.json"
ECOSYSTEMIC_FACTORS_FILE = (
    f"{PROJECT_ROOT_DIR}/data/food/ecosystemic_services/ecosystemic_factors.csv"
)
FEED_FILE = f"{PROJECT_ROOT_DIR}/data/food/ecosystemic_services/feed.json"
UGB_FILE = f"{PROJECT_ROOT_DIR}/data/food/ecosystemic_services/ugb.csv"
INGREDIENTS_FILE = f"{PROJECT_ROOT_DIR}/public/data/food/ingredients.json"
PROCESSES_IMPACTS = f"{ECOBALYSE_DATA_DIR}/data/food/processes_impacts.json"
PROCESSES_AGGREGATED = f"{PROJECT_ROOT_DIR}/public/data/food/processes.json"
LAND_OCCUPATION_METHOD = ("selected LCI results", "resource", "land occupation")
GRAPH_FOLDER = f"{PROJECT_ROOT_DIR}/data/food/impact_comparison"


def create_ingredient_list(activities_tuple):
    print("Creating ingredient list...")
    return tuple(
        [
            to_ingredient(activity)
            for activity in list(activities_tuple)
            if "ingredient" in activity.get("process_categories", [])
        ]
    )


def to_ingredient(activity):
    return {
        "id": activity["id"],
        "name": activity["name"],
        "categories": activity.get("ingredient_categories", []),
        "search": activity["search"],
        "default": find_id(activity.get("database", DEFAULT_DB), activity),
        "default_origin": activity["default_origin"],
        "raw_to_cooked_ratio": activity["raw_to_cooked_ratio"],
        "density": activity["density"],
        "inedible_part": activity["inedible_part"],
        "transport_cooling": activity["transport_cooling"],
        "ecosystemicServices": activity.get("ecosystemicServices", {}),
        **(
            {"land_occupation": activity["land_occupation"]}
            if "land_occupation" in activity
            else {}
        ),
        **({"crop_group": activity["crop_group"]} if "crop_group" in activity else {}),
        **({"scenario": activity["scenario"]} if "scenario" in activity else {}),
        "visible": activity["visible"],
    }


def compute_land_occupation(activities_tuple):
    """"""
    print("Computing land occupation for activities")
    activities = list(activities_tuple)
    updated_activities = []
    for index, activity in enumerate(activities):
        progress_bar(index, len(activities))
        if "land_occupation" not in activity:
            lca = bw2calc.LCA(
                {
                    cached_search(
                        activity.get("database", DEFAULT_DB),
                        activity["search"],
                    ): 1
                }
            )
            lca.lci()
            lca.switch_method(LAND_OCCUPATION_METHOD)
            lca.lcia()
            activity["land_occupation"] = float("{:.10g}".format(lca.score))
        updated_activities.append(frozendict(activity))
    return tuple(updated_activities)


def create_process_list(activities):
    print("Creating process list...")
    return frozendict({activity["id"]: to_process(activity) for activity in activities})


def to_process(activity):
    return {
        "categories": activity.get("process_categories"),
        "comment": (
            prod[0]["comment"]
            if (
                prod := list(
                    cached_search(
                        activity.get("database", DEFAULT_DB), activity["search"]
                    ).production()
                )
            )
            else activity.get("comment", "")
        ),
        "displayName": activity["name"],
        "id": activity["id"],
        "identifier": find_id(activity.get("database", DEFAULT_DB), activity),
        "impacts": {},
        "name": cached_search(activity.get("database", DEFAULT_DB), activity["search"])[
            "name"
        ],
        "source": activity.get("database", DEFAULT_DB),
        "system_description": cached_search(
            activity.get("database", DEFAULT_DB), activity["search"]
        )["System description"],
        "unit": fix_unit(
            cached_search(activity.get("database", DEFAULT_DB), activity["search"])[
                "unit"
            ]
        ),
        # those are removed at the end:
        "search": activity["search"],
    }


if __name__ == "__main__":
    projects.set_current(PROJECT)
    bw2data.config.p["biosphere_database"] = "biosphere3"

    # keep the previous processes with old impacts
    oldprocesses = load_json(PROCESSES_IMPACTS)
    activities = tuple(load_json(ACTIVITIES_FILE))

    activities_land_occ = compute_land_occupation(activities)
    ingredients = create_ingredient_list(activities_land_occ)
    check_ids(ingredients)

    processes = create_process_list(activities_land_occ)

    # ecosystemic factors
    ecosystemic_factors = load_ecosystemic_dic(ECOSYSTEMIC_FACTORS_FILE)
    ingredients_veg_es = compute_vegetal_ecosystemic_services(
        ingredients, ecosystemic_factors
    )

    feed_file = load_json(FEED_FILE)
    ugb = load_ugb_dic(UGB_FILE)
    ingredients_animal_es = compute_animal_ecosystemic_services(
        ingredients_veg_es, activities_land_occ, ecosystemic_factors, feed_file, ugb
    )

    if len(sys.argv) == 1:  # just export.py
        processes_impacts = compute_impacts(processes, DEFAULT_DB, impacts_py)
    elif len(sys.argv) > 1 and sys.argv[1] == "compare":  # export.py compare
        impacts_compared_dic = compare_impacts(processes, DEFAULT_DB, impacts_py)
        csv_export_impact_comparison(impacts_compared_dic, "food")
        for process_name, values in impacts_compared_dic.items():
            print(f"Plotting {process_name}")
            simapro_impacts = values["simapro_impacts"]
            brightway_impacts = values["brightway_impacts"]
            os.makedirs(GRAPH_FOLDER, exist_ok=True)
            plot_impacts(
                process_name,
                simapro_impacts,
                brightway_impacts,
                GRAPH_FOLDER,
                IMPACTS_JSON,
            )
        print("Charts have been generated and saved as PNG files.")
        sys.exit(0)
    else:
        print("Wrong argument: either no args or 'compare'")
        sys.exit(1)

    processes_corrected_impacts = with_corrected_impacts(
        IMPACTS_JSON, processes_impacts
    )
    processes_aggregated_impacts = with_aggregated_impacts(
        IMPACTS_JSON, processes_corrected_impacts
    )

    # Export

    export_json(order_json(activities_land_occ), ACTIVITIES_FILE)
    export_json(order_json(ingredients_animal_es), INGREDIENTS_FILE)
    display_changes("id", oldprocesses, processes_corrected_impacts)
    export_json(
        order_json(list(processes_aggregated_impacts.values())), PROCESSES_IMPACTS
    )

    export_json(
        order_json(
            remove_detailed_impacts(list(processes_aggregated_impacts.values()))
        ),
        PROCESSES_AGGREGATED,
    )
