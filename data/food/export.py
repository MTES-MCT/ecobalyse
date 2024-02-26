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
    "INGREDIENTS_FILE": "../../public/data/food/ingredients.json",
    "PROCESSES_FILE": "../../public/data/food/processes.json",
}

def setup_environment():
    projects.set_current(CONFIG["PROJECT"])
    bw2data.config.p["biosphere_database"] = CONFIG["BIOSPHERE"]

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
        {
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
            **(
                {"crop_group": activity["crop_group"]}
                if "crop_group" in activity
                else {}
            ),
            **({"scenario": activity["scenario"]} if "scenario" in activity else {}),
            "visible": activity["visible"],
        }
        for activity in activities
        if activity["category"] == "ingredient"
    ]
 
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
    AGRIBALYSE = CONFIG["AGRIBALYSE"]
    return {
        activity["id"]: {
            "id": activity["id"],
            "name": cached_search(
                activity.get("database", AGRIBALYSE), activity["search"]
            )["name"],
            "displayName": activity["name"],
            "unit": cached_search(
                activity.get("database", AGRIBALYSE), activity["search"]
            )["unit"],
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
        for activity in activities
    }

if __name__ == "__main__":
    # keep the previous processes with old impacts
    with open(CONFIG["PROCESSES_FILE"]) as f:
        oldprocesses = json.load(f)

    with open(CONFIG["ACTIVITIES_FILE"], "r") as f:
        activities = json.load(f)

    ingredients = create_ingredient_list(activities)

    # compute the ecosystemic services
    plot_ecs_transformations(save_path="ecosystemic_services/ecs_transformations.png")
    ecosystemic_factors = load_ecosystemic_dic(CONFIG["ECOSYSTEMIC_FACTORS_FILE"])
    ingredients = compute_ecosystemic_factors(ingredients, ecosystemic_factors)

    # Check the id is lowercase and does not contain spaces
    for ingredient in ingredients:
        if (
            ingredient["id"].lower() != ingredient["id"]
            or ingredient["id"].replace(" ", "") != ingredient["id"]
        ):
            raise ValueError(
                f"This identifier is not lowercase or contains spaces: {ingredient['id']}"
            )
        
    processes = create_process_list(activities)
    
    # compute the impacts of base processes
    print("Computing impacts:")
    for index, (processid, process) in enumerate(processes.items()):
        print(
            "("
            + (index) * "•"
            + (len(processes) - index) * " "
            + f") {str(index)}/{len(processes)}",
            end="\r",
        )
        lca = bw2calc.LCA(
            {cached_search(process.get("database", CONFIG["AGRIBALYSE"]), process["search"]): 1}
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

    print("Computing corrected impacts (etf-c, htc-c, htn-c)...")
    with open(CONFIG["IMPACTS_FILE"], "r") as f:
        processes = with_corrected_impacts(json.load(f), processes)

    # export ingredients
    with open(CONFIG["INGREDIENTS_FILE"], "w") as outfile:
        json.dump(ingredients, outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"\nExported {len(ingredients)} ingredients to {CONFIG['INGREDIENTS_FILE']}")

    # display impacts that have changed
    display_changes("id", oldprocesses, processes)

    # export processes
    with open(CONFIG["PROCESSES_FILE"], "w") as outfile:
        json.dump(list(processes.values()), outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"Exported {len(processes)} processes to {CONFIG['PROCESSES_FILE']}")
