#!/usr/bin/env python
# coding: utf-8

"""Export des ingrédients et des processes de l'alimentaire"""

from bw2data.project import projects
from common.export import (
    with_subimpacts,
    search,
    with_corrected_impacts,
    display_changes,
)
from common.impacts import impacts as impacts_definition
import bw2calc
import bw2data
import json


# Input
PROJECT = "food"
AGRIBALYSE = "Agribalyse 3.1.1"
BIOSPHERE = AGRIBALYSE + " biosphere"
ACTIVITIES = "activities.json"
IMPACTS = "../../public/data/impacts.json"  # TODO move the impact definition somewhere else and remove base impact
# Output
INGREDIENTS = "../../public/data/food/ingredients.json"
PROCESSES = "../../public/data/food/processes.json"

projects.set_current(PROJECT)
# projects.activate_project(PROJECT)
bw2data.config.p["biosphere_database"] = BIOSPHERE


def find_id(dbname, activity):
    print(activity["search"])
    return search(dbname, activity["search"]).get("Process identifier", activity["id"])


if __name__ == "__main__":
    # keep the previous processes with old impacts
    with open(PROCESSES) as f:
        oldprocesses = json.load(f)

    with open(ACTIVITIES, "r") as f:
        activities = json.load(f)

    print("Creating ingredient list...")
    ingredients = [
        {
            "id": activity["id"],
            "name": activity["name"],
            "categories": [c for c in activity["categories"] if c != "ingredient"],
            "default": find_id(activity.get("database", AGRIBALYSE), activity),
            "default_origin": activity["default_origin"],
            "raw_to_cooked_ratio": activity["raw_to_cooked_ratio"],
            "density": activity["density"],
            "inedible_part": activity["inedible_part"],
            "transport_cooling": activity["transport_cooling"],
            "visible": activity["visible"],
            "complements": activity.get("complements", []),
        }
        for activity in activities
        if activity["category"] == "ingredient"
    ]
    # cleanup unuseful attributes
    for ingredient in ingredients:
        if (
            "animal_product" not in ingredient["categories"]
            and "dairy_product" not in ingredient["categories"]
            and "animal-welfare" in ingredient.get("complements", [])
        ):
            del ingredient["complements"]["animal-welfare"]

    # Check the id is lowercase and does not contain spaces
    for ingredient in ingredients:
        if (
            ingredient["id"].lower() != ingredient["id"]
            or ingredient["id"].replace(" ", "") != ingredient["id"]
        ):
            raise ValueError(
                f"This identifier is not lowercase or contains spaces: {ingredient['id']}"
            )

    print("Creating process list...")
    processes = {
        activity["id"]: {
            "id": activity["id"],
            "name": search(activity.get("database", AGRIBALYSE), activity["search"])[
                "name"
            ],
            "displayName": activity["name"],
            "unit": search(activity.get("database", AGRIBALYSE), activity["search"])[
                "unit"
            ],
            "identifier": find_id(activity.get("database", AGRIBALYSE), activity),
            "system_description": search(
                activity.get("database", AGRIBALYSE), activity["search"]
            )["System description"],
            "category": activity.get("category"),
            "comment": list(
                search(
                    activity.get("database", AGRIBALYSE), activity["search"]
                ).production()
            )[0]["comment"],
            # those are removed at the end:
            "search": activity["search"],
        }
        for activity in activities
    }
    # remove empty category
    for p in processes:
        if not processes[p]["category"]:
            del processes[p]["category"]

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
            {search(process.get("database", AGRIBALYSE), process["search"]): 1}
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
    with open(IMPACTS, "r") as f:
        processes = with_corrected_impacts(json.load(f), processes)

    # export ingredients
    with open(INGREDIENTS, "w") as outfile:
        json.dump(ingredients, outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"\nExported {len(ingredients)} ingredients to {INGREDIENTS}")

    # display impacts that have changed
    display_changes("id", oldprocesses, processes)

    # export processes
    with open(PROCESSES, "w") as outfile:
        json.dump(list(processes.values()), outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"Exported {len(processes)} processes to {PROCESSES}")
