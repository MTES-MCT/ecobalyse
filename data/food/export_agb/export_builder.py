#!/usr/bin/env python
# coding: utf-8

"""Export de l'impact d'une liste de processes
exemple : python export_builder.py"""

import copy
import csv
import json
import argparse
import bw2data
import bw2calc
from food.impacts import impacts as impacts_definition
import uuid
import hashlib

# Input
PROJECT = "Ecobalyse"
DBNAME = "Agribalyse 3.1.1"
BIOSPHERE = DBNAME + " biosphere"
PROCESSES2EXPORT = "builder_processes_to_export.csv"
INGREDIENTS_BASE = "ingredients_base.json"
IMPACTS = "../../../public/data/impacts.json"  # TODO move the impact definition somewhere else and remove base impact
# Output
INGREDIENTS = "../../../public/data/food/ingredients.json"
BUILDER = "../../../public/data/food/processes/builder.json"

bw2data.projects.set_current(PROJECT)
bw2data.config.p["biosphere_database"] = BIOSPHERE
# bw2io.bw2setup()
db = bw2data.Database(DBNAME)


def compute_new_processes(activities, ingredients):
    new_processes = []

    for ingredient in ingredients:
        for variant_name, variant in ingredient.get("variants", {}).items():
            # variant_name can be 'organic', 'bleu_blanc_coeur'
            # we build new processes for ingredients defined with 2 sub-ingredients
            if (
                "simple_ingredient_default" in variant
                or "simple_ingredient_variant" in variant
            ):
                assert (
                    "simple_ingredient_default" in variant
                    and "simple_ingredient_variant" in variant
                ), f"Incomplete variant for {ingredient}"
                # This is a complex ingredient, we need to create a new process from the elements we have.
                assert (
                    ingredient["default"] in activities
                ), f"This activity is missing from the {INGREDIENTS_BASE} file: {ingredient['default']}"

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
                new_process["identifier"] = str(uuid.UUID(m.hexdigest()))

                for impact in new_process["impacts"]:
                    # Formula: Impact farine bio = impact farine conventionnel + ratio * ( impact blé bio -  impact blé conventionnel)
                    # It takes more than 1kg of wheat to make 1kg of flour. Or more than 1kg of beef to make 1kg of beef meat
                    new_process["impacts"][impact] = new_process["impacts"][
                        impact
                    ] + ratio * (
                        simple_ingredient_variant["impacts"][impact]
                        - simple_ingredient_default["impacts"][impact]
                    )
                del variant["simple_ingredient_default"]
                del variant["simple_ingredient_variant"]
                del variant["ratio"]
                variant["process"] = new_process["identifier"]

                new_processes.append(new_process)

    return new_processes


if __name__ == "__main__":
    # TODO add cli arguments to offer more choice (paths, db, impacts)
    parser = argparse.ArgumentParser(
        description=f"Export {DBNAME} LCA data from a brightway database"
    )
    args = parser.parse_args()

    with open(PROCESSES2EXPORT) as f:
        processes_to_export = [
            dict([(k, v) for k, v in d.items() if v])
            for d in list(csv.DictReader(f, dialect="unix"))
        ]

    # Parse the ingredients.json, which may contain complex ingredients to add/compute
    with open(INGREDIENTS_BASE, "r") as f:
        ingredients = json.load(f)

    with open(IMPACTS, "r") as f:
        impacts_ecobalyse = json.load(f)

    # we need to add the processes corresponding to sub-ingredients of constructed ingredients
    processes_to_add = []
    for i, ingredient in enumerate(ingredients):
        # we first get the activity from the search string and store its identifier
        results = db.search(ingredient["default"])
        assert (
            len(results) >= 1
        ), f"In {INGREDIENTS_BASE}:{i}, searching this \"default\" field doesn't give a result: {ingredient['default']}"
        ingredient["identifier"] = results[0]["Process identifier"]
        for variant in ingredient.get("variants", {}).values():
            if (
                "simple_ingredient_default" in variant
                and "simple_ingredient_variant" in variant
            ):
                # This is a complex ingredient, we need to create a new process from the elements we have.
                processes_to_add.append({"name": variant["simple_ingredient_default"]})
                processes_to_add.append({"name": variant["simple_ingredient_variant"]})

    print(
        f"{len(processes_to_add)} procédés construits provenant de {INGREDIENTS_BASE}"
    )

    processes_to_export += processes_to_add
    print(
        f"Total de {len(processes_to_export)} procédés à exporter, sélectionnés depuis {PROCESSES2EXPORT}"
    )

    activities = {}
    for i, p in enumerate(processes_to_export):
        results = db.search(p["name"])
        assert (
            len(results) >= 1
        ), f"In {PROCESSES2EXPORT}:{i}, searching this \"name\" field doesn't give a result: {p['name']}"
        activity = results[0]
        activities[p["name"]] = {
            "activity": activity,
            "export_data": p,
        }

    nb_activities = len(activities)
    print(f"Total de {nb_activities} activités trouvées dans {DBNAME}")

    for index, v in enumerate(activities.values()):
        print(
            "[" + (index) * "•" + (nb_activities - index) * " " + "]",
            end="\r",
        )
        # move data
        activity, export_data = v["activity"], v["export_data"]
        export_data["unit"] = activity["unit"]
        export_data["identifier"] = activity["Process identifier"]
        export_data["name"] = activity.get("simapro name", activity["name"])
        export_data["system_description"] = activity["System description"]

        # Useful info like the category_tags and comment are in the production exchange
        prod_exchange = list(activity.production())[0]
        export_data["category_tags"] = prod_exchange["categories"]
        if prod_exchange["comment"]:
            export_data["comment"] = prod_exchange["comment"]

        category = activity["Category type"]
        # We have our own classification/categorization.
        if (
            category == "material"
            and "Food" in export_data["category_tags"]
            and activity["unit"] == "kilogram"
        ):
            category = "ingredient"
        elif "kind" in export_data:
            category = export_data["kind"]
            del export_data["kind"]  # kind is moved to category

        export_data["category"] = category

        export_data["impacts"] = {}
        lca = bw2calc.LCA({activity: 1})
        # Compute the inventory
        lca.lci()
        # Compute the impacts
        for key, method in impacts_definition.items():
            lca.switch_method(method)
            lca.lcia()
            v["export_data"]["impacts"][key] = lca.score
        # etf-o = etf-o1 + etf-o2
        v["export_data"]["impacts"]["etf-o"] = (
            v["export_data"]["impacts"]["etf-o1"]
            + v["export_data"]["impacts"]["etf-o2"]
        )
        del v["export_data"]["impacts"]["etf-o1"]
        del v["export_data"]["impacts"]["etf-o2"]
        # etf = etf1 + etf2
        v["export_data"]["impacts"]["etf"] = (
            v["export_data"]["impacts"]["etf1"] + v["export_data"]["impacts"]["etf2"]
        )
        del v["export_data"]["impacts"]["etf1"]
        del v["export_data"]["impacts"]["etf2"]

        # move bvi from export_data (coming from csv) to the impacts
        if "bvi" in v["export_data"]:
            v["export_data"]["impacts"]["bvi"] = float(
                v["export_data"]["bvi"].replace(",", ".")
            )
            del v["export_data"]["bvi"]
        else:
            v["export_data"]["impacts"]["bvi"] = 0.0

    # Compute new processes for complex variants
    new_processes = compute_new_processes(activities, ingredients)

    # Export the ingredients
    print(f"Export de {len(ingredients)} ingrédients vers {INGREDIENTS}")
    with open(INGREDIENTS, "w") as outfile:
        json.dump(ingredients, outfile, indent=2, ensure_ascii=False)

    # Add the new processes we computed for the complex ingredients
    export = [v["export_data"] for v in activities.values()] + new_processes

    # compute the corrected impacts
    corrections = {
        k: v["correction"] for (k, v) in impacts_ecobalyse.items() if "correction" in v
    }
    for process in export:
        for impact_to_correct, correction in corrections.items():
            corrected_impact = 0
            for correction_item in correction:  # For each sub-impact and its weighting
                sub_impact_name = correction_item["sub-impact"]
                if sub_impact_name in process["impacts"]:
                    sub_impact = process["impacts"].get(sub_impact_name, 1)
                    corrected_impact += sub_impact * correction_item["weighting"]
                    del process["impacts"][sub_impact_name]
            process["impacts"][impact_to_correct] = corrected_impact

    print(f"Export de {len(export)} procédés vers {BUILDER}")
    with open(BUILDER, "w") as outfile:
        json.dump(export, outfile, indent=2, ensure_ascii=False)
