#!/usr/bin/env python
# coding: utf-8
"""Export des produits avec code CIQUAL d'une base Agribalyse"""

import json

import argparse
import brightway2 as bw
from collections import defaultdict
from food.impacts import impacts
import pandas as pd
import re

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


def open_db(dbname):
    bw.projects.set_current("EF calculation")
    bw.bw2setup()
    return bw.Database(dbname)


def get_ciqual_codes(filename):
    agb_synthese = pd.read_csv(filename)
    return list(agb_synthese["Code CIQUAL"])


def get_ciqual_products(agribalyse_db, ciqual_codes):
    ciqual_products = []

    for index, ciqual_code in enumerate(ciqual_codes):
        products = agribalyse_db.search("Ciqual code : " + str(ciqual_code))
        ciqual_products += products
        if index % 100 == 0 and index:
            print(f"Loaded {index} products", end="\r")

    return ciqual_products


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

    # We store the "kind" as the "category" key
    processes[activity]["category"] = category

    processes[activity]["impacts"] = {}


def build_product_tree(ciqual_products, max_products=None):
    products = {}
    processes = defaultdict(dict)
    num_ciqual_products = len(ciqual_products)

    # Iterate on all products
    for index, product in enumerate(ciqual_products):
        product_name = product["name"]
        amount = 1
        current_central_activity = product
        exchange = list(current_central_activity.exchanges())[0]
        products[product_name] = {}

        # Build the products tree and the processes list for this ciqual product
        for step in ["consumer", "supermarket", "distribution", "packaging", "plant"]:
            products[product_name][step] = {"items": []}
            next_central_exchange = None
            # Iterate on all technosphere exchanges (we ignore biosphere exchanges)
            for exchange in current_central_activity.technosphere():
                current_activity = exchange.input

                flags = [
                    "at supermarket/FR",
                    "at consumer/FR",
                    "at distribution/FR",
                    "at packaging/FR",
                ]
                if not any([flag in current_activity["name"] for flag in flags]):
                    # If the process is NOT one of the intermediary ciqual products (containing one of the above flags), then fill it in
                    fill_processes(processes, current_activity)

                exchange_name = exchange.input["name"]
                exchange_data = {
                    "processName": exchange_name,
                    "comment": exchange._data["comment"],
                    "amount": exchange["amount"] * amount,
                }
                is_main_item = False

                #  We're looking for the next central product to drill it down. For "Tomato at consumer" ciqual product, the next central product should be "Tomato at supermarket")
                # HACK: we assume that the next "central product"
                # is the first one that doesn't have "Copied from Ecoinvent".
                if (
                    next_central_exchange is None
                    and "Copied from Ecoinvent" not in exchange["name"]
                ):
                    next_central_exchange = exchange
                    # Set the current exchange as the "main item", unless we're at plant already
                    is_main_item = step != "plant"

                if is_main_item:
                    products[product_name][step]["mainItem"] = {
                        "processName": exchange_data["processName"],
                        "comment": exchange_data["comment"],
                        "amount": exchange_data["amount"],
                    }
                else:
                    products[product_name][step]["items"].append(exchange_data)

            # If we're at the last step, no need to drill down further
            if step == "plant":
                continue
            # Else we replace the current_central_activity by the next_central_activity
            try:
                current_central_activity = next_central_exchange.input
                amount = next_central_exchange["amount"] * amount
            except AttributeError:
                print(
                    f"Error while drilling down product {product_name} at step {step}: no next step"
                )
                continue

        if index % 10 == 0:
            print(f"{round(index * 100 / num_ciqual_products)}%", end="\r")

        if max_products is not None and index >= max_products:
            print(f"\nStopped after importing {max_products} products")
            break
    else:
        print("100%")
    return (products, processes)


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
    impacts_file = "../../../public/data/impacts.json"
    with open(impacts_file, "r") as f:
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
        json.dump(content, outfile, indent=2)


path = "../Agribalyse_Synthese.csv"
if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Export agribalyse LCA data from a brightway database"
    )
    parser.add_argument(
        "--no-impacts",
        action="store_true",
        help="Only export products and processes, don't compute the impacts",
    )
    parser.add_argument(
        "--max",
        default=None,
        type=int,
        help="Max number of ciqual products to export (for debug purposes)",
    )

    args = parser.parse_args()

    print(f"Get ciqual codes from {path}")
    ciqual_codes = get_ciqual_codes(path)

    if args.max:
        ciqual_codes = ciqual_codes[: args.max]

    print("Open the agribalyse3 brightway database")
    agb = open_db("agribalyse3")
    print("Search for the ciqual products in the brightway database")
    ciqual_products = get_ciqual_products(agb, ciqual_codes)

    print(f"Loaded {len(ciqual_products)} products")

    print("Building product tree")
    (products, processes) = build_product_tree(ciqual_products)

    print(
        f"Export de {len(products)} produits vers ../../../public/data/food/products.json"
    )
    export_json(products, "../../../public/data/food/products.json")

    processes_export_file = "../../../public/data/food/processes/explorer.json"

    if args.no_impacts:
        processes_export_file = "processes-no-impacts.json"
    else:
        # Just get a random process, for example the very first one
        random_process = next(iter(processes))
        lcas = init_lcas({random_process: 1})

        compute_lca(processes, lcas)

    # reformat processes in a list of dictionaries
    processes_list = list(processes.values())

    print(f"Export de {len(processes_list)} produits vers {processes_export_file}")
    export_json(processes_list, processes_export_file)
    print("Terminé.")
