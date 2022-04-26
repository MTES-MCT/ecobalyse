#!/usr/bin/env python
# coding: utf-8

"""Vérification des exports de la base Agribalyse."""

import copy
import json
from impacts import impacts


def checks(products, processes):
    # Nombre de produits qui n'ont pas 5 étapes
    count = 0
    for key, product in products.items():
        for step_key, step in product.items():
            if step == {}:
                count += 1
                print(f"{key} has no {step_key}")

    print(f"{count} missing steps")

    # Différence entre les impacts globaux et la somme des sous-impacts à l'étape consommation
    diff_impact = copy.deepcopy(processes)

    count = 0
    threshold = 4  # en pourcentage : 10 -> 10%

    for key, product in products.items():
        process = diff_impact[key]
        consumer = product["consumer"]

        for ingredient, amount in consumer.items():
            for impact in process.keys():
                process[impact] -= diff_impact[ingredient][impact] * amount

        for impact in process.keys():
            if abs(process[impact]) > abs(processes[key][impact]) * threshold / 100:
                count += 1
                print(f"{key} (impact {impact}): {process[impact]}")

    print(f"Total de {count} impacts qui ont une différence supérieure à {threshold}%")


def read_json(filename):
    with open(filename, "r") as infile:
        return json.load(infile)


if __name__ == "__main__":
    products = read_json("products.json")
    processes = read_json("processes.json")

    checks(products, processes)
