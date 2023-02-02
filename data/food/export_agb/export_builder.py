#!/usr/bin/env python
# coding: utf-8

"""Export de l'impact d'une liste de processes
exemple : python export_builder.py"""

import copy
import csv
import json
import argparse
import brightway2 as bw
from collections import defaultdict
from food.impacts import impacts
import uuid
import hashlib

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
        stripped_name = (
            process_name.strip()
        )  # Remove extraneous newline at the end of the line.
        results = agribalyse_db.search(stripped_name)
        for result in results:
            if result["name"] == stripped_name:
                # We found an exact match, use this instead of the first result
                # which may not be the most relevant
                activity = result
                break
        else:
            # We didn't find an exact match
            activity = results[0]
        activities.append(activity)
        if index % 100 == 0 and index:
            print(f"Chargement de {index} activités", end="\r")

    print(f"Chargement de {len(activities)} activités terminé")

    return activities


def add_process(processes, activity):
    activity_name = activity["name"]
    processes[activity]["name"] = activity_name

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
        print("Initialisation de la méthode", method)
        lca = bw.LCA(demand, method)
        lca.lci()
        lca.lcia()
        lcas[key] = lca
    return lcas


def compute_pef(impacts_ecobalyse, impacts_dic):
    pef = 0
    total_weighting = 0
    for k in impacts_ecobalyse.keys():
        if k == "pef" or impacts_ecobalyse[k]["pef"] is None:
            continue
        norm = impacts_ecobalyse[k]["pef"]["normalization"]
        weight = impacts_ecobalyse[k]["pef"]["weighting"]
        total_weighting += weight
        pef += impacts_dic[k] * weight / norm
    # The PEF is computed for a total weighting of 1 (100%), if we are above
    # (because of BVI for example), then normalize it
    pef /= total_weighting
    pef *= 1000000  # We need the result in µPt, but we have it in Pt
    return pef


def impacts_for_activity(activity, lcas, impacts_ecobalyse, bvi_data):
    activity_impacts = {}
    # Compute every impact but the PEF (computed later) and BVI (imported from bvi_data)
    for impact in impacts.keys():
        lca = lcas[impact]

        demand = {activity: 1}
        lca.redo_lcia(demand)
        activity_impacts[impact] = lca.score

    # Add the bvi impact that's been imported from another source (not coming from agribalyse,
    # and not computed by brightway).
    for process_name, bvi in bvi_data.items():
        # Remove various postfixes that differ between data sources
        normalized_name = (
            activity["name"]
            .replace("/ FR U", "")
            .replace("/FR U", "")
            .replace(", U", "")
            .replace(", S - Copied from Ecoinvent", "")
        )
        if process_name.startswith(normalized_name):
            break
    else:
        print(f"No bvi data for {normalized_name}")
        bvi = 0

    activity_impacts["bvi"] = float(bvi)
    activity_impacts["pef"] = compute_pef(impacts_ecobalyse, activity_impacts)
    return activity_impacts


def compute_lca(processes, lcas, impacts_ecobalyse, bvi_data):
    num_processes = len(processes)
    print(f"Calcul de l'impact pour {num_processes} procédés")
    for index, activity in enumerate(processes):
        impacts = impacts_for_activity(activity, lcas, impacts_ecobalyse, bvi_data)
        processes[activity]["impacts"] = impacts
        if index % 10 == 0:
            print(f"{round(index * 100 / num_processes)}%", end="\r")
    print("100%")


class ProcessNotFoundByIdError(Exception):
    def __init__(self, process_id):
        self.message = f"Procédé non trouvé pour l'id {process_id}"
        super().__init__(self.message)


def get_process_by_id(processes, process_id):
    for process in processes.values():
        if process["simapro_id"] == process_id:
            return process
    raise ProcessNotFoundByIdError(process_id)


class ProcessNotFoundByNameError(Exception):
    def __init__(self, process_name):
        self.message = f"Procédé non trouvé pour le nom {process_name}"
        super().__init__(self.message)


def get_process_by_name(processes, process_name):
    for process in processes.values():
        if process["name"] == process_name:
            return process
    raise ProcessNotFoundByNameError(process_name)


def parse_ingredient_list(ingredients_base):
    processes_to_add = []

    for ingredient in ingredients_base:
        for variant_name, variant in ingredient["variants"].items():
            if isinstance(variant, dict):
                # This is a complex ingredient, we need to create a new process from the elements we have.
                processes_to_add.append(variant["simple_ingredient_default"])
                processes_to_add.append(variant["simple_ingredient_variant"])
    return processes_to_add


def compute_ingredient_list(processes, ingredients_base):
    new_processes = []

    for ingredient in ingredients_base:
        for variant_name, variant in ingredient["variants"].items():
            if isinstance(variant, dict):
                # This is a complex ingredient, we need to create a new process from the elements we have.
                complex_ingredient_default = get_process_by_id(
                    processes, ingredient["default"]
                )
                # The ratio is the quantity of simple ingredient necessary to produce 1 unit of complex ingredient
                # For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
                ratio = variant["ratio"]

                simple_ingredient_default = get_process_by_name(
                    processes, variant["simple_ingredient_default"]
                )
                simple_ingredient_variant = get_process_by_name(
                    processes, variant["simple_ingredient_variant"]
                )

                new_process = copy.deepcopy(complex_ingredient_default)
                new_process[
                    "name"
                ] = f"{ingredient['id']}, {variant_name}, constructed by ecobalyse"
                new_process["system_description"] = "ecobalyse"

                # We generate a uuid using the process name as a seed
                m = hashlib.md5()
                seed = new_process["name"]
                m.update(seed.encode("utf-8"))
                new_process["simapro_id"] = str(uuid.UUID(m.hexdigest()))

                for impact in new_process["impacts"]:
                    # Formula: Impact farine bio = impact farine conventionnel + ratio * ( impact blé bio -  impact blé conventionnel)
                    new_process["impacts"][impact] = new_process["impacts"][
                        impact
                    ] + ratio * (
                        simple_ingredient_variant["impacts"][impact]
                        - simple_ingredient_default["impacts"][impact]
                    )
                ingredient["variants"][variant_name] = new_process["simapro_id"]

                new_processes.append(new_process)

    return (ingredients_base, new_processes)


def export_json(content, filename):
    with open(filename, "w") as outfile:
        json.dump(content, outfile, indent=2, ensure_ascii=False)
        outfile.write("\n")  # Add a newline at the end of the file, as many editors do.


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Export agribalyse LCA data from a brightway database"
    )

    args = parser.parse_args()

    processes_to_export_file = "builder_processes_to_export.txt"
    with open(processes_to_export_file, "r") as f:
        processes_to_export = f.readlines()

    # Parse the ingredients_base.json, which may contain complex ingredients to add/compute
    with open("ingredients_base.json", "r") as f:
        ingredients_base = json.load(f)
    processes_to_add = parse_ingredient_list(ingredients_base)
    print(
        f"{len(processes_to_add)} procédés à rajouter provenant de ingredients_base.json (ingrédients complexes)"
    )

    processes_to_export += processes_to_add
    print(f"Total de {len(processes_to_export)} procédés à exporter")

    agb = open_db("agribalyse3")

    activities = get_activities(agb, processes_to_export)
    print(f"Total de {len(activities)} activités trouvées dans agribalyse")

    processes = defaultdict(dict)
    for activity in activities:
        add_process(processes, activity)

    # Just get a random process, for example the very first one
    random_process = next(iter(processes))
    lcas = init_lcas({random_process: 1})

    impacts_file = "../../../public/data/impacts.json"
    with open(impacts_file, "r") as f:
        impacts_ecobalyse = json.load(f)

    bvi_data_file = "bvi.csv"
    bvi_data = {}
    with open(bvi_data_file, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            bvi_data[row["process_name"]] = row["bvi"]

    compute_lca(processes, lcas, impacts_ecobalyse, bvi_data)

    # Extract simple and complex ingredients. Complex ingredients are need a new process to be added.
    (ingredient_list, new_processes) = compute_ingredient_list(
        processes, ingredients_base
    )

    # Export the ingredients.json file
    ingredients_export_file = "../../../public/data/food/ingredients.json"
    print(
        f"Export de {len(ingredient_list)} ingrédients vers {ingredients_export_file}"
    )
    export_json(ingredient_list, ingredients_export_file)

    # reformat processes in a list of dictionaries
    processes_list = list(processes.values())

    # Add the new processes we computed for the complex ingredients
    processes_list += new_processes

    processes_export_file = "../../../public/data/food/processes/builder.json"
    print(f"Export de {len(processes_list)} procédés vers {processes_export_file}")
    export_json(processes_list, processes_export_file)
    print("Terminé.")
