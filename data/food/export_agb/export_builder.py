#!/usr/bin/env python
# coding: utf-8

"""Export de l'impact d'une liste de processes
exemple : python export_builder.py"""

import copy
import csv
import json
import argparse
import brightway2 as bw
from food.impacts import impacts
import uuid
import hashlib


def get_activities(agribalyse_db, processes_code):
    activities = []

    for index, code in enumerate(processes_code):
        activities.append(agribalyse_db.get(code))
        if index % 100 == 0 and index:
            print(f"Chargement de {index} activités", end="\r")

    print(f"Chargement de {len(activities)} activités terminé")

    return activities


def open_db(dbname):
    bw.projects.set_current("Ecobalyse")
    bw.bw2setup()
    return bw.Database(dbname)


def init_lcas(demand):
    # Speed hack: initialize a LCA for each method, using just any product that we'll change later
    lcas = {}
    for key, method in impacts.items():
        print("Initialisation de la méthode", method)
        lca = bw.LCA(demand, method)
        lca.lci()
        lca.lcia()
        lcas[key] = lca
    return lcas


def impacts_for_activity(activity, lcas, bvi_data):
    activity_impacts = {}
    # Compute every impact but the PEF (computed later) and BVI (imported from bvi_data)
    for impact in impacts.keys():
        lca = lcas[impact]
        lca.redo_lcia({activity: 1})
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
        print(f"No bvi data for {activity['name']}")
        bvi = 0

    activity_impacts["bvi"] = float(bvi)
    return activity_impacts


def compute_lca(activities, lcas, bvi_data):
    num_activities = len(activities)
    print(f"Calcul de l'impact pour {num_activities} procédés")
    for index, activity in enumerate([v["activity"] for v in activities.values()]):
        impacts = impacts_for_activity(activity, lcas, bvi_data)
        activities[activity["code"]]["export_data"]["impacts"] = impacts
        if index % 10 == 0:
            print(f"{round(index * 100 / num_activities)}%", end="\r")
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


def is_complex_ingredient(variant):
    return (
        "simple_ingredient_default" in variant
    )  # This is enough (for now?) to detect if an ingredient is complex


def parse_ingredient_list(ingredients_base):
    processes_to_add = []

    for ingredient in ingredients_base:
        for variant in ingredient["variants"].values():
            if is_complex_ingredient(variant):
                # This is a complex ingredient, we need to create a new process from the elements we have.
                processes_to_add.append({"code": variant["simple_ingredient_default"]})
                processes_to_add.append({"code": variant["simple_ingredient_variant"]})
    return processes_to_add


def compute_ingredient_list(activities, ingredients_base):
    new_processes = []

    for ingredient in ingredients_base:
        for variant_name, variant in ingredient["variants"].items():
            if is_complex_ingredient(variant):
                # This is a complex ingredient, we need to create a new process from the elements we have.
                complex_ingredient_default = activities[ingredient["default"]][
                    "export_data"
                ]
                # The ratio is the quantity of simple ingredient necessary to produce 1 unit of complex ingredient
                # For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
                ratio = variant["ratio"]

                simple_ingredient_default = activities[
                    variant["simple_ingredient_default"]
                ]["export_data"]
                simple_ingredient_variant = activities[
                    variant["simple_ingredient_variant"]
                ]["export_data"]

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
                del variant["simple_ingredient_default"]
                del variant["simple_ingredient_variant"]
                del variant["ratio"]
                variant["process"] = new_process["simapro_id"]

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

    with open("builder_processes_to_export.csv") as f:
        processes_to_export = [
            dict([(k, v) for k, v in d.items() if v])
            for d in list(csv.DictReader(f, dialect="unix"))
        ]

    # Parse the ingredients_base.json, which may contain complex ingredients to add/compute
    with open("ingredients_base.json", "r") as f:
        ingredients_base = json.load(f)
    processes_to_add = parse_ingredient_list(ingredients_base)
    print(
        f"{len(processes_to_add)} procédés à rajouter provenant de ingredients_base.json (ingrédients complexes)"
    )

    processes_to_export += processes_to_add
    print(f"Total de {len(processes_to_export)} procédés à exporter")

    agb = open_db("Agribalyse 3.0")

    activities = {
        p["code"]: {
            "activity": agb.get(p["code"]),
            "export_data": p,  # agb.get(p["code"]).as_dict(),
        }
        for p in processes_to_export
    }
    print(f"Total de {len(activities)} activités trouvées dans agribalyse")

    for v in list(activities.values()):
        # move data
        activity, export_data = v["activity"], v["export_data"]
        export_data["simapro_id"] = export_data["code"]
        del export_data["code"]
        export_data["name"] = activity.get("simapro name", activity["name"])
        export_data["unit"] = activity["unit"]
        export_data["system_description"] = activity["simapro metadata"][
            "System description"
        ]

        # Useful info like the category_tags and comment are in the production exchange
        prod_exchange = list(activity.production())[0]
        export_data["category_tags"] = prod_exchange["categories"]
        if prod_exchange["comment"]:
            export_data["comment"] = prod_exchange["comment"]

        category = activity["simapro metadata"]["Category type"]
        # We have our own classification/categorization.
        if (
            category == "material"
            and "Food" in export_data["category_tags"]
            and activity["unit"] == "kilogram"
        ):
            category = "ingredient"
        elif "kind" in export_data:
            category = export_data["kind"]

        export_data["category"] = category
        export_data["impacts"] = {}

    # Just get a random process, for example the very first one
    lcas = init_lcas({next(iter(activities.values()))["activity"]: 1})

    bvi_data_file = "bvi.csv"
    bvi_data = {}
    with open(bvi_data_file, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f, delimiter=";")
        for row in reader:
            bvi_data[row["process_name"]] = row["bvi"]

    compute_lca(activities, lcas, bvi_data)

    # Extract simple and complex ingredients. Complex ingredients are need a new process to be added.
    (ingredient_list, new_processes) = compute_ingredient_list(
        activities, ingredients_base
    )

    # Export the ingredients.json file
    ingredients_export_file = "../../../public/data/food/ingredients.json"
    print(
        f"Export de {len(ingredient_list)} ingrédients vers {ingredients_export_file}"
    )
    export_json(ingredient_list, ingredients_export_file)

    # Add the new processes we computed for the complex ingredients
    export = [v["export_data"] for v in activities.values()] + new_processes

    processes_export_file = "../../../public/data/food/processes/builder.json"
    print(f"Export de {len(export)} procédés vers {processes_export_file}")
    export_json(export, processes_export_file)
    print("Terminé.")
