#!/usr/bin/env python
# coding: utf-8

"""Export des produits avec code CIQUAL d'une base Agribalyse"""

import json
import pandas as pd
import brightway2 as bw
from brightway2 import *
from collections import defaultdict
from impacts import impacts


def open_db(dbname):
    bw.projects.set_current("EF calculation")
    bw.bw2setup()
    return Database(dbname)


def get_ciqual_codes(filename):
    agb_synthese = pd.read_csv(filename)
    return list(agb_synthese["Code CIQUAL"])


def get_ciqual_products(ciqual_codes):
    ciqual_products = []

    for index, ciqual_code in enumerate(ciqual_codes):
        products = agb.search("Ciqual code : " + str(ciqual_code))
        ciqual_products += products
        if index % 100 == 0 and index:
            print(f"Loaded {index} products", end="\r")

    return ciqual_products


def build_product_tree(ciqual_products, max_products=None):
    products = {}
    process_list = set()

    for index, product in enumerate(ciqual_products):
        product_name = product["name"]
        amount = 1
        current_step = product
        products[product_name] = {}

        process_list.add(current_step)

        # Build the products tree and the processes list for this ciqual product
        for step in ["consumer", "supermarket", "distribution", "packaging", "plant"]:
            products[product_name][step] = {}
            next_exchange = None

            for exchange in current_step.technosphere():
                # HACK: we assume that the next "processed product" that we want to drill down
                # is the first one that doesn't have "Copied from Ecoinvent".
                if (
                    next_exchange is None
                    and "Copied from Ecoinvent" not in exchange["name"]
                ):
                    next_exchange = exchange
                exchange_name = exchange.input["name"]
                products[product_name][step][exchange_name] = (
                    exchange["amount"] * amount
                )
                process_list.add(exchange.input)

            # If we're at the last step, no need to drill down further
            if step == "plant":
                continue

            try:
                current_step = next_exchange.input
                current_step = next_exchange.input
                amount = next_exchange["amount"] * amount
            except AttributeError:
                print(
                    f"Error while drilling down product {product_name} at step {step}: no next step"
                )
                continue

        if index % 10 == 0:
            print(f"{round(index * 100 / len(ciqual_products))}%", end="\r")

        if max_products is not None and index >= max_products:
            print(f"\nStopped after importing {max_products} products")
            break
    else:
        print("100%")
    return (products, process_list)


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


def compute_impacts(process_list, lcas):
    processes = defaultdict(dict)

    for (key, _method) in impacts.items():
        lca = lcas[key]
        print(f">>>> Computing impact {key} for all processes")
        for index, process in enumerate(process_list):
            demand = {process: 1}
            lca.redo_lcia(demand)
            processes[process["name"]][key] = lca.score
            if index % 10 == 0:
                print(f"{round(index * 100 / len(process_list))}%", end="\r")
        print("100%")

    return processes


def export_products_as_json(products, filename):
    with open(filename, "w") as outfile:
        json.dump(products, outfile, indent=2)


def export_processes_as_json(processes, filename):
    with open(filename, "w") as outfile:
        json.dump(processes, outfile, indent=2)


if __name__ == "__main__":
    agb = open_db("agribalyse3")
    ciqual_codes = get_ciqual_codes("../Agribalyse_Synthese.csv")
    ciqual_products = get_ciqual_products(ciqual_codes)
    print(f"Loaded {len(ciqual_products)} products")

    print("Building product tree")
    (products, process_list) = build_product_tree(ciqual_products)  # , max_products=20)

    print(f"{len(products)} produits")
    print(f"{len(process_list)} processus")

    random_product = list(process_list)[0]
    lcas = init_lcas({random_product: 1})

    processes = compute_impacts(process_list, lcas)

    print("Nombre de produits importés:", len(products))
    print("Nombre de processus importés:", len(processes))

    export_products_as_json(products, "products.json")
    export_processes_as_json(processes, "processes.json")
