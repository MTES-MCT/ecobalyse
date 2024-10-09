#!/usr/bin/env python
# coding: utf-8

"""Export des ingrédients et des processes de l'alimentaire"""

import json
import os
import sys
import urllib.parse
from collections import OrderedDict
from os.path import abspath, dirname

sys.path.append(dirname(dirname(abspath(__file__))))
import bw2calc
import bw2data
import matplotlib
import numpy
import pandas as pd
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
from food.ecosystemic_services.ecosystemic_services import (
    compute_animal_ecosystemic_services,
    compute_vegetal_ecosystemic_services,
    load_ecosystemic_dic,
    load_ugb_dic,
)
from frozendict import frozendict

PROJECT_ROOT_DIR = dirname(dirname(dirname(__file__)))
ECOBALYSE_DATA_DIR = os.environ.get("ECOBALYSE_DATA_DIR")
if not ECOBALYSE_DATA_DIR:
    print(
        "\n🚨 ERROR: For the export to work properly, you need to specify ECOBALYSE_DATA_DIR env variable. It needs to point to the https://github.com/MTES-MCT/ecobalyse-private/ repository. Please, edit your .env file accordingly."
    )
    sys.exit(1)

# Configuration
CONFIG = {
    "PROJECT": "default",
    "AGRIBALYSE": "Agribalyse 3.1.1",
    "BIOSPHERE": "Agribalyse 3.1.1 biosphere",
    "ACTIVITIES_FILE": f"{PROJECT_ROOT_DIR}/data/food/activities.json",
    "COMPARED_IMPACTS_FILE": f"{PROJECT_ROOT_DIR}/data/food/compared_impacts.csv",
    "IMPACTS_FILE": f"{PROJECT_ROOT_DIR}/public/data/impacts.json",
    "ECOSYSTEMIC_FACTORS_FILE": f"{PROJECT_ROOT_DIR}/data/food/ecosystemic_services/ecosystemic_factors.csv",
    "FEED_FILE": f"{PROJECT_ROOT_DIR}/data/food/ecosystemic_services/feed.json",
    "UGB_FILE": f"{PROJECT_ROOT_DIR}/data/food/ecosystemic_services/ugb.csv",
    "INGREDIENTS_FILE": f"{PROJECT_ROOT_DIR}/public/data/food/ingredients.json",
    "PROCESSES_FILE": f"{ECOBALYSE_DATA_DIR}/data/food/processes_impacts.json",
    "LAND_OCCUPATION_METHOD": ("selected LCI results", "resource", "land occupation"),
    "GRAPH_FOLDER": f"{PROJECT_ROOT_DIR}/data/food/impact_comparison",
}
with open(CONFIG["IMPACTS_FILE"]) as f:
    IMPACTS_DEF_ECOBALYSE = json.load(f)


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
            if "ingredient" in activity["process_categories"]
        ]
    )


def compute_normalization_factors():
    normalization_factors = {}
    for k, v in IMPACTS_DEF_ECOBALYSE.items():
        if v["ecoscore"]:
            normalization_factors[k] = (
                v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            )
        else:
            normalization_factors[k] = 0
    return normalization_factors


def process_activity_for_ingredient(activity):
    return {
        "id": activity["id"],
        "name": activity["name"],
        "categories": [
            c for c in activity["ingredient_categories"] if c != "ingredient"
        ],
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
    return OrderedDict(
        {
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
            "categories": activity.get("process_categories"),
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
            "source": activity.get("database", AGRIBALYSE),
            # those are removed at the end:
            "search": activity["search"],
        }
    )


def compute_simapro_impacts(activity, method):
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


def compute_brightway_impacts(activity, method):
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
            process.get("source", CONFIG["AGRIBALYSE"]), process["search"]
        )
        results = compute_simapro_impacts(activity, main_method)
        print(f"got impacts from SimaPro for: {process['name']}")
        # WARNING assume remote is in m3 or MJ (couldn't find unit from COM intf)
        if process["unit"] == "kilowatt hour" and isinstance(results, dict):
            results = {k: v * 3.6 for k, v in results.items()}
        if process["unit"] == "litre" and isinstance(results, dict):
            results = {k: v / 1000 for k, v in results.items()}

        process["simapro_impacts"] = results

        # brightway
        process["brightway_impacts"] = compute_brightway_impacts(activity, main_method)
        print(f"got impacts from Brightway for: {process['name']}")

        # compute subimpacts
        process["simapro_impacts"] = with_subimpacts(process["simapro_impacts"])
        process["brightway_impacts"] = with_subimpacts(process["brightway_impacts"])

    processes_corrected_simapro = with_corrected_impacts(
        IMPACTS_DEF_ECOBALYSE, processes, "simapro_impacts"
    )
    processes_corrected_smp_bw = with_corrected_impacts(
        IMPACTS_DEF_ECOBALYSE, processes_corrected_simapro, "brightway_impacts"
    )

    return frozendict({k: frozendict(v) for k, v in processes_corrected_smp_bw.items()})


def compute_impacts(processes_fd):
    """Add impacts to processes dictionary

    Args:
        processes_fd (frozendict): dictionary of processes of which we want to compute the impacts
    Returns:
    dictionary of processes with impacts. Example :

    {"sunflower-oil-organic": {
        "id": "sunflower-oil-organic",
        name": "...",
        "impacts": {
            "acd": 3.14,
            ...
            "ecs": 34.3,
        },
        "unit": ...
        },
    "tomato":{
    ...
    }
    """
    processes = dict(processes_fd)
    print("Computing impacts:")
    for index, (_, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        # simapro
        activity = cached_search(
            process.get("source", CONFIG["AGRIBALYSE"]), process["search"]
        )
        results = compute_simapro_impacts(activity, main_method)
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
            process["impacts"] = compute_brightway_impacts(activity, main_method)
            print(f"got impacts from brightway for: {process['name']}")

        # compute subimpacts
        process["impacts"] = with_subimpacts(process["impacts"])

        # remove unneeded attributes
        for attribute in ["search"]:
            if attribute in process:
                del process[attribute]

    return frozendict({k: frozendict(v) for k, v in processes.items()})


def plot_impacts(ingredient_name, impacts_smp, impacts_bw):
    impact_labels = impacts_smp.keys()
    normalization_factors = compute_normalization_factors()

    simapro_values = [
        impacts_smp[label] * normalization_factors[label] for label in impact_labels
    ]
    brightway_values = [
        impacts_bw[label] * normalization_factors[label] for label in impact_labels
    ]

    x = numpy.arange(len(impact_labels))
    width = 0.35

    fig, ax = matplotlib.pyplot.subplots(figsize=(12, 8))

    ax.bar(x - width / 2, simapro_values, width, label="SimaPro")
    ax.bar(x + width / 2, brightway_values, width, label="Brightway")

    ax.set_xlabel("Impact Categories")
    ax.set_ylabel("Impact Values")
    ax.set_title(f"Environmental Impacts for {ingredient_name}")
    ax.set_xticks(x)
    ax.set_xticklabels(impact_labels, rotation=90)
    ax.legend()

    matplotlib.pyplot.tight_layout()
    matplotlib.pyplot.savefig(f"{CONFIG['GRAPH_FOLDER']}/{ingredient_name}.png")
    matplotlib.pyplot.close()


def csv_export_impact_comparison(compared_impacts):
    rows = []
    for product_id, process in compared_impacts.items():
        simapro_impacts = process.get("simapro_impacts", {})
        brightway_impacts = process.get("brightway_impacts", {})
        for impact in simapro_impacts:
            row = {
                "id": product_id,
                "name": process["name"],
                "impact": impact,
                "simapro": simapro_impacts.get(impact),
                "brightway": brightway_impacts.get(impact),
            }
            row["diff_abs"] = abs(row["simapro"] - row["brightway"])
            row["diff_rel"] = (
                row["diff_abs"] / abs(row["simapro"]) if row["simapro"] != 0 else None
            )

            rows.append(row)

    df = pd.DataFrame(rows)
    df.to_csv(CONFIG["COMPARED_IMPACTS_FILE"], index=False)


if __name__ == "__main__":
    projects.set_current(CONFIG["PROJECT"])
    bw2data.config.p["biosphere_database"] = CONFIG["BIOSPHERE"]

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
        impacts_compared_dic = compare_impacts(processes)
        csv_export_impact_comparison(impacts_compared_dic)
        for ingredient_name, values in impacts_compared_dic.items():
            print(f"Plotting {ingredient_name}")
            simapro_impacts = values["simapro_impacts"]
            brightway_impacts = values["brightway_impacts"]
            os.makedirs(CONFIG["GRAPH_FOLDER"], exist_ok=True)
            plot_impacts(ingredient_name, simapro_impacts, brightway_impacts)
            print("Charts have been generated and saved as PNG files.")
        sys.exit(0)
    else:
        print("Wrong argument: either no args or 'compare'")
        sys.exit(1)

    processes_corrected_impacts = with_corrected_impacts(
        IMPACTS_DEF_ECOBALYSE, processes_impacts
    )

    # Export

    export_json(activities_land_occ, CONFIG["ACTIVITIES_FILE"])
    export_json(ingredients_animal_es, CONFIG["INGREDIENTS_FILE"])
    display_changes("id", oldprocesses, processes_corrected_impacts)
    export_json(list(processes_corrected_impacts.values()), CONFIG["PROCESSES_FILE"])
