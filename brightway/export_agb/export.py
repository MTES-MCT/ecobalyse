#!/usr/bin/env python
# coding: utf-8

"""Export des produits avec code CIQUAL d'une base Agribalyse"""

from contextlib import nullcontext
import json

import argparse
import brightway2 as bw
from collections import defaultdict
from impacts import impacts
import pandas as pd
import re


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


def fill_processes(processes, activity, exchange):
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
    processes[activity]["impacts"] = {}
    processes[activity]["transport_at_plant"] = None


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

        # Fill the processes dictionary for this ciqual product
        fill_processes(processes, current_central_activity, exchange)

        # Build the products tree and the processes list for this ciqual product
        for step in ["consumer", "supermarket", "distribution", "packaging", "plant"]:
            products[product_name][step] = {}
            next_central_exchange = None
            # Iterate on all technosphere exchanges (we ignore biosphere exchanges)
            for exchange in current_central_activity.technosphere():
                next_activity = exchange.input
                # Fill processes dictionary with exchange data
                fill_processes(processes, next_activity, exchange)

                exchange_name = exchange.input["name"]
                exchange_data = {
                    "processName": exchange_name,
                    "comment": exchange._data["comment"],
                    "amount": exchange["amount"] * amount,
                }

                #  We're looking for the next central product to drill it down. For "Tomato at consumer" ciqual product, the next central product should be "Tomato at supermarket")
                # HACK: we assume that the next "central product"
                # is the first one that doesn't have "Copied from Ecoinvent".
                if (
                    next_central_exchange is None
                    and "Copied from Ecoinvent" not in exchange["name"]
                ):
                    next_central_exchange = exchange

                    # Exceptionaly the category_tags for the next "central product" are not in the technosphere exchanges but in the production exchange
                    # that's why we call a specific function to retrieve this information
                    processes[next_activity]["category_tags"] = get_category_tags(
                        current_central_activity
                    )
                    # Store the "main process" for this step, unless we're at plant already
                    if step != "plant":
                        exchange_data["mainProcess"] = True

                # In products.json, we group processes by categories (transport, energy, waste treatment, material,...)
                exchange_category = next_activity._data["simapro metadata"][
                    "Category type"
                ]
                category_data = products[product_name][step].get(exchange_category, [])
                category_data.append(exchange_data)
                products[product_name][step][exchange_category] = category_data

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


def compute_lca(processes, lcas):
    processes_output = defaultdict(dict)
    num_processes = len(processes)
    print(f"computing the impacts for the {num_processes} processes")
    for index, (process, value) in enumerate(processes.items()):
        for (impact, _method) in impacts.items():
            lca = lcas[impact]

            demand = {process: 1}
            lca.redo_lcia(demand)
            processes_output[process["name"]] = value
            processes_output[process["name"]]["impacts"][impact] = lca.score
        if index % 10 == 0:
            print(f"{round(index * 100 / num_processes)}%", end="\r")
    print("100%")

    return processes_output


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

    print(f"Export de {len(products)} produits vers products.json")
    export_json(products, "products.json")

    # For ciqual_products we fill the "transport at plant" boolean in processes
    for process, value in processes.items():
        if value["ciqual_code"] is not None:
            value["transport_at_plant"] = (
                "transport" in products[process["name"]]["plant"].keys()
            )

    processes_export_file = "processes.json"
    if args.no_impacts:
        # We don't compute impacts, but we still need to fix the processes dict so it has
        # string keys, and not "brightway activities"
        processes = {process["name"]: value for (process, value) in processes.items()}
        processes_export_file = "processes-no-impacts.json"
    else:
        # Just get a random process, for example the very first one
        random_process = next(iter(processes))
        lcas = init_lcas({random_process: 1})

        processes = compute_lca(processes, lcas)

    print(f"Export de {len(processes)} produits vers {processes_export_file}")
    export_json(processes, processes_export_file)
    print("Terminé.")
