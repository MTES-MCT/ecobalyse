#!/usr/bin/env python
# coding: utf-8

"""Export des ingrédients et des processes de l'alimentaire"""

from bw2data.project import projects
from common.impacts import impacts as definitions, main_method, bytrigram
from common.export import (
    cached_search,
    display_changes,
    export_json,
    load_json,
    progress_bar,
    spproject,
    with_corrected_impacts,
    with_subimpacts,
)
from food.ecosystemic_services.ecosystemic_services import (
    load_ecosystemic_dic,
    load_ugb_dic,
    plot_ecs_transformations,
    compute_vegetal_ecosystemic_services,
    compute_animal_ecosystemic_services,
)
import bw2calc
import bw2data
import json
import requests
import urllib.parse

# Configuration
CONFIG = {
    "PROJECT": "food",
    "AGRIBALYSE": "Agribalyse 3.1.1",
    "BIOSPHERE": "Agribalyse 3.1.1 biosphere",
    "ACTIVITIES_FILE": "activities.json",
    "IMPACTS_FILE": "../../public/data/impacts.json",
    "ECOSYSTEMIC_FACTORS_FILE": "ecosystemic_services/ecosystemic_factors.csv",
    "FEED_FILE": "ecosystemic_services/feed.json",
    "UGB_FILE": "ecosystemic_services/ugb.csv",
    "ECS_PNG": "ecosystemic_services/ecs_transformations.png",
    "INGREDIENTS_FILE": "../../public/data/food/ingredients.json",
    "PROCESSES_FILE": "../../public/data/food/processes.json",
    "LAND_OCCUPATION_METHOD": ("selected LCI results", "resource", "land occupation"),
}


def setup_environment():
    projects.set_current(CONFIG["PROJECT"])
    bw2data.config.p["biosphere_database"] = CONFIG["BIOSPHERE"]


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
        "search": activity["search"],
        "default": find_id(activity.get("database", CONFIG["AGRIBALYSE"]), activity),
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


def compute_land_occupation(activities):
    """"""
    print("Computing land occupation for activities")
    for index, activity in enumerate(activities):
        progress_bar(index, len(activities))
        if "land_occupation" not in activity:
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


def create_process_list(activities):
    print("Creating process list...")
    return {
        activity["id"]: process_activity_for_processes(activity)
        for activity in activities
        if "not_a_process" not in activity["categories"]
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
    for index, (_, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))

        # simapro
        activity = cached_search(
            process.get("database", CONFIG["AGRIBALYSE"]), process["search"]
        )
        strprocess = urllib.parse.quote(activity["name"], encoding=None, errors=None)
        project = urllib.parse.quote(spproject(activity), encoding=None, errors=None)
        method = urllib.parse.quote(main_method, encoding=None, errors=None)
        results = bytrigram(
            definitions,
            json.loads(
                requests.get(
                    f"http://simapro.ecobalyse.fr:8000/impact?process={strprocess}&project={project}&method={method}"
                ).content
            ),
        )
        # WARNING assume remote is in m3 or MJ (couldn't find unit from COM intf)
        if process["unit"] == "kilowatt hour" and type(results) is dict:
            results = {k: v * 3.6 for k, v in results.items()}
        if process["unit"] == "litre" and type(results) is dict:
            results = {k: v / 1000 for k, v in results.items()}

        if type(results) is dict and results:
            # simapro succeeded
            process["impacts"] = results
            print(f"got impacts from simapro for: {process['name']}")
        else:
            # simapro failed (unexisting Ecobalyse project or some other reason)
            # brightway
            lca = bw2calc.LCA(
                {
                    cached_search(
                        process.get("database", CONFIG["AGRIBALYSE"]), process["search"]
                    ): 1
                }
            )
            lca.lci()
            for key, method in definitions.items():
                lca.switch_method(method)
                lca.lcia()
                process.setdefault("impacts", {})[key] = float(
                    "{:.10g}".format(lca.score)
                )
            print(f"got impacts from brightway for: {process['name']}")

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

    compute_land_occupation(activities)
    ingredients = create_ingredient_list(activities)

    plot_ecs_transformations(save_path=CONFIG["ECS_PNG"])
    ecosystemic_factors = load_ecosystemic_dic(CONFIG["ECOSYSTEMIC_FACTORS_FILE"])
    compute_vegetal_ecosystemic_services(ingredients, ecosystemic_factors)

    feed_file = load_json(CONFIG["FEED_FILE"])
    ugb = load_ugb_dic(CONFIG["UGB_FILE"])
    compute_animal_ecosystemic_services(
        ingredients, activities, ecosystemic_factors, feed_file, ugb
    )

    check_ids(ingredients)
    processes = create_process_list(activities)
    compute_impacts(processes)

    processes = with_corrected_impacts(load_json(CONFIG["IMPACTS_FILE"]), processes)

    # Export

    export_json(activities, CONFIG["ACTIVITIES_FILE"])
    export_json(ingredients, CONFIG["INGREDIENTS_FILE"])
    display_changes("id", oldprocesses, processes)
    export_json(list(processes.values()), CONFIG["PROCESSES_FILE"])
