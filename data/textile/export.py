#!/usr/bin/env python
# coding: utf-8

"""Materials and processes export for textile"""

import json
import os
import sys
import urllib.parse
from os.path import dirname

import bw2calc
import bw2data
import matplotlib
import numpy
import pandas as pd
import requests
from common.export import (
    cached_search,
    display_changes,
    export_json_ordered,
    load_json,
    progress_bar,
    remove_detailed_impacts,
    spproject,
    with_aggregated_impacts,
    with_corrected_impacts,
    with_subimpacts,
)
from common.impacts import bytrigram, main_method
from common.impacts import impacts as definitions
from frozendict import frozendict

BW_DATABASES = bw2data.databases
PROJECT_ROOT_DIR = dirname(dirname(dirname(__file__)))
ECOBALYSE_DATA_DIR = os.environ.get("ECOBALYSE_DATA_DIR")
if not ECOBALYSE_DATA_DIR:
    print(
        "\n🚨 ERROR: For the export to work properly, you need to specify ECOBALYSE_DATA_DIR env variable. It needs to point to the https://github.com/MTES-MCT/ecobalyse-private/ repository. Please, edit your .env file accordingly."
    )
    sys.exit(1)

# Configuration
DEFAULT_DB = "Ecoinvent 3.9.1"
ACTIVITIES_FILE = f"{PROJECT_ROOT_DIR}/data/textile/activities.json"
COMPARED_IMPACTS_FILE = f"{PROJECT_ROOT_DIR}/data/textile/compared_impacts.csv"
IMPACTS_FILE = f"{PROJECT_ROOT_DIR}/public/data/impacts.json"
MATERIALS_FILE = f"{PROJECT_ROOT_DIR}/public/data/textile/materials.json"
PROCESSES_IMPACTS = f"{ECOBALYSE_DATA_DIR}/data/textile/processes_impacts.json"
PROCESSES_AGGREGATED = f"{PROJECT_ROOT_DIR}/public/data/textile/processes.json"
GRAPH_FOLDER = f"{PROJECT_ROOT_DIR}/data/textile/impact_comparison"

with open(IMPACTS_FILE) as f:
    IMPACTS_DEF_ECOBALYSE = json.load(f)

with open(IMPACTS_FILE) as f:
    impact_definitions = json.load(f)


def find_id(dbname, activity):
    return cached_search(dbname, activity["search"]).get(
        "Process identifier", activity["id"]
    )


def create_material_list(activities_tuple):
    print("Creating material list...")
    return tuple(
        [
            process_activity_for_material(activity)
            for activity in list(activities_tuple)
            if activity["category"] == "material"
        ]
    )


def compute_normalization_factors():
    normalization_factors = {}
    for k, v in impact_definitions.items():
        if v["ecoscore"]:
            normalization_factors[k] = (
                v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            )
        else:
            normalization_factors[k] = 0
    return normalization_factors


def process_activity_for_material(activity):
    return {
        "id": activity["material_id"],
        "materialProcessUuid": activity["uuid"],
        "recycledProcessUuid": activity.get("recycledProcessUuid"),
        "recycledFrom": activity.get("recycledFrom"),
        "name": activity["shortName"],
        "shortName": activity["shortName"],
        "origin": activity["origin"],
        "primary": activity.get("primary"),
        "geographicOrigin": activity["geographicOrigin"],
        "defaultCountry": activity["defaultCountry"],
        "priority": activity.get("priority"),
        "cff": activity.get("cff"),
    }


def check_ids(materials):
    # Check the id is lowercase and does not contain space
    for material in materials:
        if (
            material["id"].lower() != material["id"]
            or material["id"].replace(" ", "") != material["id"]
        ):
            raise ValueError(
                f"This identifier is not lowercase or contains spaces: {material['id']}"
            )


def create_process_list(activities):
    print("Creating process list...")
    return frozendict(
        {
            activity["uuid"]: process_activity_for_processes(activity)
            for activity in activities
        }
    )


def process_activity_for_processes(activity):
    return {
        "uuid": activity["uuid"],
        "name": cached_search(activity.get("source", DEFAULT_DB), activity["search"])[
            "name"
        ]
        if "search" in activity and activity["source"] in BW_DATABASES
        else activity.get("name", activity["displayName"]),
        "displayName": activity["displayName"],
        "info": activity["info"],
        "unit": cached_search(activity.get("source", DEFAULT_DB), activity["search"])[
            "unit"
        ]
        if "search" in activity and activity["source"] in BW_DATABASES
        else activity["unit"],
        "source": activity["source"],
        "correctif": activity["correctif"],
        "step_usage": activity["step_usage"],
        "heat_MJ": activity["heat_MJ"],
        "elec_pppm": activity["elec_pppm"],
        "elec_MJ": activity["elec_MJ"],
        "waste": activity["waste"],
        "alias": activity["alias"],
        # those are removed at the end:
        **({"search": activity["search"]} if "search" in activity else {}),
        **({"impacts": activity["impacts"].copy()} if "impacts" in activity else {}),
    }


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


def compare_impacts(frozen_processes):
    """This is compute_impacts slightly modified to store impacts from both bw and wp"""
    processes = dict(frozen_processes)
    print("Computing impacts:")
    for index, (key, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        # simapro
        activity = cached_search(process.get("source", DEFAULT_DB), process["search"])
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

    return frozendict({k: frozendict(v) for k, v in processes.items()})


def compute_impacts(frozen_processes):
    """Add impacts to processes dictionary

    Args:
        frozen_processes (frozendict): dictionary of processes of which we want to compute the impacts
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
    processes = dict(frozen_processes)
    print("Computing impacts:")
    for index, (_, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        if "search" not in process:
            continue
        # simapro
        activity = cached_search(process.get("source", DEFAULT_DB), process["search"])
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


def plot_impacts(material_name, impacts_smp, impacts_bw):
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
    ax.set_title(f"Environmental Impacts for {material_name}")
    ax.set_xticks(x)
    ax.set_xticklabels(impact_labels, rotation=90)
    ax.legend()

    matplotlib.pyplot.tight_layout()
    matplotlib.pyplot.savefig(f"{GRAPH_FOLDER}/{material_name}.png")
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
    df.to_csv(COMPARED_IMPACTS_FILE, index=False)


if __name__ == "__main__":
    # bw2data.config.p["biosphere_database"] = "biosphere3"

    # keep the previous processes with old impacts
    oldprocesses = load_json(PROCESSES_IMPACTS)
    activities = tuple(load_json(ACTIVITIES_FILE))

    materials = create_material_list(activities)

    check_ids(materials)
    processes = create_process_list(activities)

    if len(sys.argv) == 1:  # just export.py
        processes_impacts = compute_impacts(processes)
    elif len(sys.argv) > 1 and sys.argv[1] == "compare":  # export.py compare
        impacts_compared_dic = compare_impacts(processes)
        csv_export_impact_comparison(impacts_compared_dic)
        for material_name, values in impacts_compared_dic.items():
            print(f"Plotting {material_name}")
            simapro_impacts = values["simapro_impacts"]
            brightway_impacts = values["brightway_impacts"]
            os.makedirs(GRAPH_FOLDER, exist_ok=True)
            plot_impacts(material_name, simapro_impacts, brightway_impacts)
            print("Charts have been generated and saved as PNG files.")
        sys.exit(0)
    else:
        print("Wrong argument: either no args or 'compare'")
        sys.exit(1)

    processes_corrected_impacts = with_corrected_impacts(
        IMPACTS_DEF_ECOBALYSE, processes_impacts
    )
    processes_aggregated_impacts = with_aggregated_impacts(
        IMPACTS_DEF_ECOBALYSE, processes_corrected_impacts
    )

    # Export

    export_json_ordered(activities, ACTIVITIES_FILE)
    export_json_ordered(materials, MATERIALS_FILE)
    display_changes("id", oldprocesses, processes_corrected_impacts)
    export_json_ordered(list(processes_aggregated_impacts.values()), PROCESSES_IMPACTS)
    export_json_ordered(
        remove_detailed_impacts(list(processes_aggregated_impacts.values())),
        PROCESSES_AGGREGATED,
    )
