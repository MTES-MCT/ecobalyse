#!/usr/bin/env python
# coding: utf-8

"""Vérification des exports de la base Agribalyse."""

import copy
import csv
import json
import re
from impacts import impacts_to_synthese

THRESHOLD = 4  # en pourcentage : 10 -> 10%


def check_missing_steps(products):
    # Nombre de produits qui n'ont pas 5 étapes
    count = 0
    for key, product in products.items():
        for step_key, step in product.items():
            if step == {}:
                count += 1
                print(f"{key} has no {step_key}")
    return count


def check_ciqual_impacts(processes, synthese_filename):
    ciqual_code_regex = re.compile(r"\[Ciqual code: (\d+)\]")

    processes_to_ciqual = {}
    for process in processes:
        match = re.search(ciqual_code_regex, process)
        if match:
            ciqual_code = match[1]
            processes_to_ciqual[ciqual_code] = processes[process]

    print(
        "Liste des différences d'impact entre la synthèse agribalyse et les exports json:"
    )
    with open(synthese_filename) as csvfile:
        reader = csv.DictReader(csvfile)
        count = 0
        for row in reader:
            ciqual_code = row["Code CIQUAL"]
            for (impact, (trigram, multiplier)) in impacts_to_synthese.items():
                impact_a = float(row[impact]) * multiplier
                impact_b = processes_to_ciqual[ciqual_code][trigram]
                diff = get_diff(impact_a, impact_b)
                if diff:
                    # import ipdb

                    # ipdb.set_trace()
                    count += 1
                    print(
                        f"{ciqual_code} (impact {trigram}): {diff} ({round(diff * 100 / abs((max(impact_a, impact_b))))}%)"
                    )
        return count


def get_diff(impact_a, impact_b):
    max_impact = max(impact_a, impact_b)
    min_impact = min(impact_a, impact_b)
    diff = max_impact - min_impact
    threshold = abs(max_impact) * THRESHOLD / 100
    if diff > threshold:
        return diff


def check_impact_diff(products, processes):
    # Différence entre les impacts globaux et la somme des sous-impacts à l'étape consommation
    diff_impact = copy.deepcopy(processes)

    count = 0

    for key, product in products.items():
        process = diff_impact[key]
        consumer = product["consumer"]

        for ingredient, amount in consumer.items():
            for impact in process.keys():
                process[impact] -= diff_impact[ingredient][impact] * amount

        for impact in process.keys():
            if abs(process[impact]) > abs(processes[key][impact]) * THRESHOLD / 100:
                count += 1
                print(f"{key} (impact {impact}): {process[impact]}")
    return count


def read_json(filename):
    with open(filename, "r") as infile:
        return json.load(infile)


if __name__ == "__main__":
    products = read_json("products.json")
    processes = read_json("processes.json")

    print(">>> Check missing steps")
    count = check_missing_steps(products)
    print(f"{count} missing steps")

    print()

    print(">>> Check impact differences between export and Agribalyse_Synthese")
    count = check_ciqual_impacts(processes, "../Agribalyse_Synthese.csv")
    print(f"Total de {count} impacts qui ont une différence supérieure à {THRESHOLD}%")

    print()

    print(
        ">>> Check impact differences at consumer between global impact and sum of impacts at supermarket"
    )
    count = check_impact_diff(products, processes)
    print(f"Total de {count} impacts qui ont une différence supérieure à {THRESHOLD}%")
