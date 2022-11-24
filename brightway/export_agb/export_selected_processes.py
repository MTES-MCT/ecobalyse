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
    # transformation
    "Cooking, industrial, 1kg of cooked product/ FR U": "transformation",
    'Mixing, processing, at plant "dummy process"': "transformation",
    "Canning fruits or vegetables, industrial, 1kg of canned product/ FR U": "transformation",
    # packaging
    "Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Kraft paper, unbleached {RER}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Polystyrene, expandable {RER}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Packaging glass, white {RER w/o CH+DE}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Polypropylene, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Polyethylene terephthalate, granulate, bottle grade {RER}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Packaging film, low density polyethylene {RER}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Polyethylene, high density, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Steel, unalloyed {RER}| steel production, converter, unalloyed | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Polyvinylchloride, suspension polymerised {RER}| polyvinylchloride production, suspension polymerisation | Cut-off, S - Copied from Ecoinvent": "packaging",
    "Aluminium, primary, ingot {RoW}| production | Cut-off, S - Copied from Ecoinvent": "packaging",
}


processes_alias = {
    # transformation
    "Cooking, industrial, 1kg of cooked product/ FR U": "cooking",
    'Mixing, processing, at plant "dummy process"': "mixing",
    "Canning fruits or vegetables, industrial, 1kg of canned product/ FR U": "canning",
    # packaging
    "Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent": "cardboard",
    "Kraft paper, unbleached {RER}| production | Cut-off, S - Copied from Ecoinvent": "paper",
    "Polystyrene, expandable {RER}| production | Cut-off, S - Copied from Ecoinvent": "ps",
    "Packaging glass, white {RER w/o CH+DE}| production | Cut-off, S - Copied from Ecoinvent": "glass",
    "Polypropylene, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent": "pp",
    "Polyethylene terephthalate, granulate, bottle grade {RER}| production | Cut-off, S - Copied from Ecoinvent": "pet",
    "Packaging film, low density polyethylene {RER}| production | Cut-off, S - Copied from Ecoinvent": "ldpe",
    "Polyethylene, high density, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent": "hdpe",
    "Steel, unalloyed {RER}| steel production, converter, unalloyed | Cut-off, S - Copied from Ecoinvent": "steel",
    "Polyvinylchloride, suspension polymerised {RER}| polyvinylchloride production, suspension polymerisation | Cut-off, S - Copied from Ecoinvent": "pvc",
    "Aluminium, primary, ingot {RoW}| production | Cut-off, S - Copied from Ecoinvent": "aluminium",
}


processes_display_name = {
    # transformation
    "Cooking, industrial, 1kg of cooked product/ FR U": "Cuisson",
    'Mixing, processing, at plant "dummy process"': "Mélange",
    "Canning fruits or vegetables, industrial, 1kg of canned product/ FR U": "Mise en conserve",
    # packaging
    "Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent": "Carton",
    "Kraft paper, unbleached {RER}| production | Cut-off, S - Copied from Ecoinvent": "Papier",
    "Polystyrene, expandable {RER}| production | Cut-off, S - Copied from Ecoinvent": "Polystyrène",
    "Packaging glass, white {RER w/o CH+DE}| production | Cut-off, S - Copied from Ecoinvent": "Verre",
    "Polypropylene, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent": "Polypropylène",
    "Polyethylene terephthalate, granulate, bottle grade {RER}| production | Cut-off, S - Copied from Ecoinvent": "PET",
    "Packaging film, low density polyethylene {RER}| production | Cut-off, S - Copied from Ecoinvent": "Polyéthylène basse densité",
    "Polyethylene, high density, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent": "Polyéthylène haute densité",
    "Steel, unalloyed {RER}| steel production, converter, unalloyed | Cut-off, S - Copied from Ecoinvent": "Acier",
    "Polyvinylchloride, suspension polymerised {RER}| polyvinylchloride production, suspension polymerisation | Cut-off, S - Copied from Ecoinvent": "PVC",
    "Aluminium, primary, ingot {RoW}| production | Cut-off, S - Copied from Ecoinvent": "Aluminium",
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
    activity_name = activity["name"]
    if activity_name in processes_alias:
        processes[activity]["alias"] = processes_alias[activity_name]
    if activity_name in processes_display_name:
        processes[activity]["displayName"] = processes_display_name[activity_name]
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

    # We have our own classification/categorization.
    if (
        activity._data["simapro metadata"]["Category type"] == "material"
        and "Food" in processes[activity]["category_tags"]
        and processes[activity]["unit"] == "kilogram"
    ):
        category = "ingredient"
    elif activity_name in processes_kind:
        category = processes_kind[activity_name]

    processes[activity]["category"] = category

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
