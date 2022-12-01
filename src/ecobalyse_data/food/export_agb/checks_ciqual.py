#!/usr/bin/env python
# coding: utf-8

"""Vérification des exports de la base Agribalyse.

Paramètres positionnels optionnels : le nom du fichier products.json et processes.json à utiliser.
Exemple :
    python checks.py products_EF2.json processes_EF2.json

"""

import json
import os
import sys


def check_missing_steps(products):
    """Nombre de produits qui n'ont pas 5 étapes."""
    count = 0
    for key, product in products.items():
        for step_key, step in product.items():
            if step == {}:
                count += 1
                print(f"{key} has no {step_key}")
    return count


if __name__ == "__main__":
    products_filename = os.path.join(os.path.dirname(__file__), "products.json")
    if len(sys.argv) == 2:
        products_filename = sys.argv[1]
    with open(products_filename, "r") as infile:
        products = json.load(infile)

    print(">>> Liste des produits avec étapes manquantes")
    count = check_missing_steps(products)
    print(f"{count} missing steps")
