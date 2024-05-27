#!/usr/bin/env python
# coding: utf-8

"""Export des ingrédients et des processes de l'alimentaire"""

import json
import sys
import urllib.parse

import bw2calc
import bw2data
import matplotlib
import numpy
import requests
from bw2data.project import projects
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
from common.impacts import bytrigram, main_method
from common.impacts import impacts as definitions
from frozendict import frozendict

from food.ecosystemic_services.ecosystemic_services import (
    compute_animal_ecosystemic_services,
    compute_vegetal_ecosystemic_services,
    load_ecosystemic_dic,
    load_ugb_dic,
)

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
    "INGREDIENTS_FILE": "../../public/data/food/ingredients.json",
    "PROCESSES_FILE": "../../public/data/food/processes_impacts.json",
    "LAND_OCCUPATION_METHOD": ("selected LCI results", "resource", "land occupation"),
}
with open("../public/data/impacts.json") as f:
    IMPACTS = json.load(f)


def setup_environment():
    projects.set_current(CONFIG["PROJECT"])
    bw2data.config.p["biosphere_database"] = CONFIG["BIOSPHERE"]


def find_id(dbname, activity):
    return cached_search(dbname, activity["search"]).get(
        "Process identifier", activity["id"]
    )


def create_ingredient_list(activities_tuple):
    print("Creating ingredient list...")
    activities = list(activities_tuple)
    return tuple(
        [
            process_activity_for_ingredient(activity)
            for activity in activities
            if activity["category"] == "ingredient"
        ]
    )


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
                        activity.get("database", CONFIG["AGRIBALYSE"]),
                        activity["search"],
                    ): 1
                }
            )
            lca.lci()
            lca.switch_method(CONFIG["LAND_OCCUPATION_METHOD"])
            lca.lcia()
            activity["land_occupation"] = float("{:.10g}".format(lca.score))
        updated_activities.append(frozendict(activity))
    return tuple(updated_activities)


def check_ids(ingredients):
    # Check the id is lowercase and does not contain space
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
    return frozendict(
        {
            activity["id"]: process_activity_for_processes(activity)
            for activity in activities
        }
    )


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
        "categories": activity.get("categories"),
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


def simapro_impacts(activity, method):
    strprocess = urllib.parse.quote(activity["name"], encoding=None, errors=None)
    project = urllib.parse.quote(spproject(activity), encoding=None, errors=None)
    method = urllib.parse.quote(main_method, encoding=None, errors=None)
    return bytrigram(
        definitions,
        json.loads(
            requests.get(
                f"http://simapro.ecobalyse.fr:8000/impact?process={strprocess}&project={project}&method={method}"
            ).content
        ),
    )


def brightway_impacts(activity, method):
    results = dict()
    lca = bw2calc.LCA({activity: 1})
    lca.lci()
    for key, method in definitions.items():
        lca.switch_method(method)
        lca.lcia()
        results[key] = float("{:.10g}".format(lca.score))
    return results


def compare_impacts(processes_fd):
    """This is compute_impacts slightly modified to store impacts from both bw and wp"""
    processes = dict(processes_fd)
    print("Computing impacts:")
    for index, (key, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        # simapro
        activity = cached_search(
            process.get("database", CONFIG["AGRIBALYSE"]), process["search"]
        )
        results = simapro_impacts(activity, main_method)
        print(f"got impacts from SimaPro for: {process['name']}")
        # WARNING assume remote is in m3 or MJ (couldn't find unit from COM intf)
        if process["unit"] == "kilowatt hour" and isinstance(results, dict):
            results = {k: v * 3.6 for k, v in results.items()}
        if process["unit"] == "litre" and isinstance(results, dict):
            results = {k: v / 1000 for k, v in results.items()}

        process["simapro impacts"] = results

        # brightway
        process["brightway impacts"] = brightway_impacts(activity, main_method)
        print(f"got impacts from Brightway for: {process['name']}")

        # compute subimpacts
        process["simapro impacts"] = with_subimpacts(process["simapro impacts"])
        process["brightway impacts"] = with_subimpacts(process["brightway impacts"])

    return frozendict({k: frozendict(v) for k, v in processes.items()})


def compute_impacts(processes_fd):
    processes = dict(processes_fd)
    print("Computing impacts:")
    for index, (key, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        # simapro
        activity = cached_search(
            process.get("database", CONFIG["AGRIBALYSE"]), process["search"]
        )
        results = simapro_impacts(activity, main_method)
        # WARNING assume remote is in m3 or MJ (couldn't find unit from COM intf)
        if process["unit"] == "kilowatt hour" and isinstance(results, dict):
            results = {k: v * 3.6 for k, v in results.items()}
        if process["unit"] == "litre" and isinstance(results, dict):
            results = {k: v / 1000 for k, v in results.items()}

        process["impacts"] = results

        if isinstance(results, dict) and results:
            # simapro succeeded
            process["impacts"] = results
            print(f"got impacts from simapro for: {process['name']}")
        else:
            # simapro failed (unexisting Ecobalyse project or some other reason)
            # brightway
            process["impacts"] = brightway_impacts(activity, main_method)
            print(f"got impacts from brightway for: {process['name']}")

        # compute subimpacts
        process["impacts"] = with_subimpacts(process["impacts"])

        # remove unneeded attributes
        for attribute in ["search"]:
            if attribute in process:
                del process[attribute]

    return frozendict({k: frozendict(v) for k, v in processes.items()})


def plot_impacts(ingredient_name, simapro, brightway):
    categories = [
        c
        for c in simapro.keys()
        if c not in ("etf-o", "etf-i", "htn-o", "htn-i", "htc-i", "htc-o")
    ]

    simapro_values = [
        simapro[cat] / IMPACTS[cat]["pef"]["normalization"] for cat in categories
    ]
    brightway_values = [
        brightway[cat] / IMPACTS[cat]["pef"]["normalization"] for cat in categories
    ]

    x = numpy.arange(len(categories))
    width = 0.35

    fig, ax = matplotlib.pyplot.subplots(figsize=(12, 8))

    ax.bar(x - width / 2, simapro_values, width, label="SimaPro")
    ax.bar(x + width / 2, brightway_values, width, label="Brightway")

    ax.set_xlabel("Impact Categories")
    ax.set_ylabel("Impact Values")
    ax.set_title(f"Environmental Impacts for {ingredient_name}")
    ax.set_xticks(x)
    ax.set_xticklabels(categories, rotation=90)
    ax.legend()

    matplotlib.pyplot.tight_layout()
    matplotlib.pyplot.savefig(f"{ingredient_name}.png")
    matplotlib.pyplot.close()


if __name__ == "__main__":
    setup_environment()

    # keep the previous processes with old impacts
    oldprocesses = load_json(CONFIG["PROCESSES_FILE"])
    activities = tuple(load_json(CONFIG["ACTIVITIES_FILE"]))

    activities_land_occ = compute_land_occupation(activities)
    ingredients = create_ingredient_list(activities_land_occ)

    ecosystemic_factors = load_ecosystemic_dic(CONFIG["ECOSYSTEMIC_FACTORS_FILE"])
    ingredients_veg_es = compute_vegetal_ecosystemic_services(
        ingredients, ecosystemic_factors
    )

    feed_file = load_json(CONFIG["FEED_FILE"])
    ugb = load_ugb_dic(CONFIG["UGB_FILE"])
    ingredients_animal_es = compute_animal_ecosystemic_services(
        ingredients_veg_es, activities_land_occ, ecosystemic_factors, feed_file, ugb
    )

    check_ids(ingredients_animal_es)
    processes = create_process_list(activities_land_occ)
    if len(sys.argv) == 1:  # just export.py
        processes_impacts = compute_impacts(processes)
    elif len(sys.argv) > 1 and sys.argv[1] == "compare":  # export.py compare
        data_dict = compare_impacts(processes)
        for ingredient_name, values in data_dict.items():
            print(f"Plotting {ingredient_name}")
            simapro_impacts = values["simapro impacts"]
            brightway_impacts = values["brightway impacts"]
            plot_impacts(ingredient_name, simapro_impacts, brightway_impacts)
            print("Charts have been generated and saved as PNG files.")
        sys.exit(0)
    else:
        print("Wrong argument: either no args or 'compare'")
        sys.exit(1)

    processes_corrected_impacts = with_corrected_impacts(
        load_json(CONFIG["IMPACTS_FILE"]), processes_impacts
    )

    # Export

    export_json(activities_land_occ, CONFIG["ACTIVITIES_FILE"])
    export_json(ingredients_animal_es, CONFIG["INGREDIENTS_FILE"])
    display_changes("id", oldprocesses, processes_corrected_impacts)
    export_json(list(processes_corrected_impacts.values()), CONFIG["PROCESSES_FILE"])
