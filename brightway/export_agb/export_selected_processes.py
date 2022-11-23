#!/usr/bin/env python
# coding: utf-8
# example command : python export_selected_processes.py "../../../ecobalyse//public/data/impacts.json"
"""Export de l'impact d'une liste de processes"""

import json

import argparse
import brightway2 as bw
from collections import defaultdict
from impacts import impacts
import pandas as pd

processes_kind = {
    "transformation": [
        "Cooking, industrial, 1kg of cooked product/ FR U",
        'Mixing, processing, at plant "dummy process"',
        "Canning fruits or vegetables, industrial, 1kg of canned product/ FR U",
    ],
    "packaging": [
        "Steel, unalloyed {RER}| steel production, converter, unalloyed | Cut-off, S - Copied from Ecoinvent",
        "Polystyrene, expandable {RER}| production | Cut-off, S - Copied from Ecoinvent",
        "Packaging glass, white {RER w/o CH+DE}| production | Cut-off, S - Copied from Ecoinvent",
        "Polypropylene, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent",
        "Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent",
        "Kraft paper, unbleached {RER}| production | Cut-off, S - Copied from Ecoinvent",
        "Polyvinylchloride, suspension polymerised {RER}| polyvinylchloride production, suspension polymerisation | Cut-off, S - Copied from Ecoinvent",
        "Polyethylene terephthalate, granulate, bottle grade {RER}| production | Cut-off, S - Copied from Ecoinvent",
        "Polyethylene, high density, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent",
        "Packaging film, low density polyethylene {RER}| production | Cut-off, S - Copied from Ecoinvent",
        "Extrusion of plastic sheets and thermoforming, inline {FR}| processing | Cut-off, S - Copied from Ecoinvent",
        "Impact extrusion of aluminium, deformation stroke {RER}| processing | Cut-off, S - Copied from Ecoinvent",
        "Impact extrusion of steel, cold, deformation stroke {RER}| processing | Cut-off, S - Copied from Ecoinvent",
    ],
}


def get_activities(agribalyse_db, processes_name):
    activities = []

    for index, process_name in enumerate(processes_name):
        activity = agribalyse_db.search(process_name)
        activities += activity
        if index % 100 == 0 and index:
            print(f"Loaded {index} activities", end="\r")

    return activities


def fill_processes(processes, activity):

    processes[activity]["name"] = activity["name"]
    processes[activity]["unit"] = activity._data["unit"]
    processes[activity]["simapro_id"] = activity._data["code"]

    processes[activity]["system_description"] = activity._data["simapro metadata"][
        "System description"
    ]

    # Useful info like the category_tags and comment are in the production exchange
    prod_exchange = list(activity.production())[0]
    processes[activity]["category_tags"] = prod_exchange._data["categories"]
    if prod_exchange._data["comment"]:
        processes[activity]["comment"] = prod_exchange._data["comment"]
    category = activity._data["simapro metadata"]["Category type"]

    # The `kind` key holds our own classification/categorization.
    if (
        activity._data["simapro metadata"]["Category type"] == "material"
        and "Food" in processes[activity]["category_tags"]
        and processes[activity]["unit"] == "kilogram"
    ):
        kind = "ingredient"
    elif activity["name"] in processes_kind["transformation"]:
        kind = "transformation"
    elif activity["name"] in processes_kind["packaging"]:
        kind = "packaging"
    else:
        # No specific classification/categorization from us, fallback on the category
        kind = category

    # We store the "kind" as the "category" key
    processes[activity]["category"] = kind

    processes[activity]["impacts"] = {}


def open_db(dbname):
    bw.projects.set_current("EF calculation")
    bw.bw2setup()
    return bw.Database(dbname)


def init_lcas(demand):
    # Speed hack: initialize a LCA for each method, using just any product that we'll change later
    lcas = {}
    for (key, method) in impacts.items():
        print("initializing method", method)
        lca = bw.LCA(demand, method)
        lca.lci()
        lca.lcia()
        lcas[key] = lca
    return lcas


def compute_pef(impacts_ecobalyse, impacts_dic):
    pef = 0
    for k in impacts_ecobalyse.keys():
        if k == "pef" or impacts_ecobalyse[k]["pef"] is None:
            continue
        norm = impacts_ecobalyse[k]["pef"]["normalization"]
        weight = impacts_ecobalyse[k]["pef"]["weighting"]
        pef += impacts_dic[k] * weight / norm
    pef *= 1000000  # We need the result in µPt, but we have it in Pt
    return pef


def compute_lca(processes, lcas):
    with open(args.impacts_file, "r") as f:
        impacts_ecobalyse = json.load(f)

    num_processes = len(processes)
    print(f"computing the impacts for the {num_processes} processes")
    for index, (activity, value) in enumerate(processes.items()):
        for impact in impacts.keys():
            lca = lcas[impact]

            demand = {activity: 1}
            lca.redo_lcia(demand)
            processes[activity]["impacts"][impact] = lca.score

        processes[activity]["impacts"]["pef"] = compute_pef(
            impacts_ecobalyse, processes[activity]["impacts"]
        )
        if index % 10 == 0:
            print(f"{round(index * 100 / num_processes)}%", end="\r")
    print("100%")


def export_json(content, filename):
    with open(filename, "w") as outfile:
        json.dump(content, outfile, indent=2, ensure_ascii=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Export agribalyse LCA data from a brightway database"
    )
    parser.add_argument(
        "impacts_file",
        help="""Path to the impacts.json file, following the format of https://github.com/MTES-MCT/ecobalyse/blob/master/public/data/impacts.json
        Eg: ../../../wikicarbone/public/data/impacts.json
        """,
    )

    args = parser.parse_args()

    df = pd.read_csv("selected_processes_to_export.csv")
    processes_array = df.values.tolist()

    processes_to_export = []
    for proc in processes_array:
        processes_to_export.append(proc[0])

    agb = open_db("agribalyse3")

    activities = get_activities(agb, processes_to_export)

    processes = defaultdict(dict)
    for activity in activities:
        fill_processes(processes, activity)

    processes_export_file = "selected_processes.json"

    # Just get a random process, for example the very first one
    random_process = next(iter(processes))
    lcas = init_lcas({random_process: 1})

    compute_lca(processes, lcas)

    # reformat processes in a list of dictionaries
    processes_list = list(processes.values())

    print(f"Export de {len(processes_list)} produits vers {processes_export_file}")
    export_json(processes_list, processes_export_file)
    print("Terminé.")
