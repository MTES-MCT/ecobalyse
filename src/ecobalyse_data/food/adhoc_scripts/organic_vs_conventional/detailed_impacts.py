#!/usr/bin/env python
# coding: utf-8

"""Calcul de l'impact détaillé d'une liste de procédés"""

import json
import pandas as pd
import brightway2 as bw
from brightway2 import *
from collections import defaultdict
import re
import sys

# import the list of impact categories from impacts.py to compute impacts
sys.path.insert(1, "../")
from ecobalyse_data.food.impacts import impacts



def open_db(dbname):
    bw.projects.set_current("EF calculation")
    bw.bw2setup()
    return Database(dbname)


def get_procs(filename):
    agb_synthese = pd.read_csv(filename)
    return list(agb_synthese["proc"])


def get_agb_processes(procs):
    products = []

    for index, proc in enumerate(procs):
        result = agb.search(proc)
        try:
            first_result = result[0]
        except TypeError:
            first_result = None
            print(f"No result for : {proc}")

        products.append(first_result)
        if index % 100 == 0 and index:
            print(f"Loaded {index} products", end="\r")

    return products


def find_dqr(activity):
    dqr = None
    try:
        comment = activity._data["simapro metadata"]["Comment"]
    except KeyError:
        return None

    pattern = r"The overall DQR of this product is: (\d{1,2}\.\d{0,2})"
    match = re.search(pattern, comment)
    if match:
        dqr_str = match.group(1)
        dqr = float(dqr_str)
    return dqr


def find_step(activity):
    step = None

    pattern = r"\| at ([a-z]+)/FR"
    match = re.search(pattern, activity["name"])
    if match:
        step = match.group(1)
    return step


def find_ciqual_code(activity):
    ciqual_code = None

    pattern = r"\[Ciqual code: (\d{3,6})\]"
    match = re.search(pattern, activity["name"])
    if match:
        ciqual_code_str = match.group(1)
        ciqual_code = int(ciqual_code_str)
    return ciqual_code


def get_category_tags(current_step):
    categories = [ex._data["categories"] for ex in current_step.production()]
    if len(categories) > 1:
        print(
            f"Error while looking for category tag for {str(current_step)} : multiple production exchanges match "
        )
    return categories[0]


def fill_process(processes, activity, exchange):
    processes[activity]["ciqual_code"] = find_ciqual_code(activity)
    processes[activity]["step"] = find_step(activity)
    processes[activity]["dqr"] = find_dqr(activity)
    try:
        processes[activity]["empty_process"] = (
            "This is an empty process" in activity._data["simapro metadata"]["Comment"]
        )
    except KeyError:
        processes[activity]["empty_process"] = False

    processes[activity]["unit"] = activity._data["unit"]
    processes[activity]["code"] = activity._data["code"]
    processes[activity]["simapro_category"] = activity._data["simapro metadata"][
        "Category type"
    ]
    processes[activity]["system_description"] = activity._data["simapro metadata"][
        "System description"
    ]
    processes[activity]["category_tags"] = exchange._data["categories"]


def fill_processes(processes_list, max_products=None):
    processes = defaultdict(dict)

    # Iterate on all products
    for index, product in enumerate(processes_list):
        current_central_activity = product
        exchange = list(current_central_activity.exchanges())[0]

        # Fill the processes dictionary for this ciqual product
        fill_process(processes, current_central_activity, exchange)

        if index % 10 == 0:
            print(f"{round(index * 100 / len(processes_list))}%", end="\r")

        if max_products is not None and index >= max_products:
            print(f"\nStopped after importing {max_products} products")
            break
    else:
        print("100%")
    return processes


def init_lcas(demand):
    # Speed hack: initialize a LCA for each method, using just any product that we'll change later
    lcas = {}
    for (key, method) in impacts.items():
        print("initializing method", method)
        lca = LCA(demand, method)
        lca.lci()
        lca.lcia()
        lcas[key] = lca
    return lcas


def compute_pef(impacts_dic):
    pef = 0
    for k, v in impacts_dic.items():
        norm = impacts_json[k]["pef"]["normalization"]
        weight = impacts_json[k]["pef"]["weighting"]
        pef += v * weight / norm
    return pef


def compute_impacts(processes, lcas):
    processes_output = defaultdict(dict)
    impacts_dic = {}
    i = 0
    for process, value in processes.items():
        print(f">>>> Computing impacts for process {process}")
        for index, (impact, _method) in enumerate(impacts.items()):
            lca = lcas[impact]

            demand = {process: 1}
            lca.redo_lcia(demand)
            processes_output[process["name"]] = value
            processes_output[process["name"]][impact] = lca.score
            impacts_dic[impact] = lca.score

        if index % 10 == 0:
            print(f"{round(i * 100 / len(processes.keys()))}%", end="\r")
        processes_output[process["name"]]["pef"] = compute_pef(impacts_dic)
    print("100%")

    return processes_output


def export_json(content, filename):
    with open(filename, "w") as outfile:
        json.dump(content, outfile, indent=2)


path = "detailed_impacts_input.csv"
if __name__ == "__main__":

    f = open(r"../../export_agb/impacts.json")
    impacts_json = json.load(f)

    print(f"Get process list from {path}")
    procs_name = get_procs(path)
    print("Open the agribalyse3 brightway database")
    agb = open_db("agribalyse3")
    print("Search for the products in the agb database")
    processes_list = get_agb_processes(procs_name)

    processes = fill_processes(processes_list)


    random_product = list(processes.keys())[0]
    lcas = init_lcas({random_product: 1})

    processes_output = compute_impacts(processes, lcas)

    print("Nombre de processus importés:", len(processes))
    export_json(processes_output, "processes_to_compute.json")
