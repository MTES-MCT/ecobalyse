#!/usr/bin/env python
# coding: utf-8

"""Export des ingrédients et des processes du builder"""

from food.impacts import impacts as impacts_definition
import bw2calc
import bw2data
import functools
import hashlib
import json
import sys
import uuid

# Input
PROJECT = "Ecobalyse"
DBNAME = "Agribalyse 3.1.1"
BIOSPHERE = DBNAME + " biosphere"
ACTIVITIES = "activities.json"
IMPACTS = "../../../public/data/impacts.json"  # TODO move the impact definition somewhere else and remove base impact
# Output
INGREDIENTS = "../../../public/data/food/ingredients.json"
BUILDER = "../../../public/data/food/processes/builder.json"
# maximum variation for new impacts compared to old impacts
maxN = 0.05

bw2data.projects.set_current(PROJECT)
bw2data.config.p["biosphere_database"] = BIOSPHERE
db = bw2data.Database(DBNAME)


@functools.cache
def search(name):
    results = db.search(name)
    assert len(results) >= 1, f"'{name}' was not found in Brightway"
    return results[0]


if __name__ == "__main__":
    # backup the previous builder with old impacts
    with open(BUILDER) as f:
        oldbuilder = json.load(f)

    with open(ACTIVITIES, "r") as f:
        activities = json.load(f)

    with open(IMPACTS, "r") as f:
        impacts_ecobalyse = json.load(f)
    corrections = {
        k: v["correction"] for (k, v) in impacts_ecobalyse.items() if "correction" in v
    }

    print("Creating ingredient list...")
    ingredients = [
        {
            "id": activity["id"],
            "name": activity["name"],
            "categories": [c for c in activity["categories"] if c != "ingredient"],
            "default": search(activity["search"])["Process identifier"],
            "default_origin": activity["default_origin"],
            "raw_to_cooked_ratio": activity["raw_to_cooked_ratio"],
            "density": activity["density"],
            "inedible_part": activity["inedible_part"],
            "transport_cooling": activity["transport_cooling"],
            "visible": activity["visible"],
            "complements": activity.get("complements", []),
        }
        for activity in activities
        if activity.get("ingredient")
    ]
    # cleanup unuseful attributes
    for ingredient in ingredients:
        if "animal_product" not in ingredient[
            "categories"
        ] and "animal-welfare" in ingredient.get("complements"):
            del ingredient["complements"]["animal-welfare"]

    print("Creating builder process list...")
    builder = {
        activity["id"]: {
            "id": activity["id"],
            "name": search(activity["search"])["name"],
            "displayName": activity["name"],
            "unit": search(activity["search"])["unit"],
            "identifier": search(activity["search"])["Process identifier"],
            "system_description": search(activity["search"])["System description"],
            "category": activity.get("category"),
            "comment": list(search(activity["search"]).production())[0]["comment"],
            # those are removed at the end:
            "search": activity["search"],
            "ratio": activity.get("ratio"),
            "subingredient_default": activity.get("subingredient_default"),
            "subingredient_variant": activity.get("subingredient_variant"),
            "impacts": {"bvi": activity.get("bvi", 0)},
        }
        for activity in activities
    }
    # remove empty category
    for p in builder:
        if not builder[p]["category"]:
            del builder[p]["category"]
    # remove complex ingredient attributes on simple ingredients
    for processid in builder.keys():
        if not builder[processid]["ratio"]:
            del builder[processid]["ratio"]
            del builder[processid]["subingredient_default"]
            del builder[processid]["subingredient_variant"]

    # check that all three attributes are present on complex ingredients
    for activity in activities:
        if any(
            [
                key in activity
                for key in ("ratio", "subingredient_default", "subingredient_variant")
            ]
        ):
            assert all(
                [
                    key in activity
                    for key in (
                        "ratio",
                        "subingredient_default",
                        "subingredient_variant",
                    )
                ]
            ), f"{activity} seems is missing either ratio or subingredient_default or subingredient_variant"

    # compute the impacts of base processes
    print("Computing impacts:")
    for index, (processid, process) in enumerate(
        # keep complex ingredients at the end since they depend on subingredient processes
        sorted(builder.items(), key=lambda x: "ratio" in x[1])
    ):
        print(
            "("
            + (index) * "•"
            + (len(builder) - index) * " "
            + f") {str(index)}/{len(builder)}",
            end="\r",
        )
        lca = bw2calc.LCA({search(process["search"]): 1})
        lca.lci()
        for key, method in impacts_definition.items():
            lca.switch_method(method)
            lca.lcia()
            process.setdefault("impacts", {})[key] = float("{:.10g}".format(lca.score))

        # etf-o = etf-o1 + etf-o2
        process["impacts"]["etf-o"] = (
            process["impacts"]["etf-o1"] + process["impacts"]["etf-o2"]
        )
        del process["impacts"]["etf-o1"]
        del process["impacts"]["etf-o2"]
        # etf = etf1 + etf2
        process["impacts"]["etf"] = (
            process["impacts"]["etf1"] + process["impacts"]["etf2"]
        )
        del process["impacts"]["etf1"]
        del process["impacts"]["etf2"]

        # Now compute an identifier for complex ingredients
        # Compute the impacts of complex ingredients

        # Compute impacts of complex ingredients
        # and tweak some attributes
        if "ratio" in process:
            for impact in process["impacts"]:
                # The ratio is the quantity of simple ingredient necessary to produce 1 unit of complex ingredient.
                # You need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
                # Formula: Impact farine bio = impact farine conventionnel + ratio * ( impact blé bio -  impact blé conventionnel)
                process["impacts"][impact] = process["impacts"][impact] + process[
                    "ratio"
                ] * (
                    builder[process["subingredient_variant"]]["impacts"][impact]
                    - builder[process["subingredient_default"]]["impacts"][impact]
                )

            process["name"] = f"{processid}, constructed by Ecobalyse"
            process["system_description"] = "Ecobalyse"
            process["identifier"] = str(
                uuid.UUID(hashlib.md5(process["name"].encode("utf-8")).hexdigest())
            )

        # remove unneeded attributes
        for attribute in (
            "search",
            "ratio",
            "subingredient_default",
            "subingredient_variant",
        ):
            if attribute in process:
                del process[attribute]

    print("Computing corrected impacts...")
    for process in builder.values():
        # compute corrected impacts
        for impact_to_correct, correction in corrections.items():
            corrected_impact = 0
            for correction_item in correction:  # For each sub-impact and its weighting
                sub_impact_name = correction_item["sub-impact"]
                if sub_impact_name in process["impacts"]:
                    sub_impact = process["impacts"].get(sub_impact_name, 1)
                    corrected_impact += sub_impact * correction_item["weighting"]
                    del process["impacts"][sub_impact_name]
            process["impacts"][impact_to_correct] = corrected_impact

    with open(INGREDIENTS, "w") as outfile:
        json.dump(ingredients, outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"\nExported {len(ingredients)} ingredients to {INGREDIENTS}")

    # warn and stop if impacts changed by more than maxN%
    old = {p["id"]: p["impacts"] for p in oldbuilder}
    stop = False
    for p in builder:
        for impact in builder[p]["impacts"]:
            if (
                old.get(p, {}).get(impact, {})
                and abs(builder[p]["impacts"][impact] - old[p][impact]) / old[p][impact]
                > maxN
            ):
                print(
                    f"Impact {impact} of process {p} has evolved by more than {maxN*100}%:\nfrom {old[p][impact]} to {builder[p]['impacts'][impact]}."
                )
                stop = True
    if stop:
        print("\nNot recording builder.json")
        sys.exit(1)

    with open(BUILDER, "w") as outfile:
        json.dump(list(builder.values()), outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"Exported {len(builder)} processes to {BUILDER}")
