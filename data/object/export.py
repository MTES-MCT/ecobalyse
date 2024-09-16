#!/usr/bin/env python
# coding: utf-8

"""Export des ingrédients et des processes de l'objet"""

import json
import os
import sys
import urllib.parse
from os.path import dirname

import bw2calc
import requests
from bw2data.project import projects
from common.export import (
    cached_search,
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
    "ECOINVENT": "Ecoinvent 3.9.1",
    "BIOSPHERE": "biosphere3",
    "ACTIVITIES_FILE": f"{PROJECT_ROOT_DIR}/data/object/activities.json",
    "COMPARED_IMPACTS_FILE": f"{PROJECT_ROOT_DIR}/data/object/compared_impacts.csv",
    "IMPACTS_FILE": f"{PROJECT_ROOT_DIR}/public/data/impacts.json",
    "PROCESSES_FILE": f"{ECOBALYSE_DATA_DIR}/data/object/processes_impacts.json",
}
with open(CONFIG["IMPACTS_FILE"]) as f:
    IMPACTS_DEF_ECOBALYSE = json.load(f)


def find_id(dbname, activity):
    return cached_search(dbname, activity["search"]).get(
        "Process identifier", activity["id"]
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
            process.get("source", CONFIG["ECOINVENT"]), process["search"]
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


if __name__ == "__main__":
    projects.set_current(CONFIG["PROJECT"])
    # bw2data.config.p["biosphere_database"] = CONFIG["BIOSPHERE"]

    # keep the previous processes with old impacts
    #    oldprocesses = load_json(CONFIG["PROCESSES_FILE"])
    activities = tuple(load_json(CONFIG["ACTIVITIES_FILE"]))

    processes_impacts = compute_impacts(activities)

    processes_corrected_impacts = with_corrected_impacts(
        IMPACTS_DEF_ECOBALYSE, processes_impacts
    )

    # Export
    #   display_changes("id", oldprocesses, processes_corrected_impacts)
    export_json(list(processes_corrected_impacts.values()), CONFIG["PROCESSES_FILE"])
