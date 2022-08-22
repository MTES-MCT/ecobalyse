#!/usr/bin/env python
# coding: utf-8

"""Vérification des exports de la base Agribalyse.

Paramètres positionnels optionnels : le nom du fichier products.json et processes.json à utiliser.
Exemple :
    python checks.py products_EF2.json processes_EF2.json

"""

import copy
import csv
import json
import re
import sys
from impacts import impacts_to_synthese

THRESHOLD = 4  # en pourcentage : 10 -> 10%


def check_missing_steps(products):
    """Nombre de produits qui n'ont pas 5 étapes."""
    count = 0
    for key, product in products.items():
        for step_key, step in product.items():
            if step == {}:
                count += 1
                print(f"{key} has no {step_key}")
    return count


def check_ciqual_impacts(processes, synthese_filename):
    """Liste des différences d'impact entre la synthèse agribalyse et les exports json."""
    ciqual_code_regex = re.compile(r"\[Ciqual code: (\d+)\]")

    processes_to_ciqual = {}
    for process in processes:
        match = re.search(ciqual_code_regex, process)
        if match:
            ciqual_code = match[1]
            processes_to_ciqual[ciqual_code] = processes[process]

    with open(synthese_filename) as csvfile:
        reader = csv.DictReader(csvfile)
        count = 0
        for row in reader:
            ciqual_code = row["Code CIQUAL"]
            for (impact, (trigram, multiplier)) in impacts_to_synthese.items():
                impact_a = float(row[impact]) * multiplier
                impact_b = processes_to_ciqual[ciqual_code]["impacts"][trigram]
                diff = get_diff(impact_a, impact_b)
                if diff:
                    count += 1
                    print(
                        f"{ciqual_code} (impact {trigram}), diff: {round(diff * 100 / abs(max(impact_a, impact_b)))}% - json: {impact_b}, synthèse: {impact_a}"
                    )
        return count


def get_diff(impact_a, impact_b):
    max_impact = max(impact_a, impact_b)
    min_impact = min(impact_a, impact_b)
    diff = max_impact - min_impact
    threshold = abs(max_impact) * THRESHOLD / 100
    if diff > threshold:
        return diff


def processes_for_step(step):
    """Liste de tous les process d'une étape."""
    processes = []
    for category_processes in step.values():
        processes += category_processes
    return processes


def check_impact_diff(products, processes):
    """Différence entre les impacts globaux et la somme des sous-impacts menant à l'étape consommation."""
    diff_impact = copy.deepcopy(processes)

    count = 0

    for key, product in products.items():
        process = diff_impact[key]
        consumer = product["consumer"]

        for ingredient in processes_for_step(consumer):
            processName = ingredient["processName"]
            for impact in process["impacts"].keys():
                process["impacts"][impact] -= (
                    diff_impact[processName]["impacts"][impact] * ingredient["amount"]
                )

        for impact in process["impacts"].keys():
            diff = process["impacts"][impact]
            global_ = processes[key]["impacts"][impact]
            sum_impacts = global_ - diff
            abs_max = abs(max(sum_impacts, global_))
            percentage = diff * 100 / abs_max

            if percentage > THRESHOLD:
                count += 1
                print(
                    f"{key} (impact {impact}), diff: {round(percentage)}% - global: {global_}, somme: {sum_impacts}"
                )
    return count


def read_json(filename):
    with open(filename, "r") as infile:
        return json.load(infile)


if __name__ == "__main__":
    products_filename = "products.json"
    processes_filename = "processes.json"
    if len(sys.argv) == 3:
        products_filename = sys.argv[1]
        processes_filename = sys.argv[2]
    products = read_json(products_filename)
    processes = read_json(processes_filename)

    print(">>> Liste des produits avec étapes manquantes")
    count = check_missing_steps(products)
    print(f"{count} missing steps")

    print()

    print(
        f">>> Liste des différences d'impact supérieures à {THRESHOLD}% entre l'export et la synthèse Agribalyse"
    )
    count = check_ciqual_impacts(processes, "../Agribalyse_Synthese.csv")
    print(f"Total de {count} impacts qui ont une différence supérieure à {THRESHOLD}%")

    print()

    print(
        f">>> Liste des differences d'impact supérieures à {THRESHOLD}% entre l'impact global et la somme des impacts des composants 'at consumer'"
    )
    count = check_impact_diff(products, processes)
    print(f"Total de {count} impacts qui ont une différence supérieure à {THRESHOLD}%")
