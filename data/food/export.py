#!/usr/bin/env python
# coding: utf-8

"""Export des ingrédients et des processes de l'alimentaire"""

import bw2calc
import bw2data
import json
from bw2data.project import projects
from common.impacts import impacts as impacts_definition
from common.export import (
    with_subimpacts,
    cached_search,
    with_corrected_impacts,
    display_changes,
    load_json,
    export_json,
    progress_bar,
)
from food.ecosystemic_services.ecosystemic_services import (
    ecosystemic_services_list,
    ecs_transform,
    load_ecosystemic_dic,
    plot_ecs_transformations,
)

# Configuration
CONFIG = {
    "PROJECT": "food",
    "AGRIBALYSE": "Agribalyse 3.1.1",
    "BIOSPHERE": "Agribalyse 3.1.1 biosphere",
    "ACTIVITIES_FILE": "activities.json",
    "IMPACTS_FILE": "../../public/data/impacts.json",
    "ECOSYSTEMIC_FACTORS_FILE": "ecosystemic_services/ecosystemic_factors.csv",
    "ECS_PNG": "ecosystemic_services/ecs_transformations.png",
    "INGREDIENTS_FILE": "../../public/data/food/ingredients.json",
    "PROCESSES_FILE": "../../public/data/food/processes.json",
    "LAND_OCCUPATION_METHOD": ("selected LCI results", "resource", "land occupation"),
}


def setup_environment():
    projects.set_current(CONFIG["PROJECT"])
    bw2data.config.p["biosphere_database"] = CONFIG["BIOSPHERE"]


def sync_datapackages():
    print("Syncing datackages...")
    for method in bw2data.methods:
        bw2data.Method(method).process()

    for database in bw2data.databases:
        bw2data.Database(database).process()


def find_id(dbname, activity):
    return cached_search(dbname, activity["search"]).get(
        "Process identifier", activity["id"]
    )


def create_ingredient_list(activities):
    print("Creating ingredient list...")
    return [
        process_activity_for_ingredient(activity)
        for activity in activities
        if activity["category"] == "ingredient"
    ]


def process_activity_for_ingredient(activity):
    return {
        "id": activity["id"],
        "name": activity["name"],
        "categories": [c for c in activity["categories"] if c != "ingredient"],
        "default": find_id(activity.get("database", CONFIG["AGRIBALYSE"]), activity),
        "default_origin": activity["default_origin"],
        "raw_to_cooked_ratio": activity["raw_to_cooked_ratio"],
        "density": activity["density"],
        "inedible_part": activity["inedible_part"],
        "transport_cooling": activity["transport_cooling"],
        "ecosystemicServices": activity.get("ecosystemicServices", {}),
        **(
            {"land_footprint": activity["land_footprint"]}
            if "land_footprint" in activity
            else {}
        ),
        **({"crop_group": activity["crop_group"]} if "crop_group" in activity else {}),
        **({"scenario": activity["scenario"]} if "scenario" in activity else {}),
        "search": activity["search"],
        "database": activity.get("database", CONFIG["AGRIBALYSE"]),
        "visible": activity["visible"],
    }


def compute_land_occupation(activities):
    """"""
    print("Computing land occupation for ingredients")
    for index, activity in enumerate(activities):
        progress_bar(index, len(activities))
        lca = bw2calc.LCA(
            {
                cached_search(
                    activity.get("database", CONFIG["AGRIBALYSE"]),
                    activity["search"],
                ): 1
            }
        )
        lca.lci()
        lca.switch_method(CONFIG["LAND_OCCUPATION_METHOD"])
        lca.lcia()
        activity["land_occupation"] = float("{:.10g}".format(lca.score))


def check_ids(ingredients):
    # Check the id is lowercase and does not contain spaces
    for ingredient in ingredients:
        if (
            ingredient["id"].lower() != ingredient["id"]
            or ingredient["id"].replace(" ", "") != ingredient["id"]
        ):
            raise ValueError(
                f"This identifier is not lowercase or contains spaces: {ingredient['id']}"
            )


def compute_ecosystemic_factors(ingredients, ecosystemic_factors):
    for ingredient in ingredients:
        land_footprint = ingredient.get("land_footprint")
        crop_group = ingredient.get("crop_group")
        scenario = ingredient.get("scenario")

    if land_footprint and crop_group and scenario:
        print(f"Computing ecosystemic services for {ingredient['id']}")
        for eco_service in ecosystemic_services_list:
            factor_raw = ecosystemic_factors[crop_group][eco_service][scenario]
            factor_transformed = ecs_transform(eco_service, factor_raw)
            factor_final = factor_transformed * land_footprint
            ingredient.setdefault("ecosystemicServices", {})[eco_service] = float(
                "{:.5g}".format(factor_final)
            )
    return ingredients


def create_process_list(activities):
    print("Creating process list...")
    return {
        activity[id]: process_activity_for_processes(activity)
        for activity in activities
    }


def process_activity_for_processes(activity):
    AGRIBALYSE = CONFIG["AGRIBALYSE"]
    return {
        "id": activity["id"],
        "name": cached_search(activity.get("database", AGRIBALYSE), activity["search"])[
            "name"
        ],
        "displayName": activity["name"],
        "unit": cached_search(activity.get("database", AGRIBALYSE), activity["search"])[
            "unit"
        ],
        "identifier": find_id(activity.get("database", AGRIBALYSE), activity),
        "system_description": cached_search(
            activity.get("database", AGRIBALYSE), activity["search"]
        )["System description"],
        "category": activity.get("category"),
        "comment": (
            prod[0]["comment"]
            if (
                prod := list(
                    cached_search(
                        activity.get("database", AGRIBALYSE), activity["search"]
                    ).production()
                )
            )
            else activity.get("comment", "")
        ),
        # those are removed at the end:
        "database": activity.get("database", AGRIBALYSE),
        "search": activity["search"],
    }


def compute_impacts(processes):
    print("Computing impacts:")
    for index, (processid, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        lca = bw2calc.LCA(
            {
                cached_search(
                    process.get("database", CONFIG["AGRIBALYSE"]), process["search"]
                ): 1
            }
        )
        lca.lci()
        for key, method in impacts_definition.items():
            lca.switch_method(method)
            lca.lcia()
            process.setdefault("impacts", {})[key] = float("{:.10g}".format(lca.score))

        # compute subimpacts
        process = with_subimpacts(process)

        # remove unneeded attributes
        for attribute in ["search"]:
            if attribute in process:
                del process[attribute]


if __name__ == "__main__":
    setup_environment()

    # keep the previous processes with old impacts
    oldprocesses = load_json(CONFIG["PROCESSES_FILE"])
    activities = load_json(CONFIG["ACTIVITIES_FILE"])

    ingredients = create_ingredient_list(activities)
    compute_land_occupation(activities)

    plot_ecs_transformations(save_path=CONFIG["ECS_PNG"])
    ecosystemic_factors = load_ecosystemic_dic(CONFIG["ECOSYSTEMIC_FACTORS_FILE"])
    ingredients = compute_ecosystemic_factors(ingredients, ecosystemic_factors)

    check_ids(ingredients)
    processes = create_process_list(activities)
    compute_impacts(processes)

    processes = with_corrected_impacts(load_json(CONFIG["IMPACTS_FILE"]), processes)

    # Export

    export_json(activities, CONFIG["ACTIVITIES_FILE"])
    export_json(ingredients, CONFIG["INGREDIENTS_FILE"])
    display_changes("id", oldprocesses, processes)
    export_json(processes, CONFIG["PROCESSES_FILE"])
