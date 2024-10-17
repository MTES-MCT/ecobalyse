# Only pure functions here
import functools
import json
import logging
import urllib.parse
from copy import deepcopy
from os.path import dirname

import bw2calc
import bw2data
import matplotlib
import numpy
import pandas as pd
import requests
from bw2io.utils import activity_hash
from frozendict import frozendict

from common.impacts import impacts as impact_definitions

from .impacts import bytrigram, main_method

logging.basicConfig(level=logging.ERROR)

PROJECT_ROOT_DIR = dirname(dirname(dirname(__file__)))
IMPACTS_FILE = f"{PROJECT_ROOT_DIR}/public/data/impacts.json"
COMPARED_IMPACTS_FILE = "compared_impacts.csv"


with open(IMPACTS_FILE) as f:
    IMPACTS_DEF_ECOBALYSE = json.load(f)


def find_id(dbname, activity):
    return cached_search(dbname, activity["search"]).get(
        "Process identifier", activity["id"]
    )


def compute_simapro_impacts(activity, method):
    strprocess = urllib.parse.quote(activity["name"], encoding=None, errors=None)
    project = urllib.parse.quote(spproject(activity), encoding=None, errors=None)
    method = urllib.parse.quote(main_method, encoding=None, errors=None)
    return bytrigram(
        impact_definitions,
        json.loads(
            requests.get(
                f"http://simapro.ecobalyse.fr:8000/impact?process={strprocess}&project={project}&method={method}"
            ).content
        ),
    )


def compute_brightway_impacts(activity, method):
    results = dict()
    lca = bw2calc.LCA({activity: 1})
    lca.lci()
    for key, method in impact_definitions.items():
        lca.switch_method(method)
        lca.lcia()
        results[key] = float("{:.10g}".format(lca.score))
    return results


def check_ids(ingredients):
    # Check the id is lowercase and does not contain space
    for ingredient in ingredients:
        if (
            ingredient["id"].lower() != ingredient["id"]
            or ingredient["id"].replace(" ", "") != ingredient["id"]
        ):
            raise ValueError(
                f"This identifier is not lowercase or contains spaces: {ingredient['id']}"
            )


def compute_normalization_factors():
    normalization_factors = {}
    for k, v in IMPACTS_DEF_ECOBALYSE.items():
        if v["ecoscore"]:
            normalization_factors[k] = (
                v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            )
        else:
            normalization_factors[k] = 0
    return normalization_factors


def spproject(activity):
    """return the current simapro project for an activity"""
    match activity.get("database"):
        case "Ginko":
            return "Ginko w/o azadirachtin"
        case "Ecobalyse":
            # return a non existing project to force looking at brightway
            return "EcobalyseIsNotASimaProProject"
        case "Ecoinvent 3.9.1":
            return "ADEME UPR"
        case _:
            return "AGB3.1.1 2023-03-06"


def remove_detailed_impacts(processes):
    result = list()
    for process in processes:
        new_process = deepcopy(process)
        for k in new_process["impacts"].keys():
            if k not in ("pef", "ecs"):
                new_process["impacts"][k] = 0
        result.append(new_process)
    return result


def export_json_ordered(data, filename):
    """
    Export data to a JSON file, with added newline at the end.
    Make sure to sort impacts in the json file
    """
    print(f"Exporting {filename}")
    if isinstance(data, list):
        sorted_data = [
            {**item, "impacts": sort_impacts(item["impacts"])}
            if "impacts" in item
            else item
            for item in data
        ]
    elif isinstance(data, dict):
        sorted_data = {
            key: {**value, "impacts": sort_impacts(value["impacts"])}
            if "impacts" in value
            else value
            for key, value in data.items()
        }
    else:
        sorted_data = data

    with open(filename, "w", encoding="utf-8") as file:
        json.dump(sorted_data, file, indent=2, ensure_ascii=False)
        file.write("\n")  # Add a newline at the end of the file
    print(f"\nExported {len(data)} elements to {filename}")


def sort_impacts(impacts):
    # Define the desired order of impact keys
    impact_order = [
        "acd",
        "cch",
        "etf",
        "etf-c",
        "fru",
        "fwe",
        "htc",
        "htc-c",
        "htn",
        "htn-c",
        "ior",
        "ldu",
        "mru",
        "ozd",
        "pco",
        "pma",
        "swe",
        "tre",
        "wtu",
        "pef",
        "ecs",
    ]
    return {key: impacts[key] for key in impact_order if key in impacts}


def load_json(filename):
    """
    Load JSON data from a file.
    """
    with open(filename, "r") as file:
        return json.load(file)


def progress_bar(index, total):
    print(f"Export in progress: {str(index)}/{total}", end="\r")


def with_subimpacts(impacts):
    """compute subimpacts"""
    if not impacts:
        return impacts
    # etf-o = etf-o1 + etf-o2
    impacts["etf-o"] = impacts["etf-o1"] + impacts["etf-o2"]
    del impacts["etf-o1"]
    del impacts["etf-o2"]
    # etf = etf1 + etf2
    impacts["etf"] = impacts["etf1"] + impacts["etf2"]
    del impacts["etf1"]
    del impacts["etf2"]
    return impacts


@functools.cache
def cached_search(dbname, name, excluded_term=None):
    return search(dbname, name, excluded_term)


def search(dbname, name, excluded_term=None):
    results = bw2data.Database(dbname).search(name)
    if excluded_term:
        results = [res for res in results if excluded_term not in res["name"]]
    assert len(results) >= 1, f"'{name}' was not found in Brightway"
    return results[0]


def with_corrected_impacts(impacts_ecobalyse, processes_fd, impacts_key="impacts"):
    """Add corrected impacts to the processes"""
    corrections = {
        k: v["correction"] for (k, v) in impacts_ecobalyse.items() if "correction" in v
    }
    processes = dict(processes_fd)
    processes_updated = {}
    for key, process in processes.items():
        # compute corrected impacts
        for impact_to_correct, correction in corrections.items():
            corrected_impact = 0
            for correction_item in correction:  # For each sub-impact and its weighting
                sub_impact_name = correction_item["sub-impact"]
                if sub_impact_name in process[impacts_key]:
                    sub_impact = process[impacts_key].get(sub_impact_name, 1)
                    corrected_impact += sub_impact * correction_item["weighting"]
                    del process[impacts_key][sub_impact_name]
            process[impacts_key][impact_to_correct] = corrected_impact
        processes_updated[key] = process
    return frozendict(processes_updated)


def with_aggregated_impacts(impacts_ecobalyse, processes_fd, impacts_key="impacts"):
    """Add aggregated impacts to the processes"""

    # Pre-compute normalization factors
    normalization_factors = {
        "ecs": {
            k: v["ecoscore"]["weighting"] / v["ecoscore"]["normalization"]
            for k, v in impacts_ecobalyse.items()
            if v["ecoscore"] is not None
        },
        "pef": {
            k: v["pef"]["weighting"] / v["pef"]["normalization"]
            for k, v in impacts_ecobalyse.items()
            if v["pef"] is not None
        },
    }

    processes_updated = {}
    for key, process in processes_fd.items():
        updated_process = dict(process)
        updated_impacts = updated_process[impacts_key].copy()

        updated_impacts["pef"] = calculate_aggregate(
            updated_impacts, normalization_factors["pef"]
        )
        updated_impacts["ecs"] = calculate_aggregate(
            updated_impacts, normalization_factors["ecs"]
        )

        updated_process[impacts_key] = updated_impacts
        processes_updated[key] = updated_process

    return frozendict(processes_updated)


def calculate_aggregate(process_impacts, normalization_factors):
    # We multiply by 10**6 to get the result in µPts
    return sum(
        10**6 * process_impacts.get(impact, 0) * normalization_factors.get(impact, 0)
        for impact in normalization_factors
    )


def display_changes(key, oldprocesses, processes):
    """Display a nice sorted table of impact changes to review
    key is the field to display (id for food, uuid for textile)"""
    old = {p[key]: p["impacts"] for p in oldprocesses if key in p}
    review = False
    changes = []
    for p in processes:
        for impact in processes[p]["impacts"]:
            if old.get(p, {}).get(impact, {}):
                percent_change = (
                    100
                    * abs(processes[p]["impacts"][impact] - old[p][impact])
                    / old[p][impact]
                )
                if percent_change > 0.1:
                    changes.append(
                        {
                            "trg": impact,
                            "name": p,
                            "%diff": percent_change,
                            "from": old[p][impact],
                            "to": processes[p]["impacts"][impact],
                        }
                    )
                    review = True
    changes.sort(key=lambda c: c["%diff"])
    if review:
        keys = ("trg", "name", "%diff", "from", "to")
        widths = {key: max([len(str(c[key])) for c in changes]) for key in keys}
        print("==".join(["=" * widths[key] for key in keys]))
        print("Please review the impact changes below")
        print("==".join(["=" * widths[key] for key in keys]))
        print("  ".join([f"{key.ljust(widths[key])}" for key in keys]))
        print("==".join(["=" * widths[key] for key in keys]))
        for c in changes:
            print("  ".join([f"{str(c[key]).ljust(widths[key])}" for key in keys]))
        print("==".join(["=" * widths[key] for key in keys]))
        print("  ".join([f"{key.ljust(widths[key])}" for key in keys]))
        print("==".join(["=" * widths[key] for key in keys]))
        print("Please review the impact changes above")
        print("==".join(["=" * widths[key] for key in keys]))


def create_activity(dbname, new_activity_name, base_activity=None):
    """Creates a new activity by copying a base activity or from nothing. Returns the created activity"""
    if "constructed by Ecobalyse" not in new_activity_name:
        new_activity_name = f"{new_activity_name}, constructed by Ecobalyse"
    else:
        new_activity_name = f"{new_activity_name}"

    if base_activity:
        data = base_activity.as_dict().copy()
        del data["code"]
        data["name"] = new_activity_name
        data["System description"] = "Ecobalyse"
        data["database"] = "Ecobalyse"
        code = activity_hash(data)
        new_activity = base_activity.copy(code, **data)
    else:
        data = {
            "production amount": 1,
            "unit": "kilogram",
            "type": "process",
            "comment": "added by Ecobalyse",
            "name": new_activity_name,
            "System description": "Ecobalyse",
        }
        code = activity_hash(data)
        new_activity = bw2data.Database(dbname).new_activity(code, **data)
        new_activity["code"] = code
    new_activity["Process identifier"] = code
    new_activity.save()
    logging.info(f"Created activity {new_activity}")
    return new_activity


def delete_exchange(activity, activity_to_delete, amount=False):
    """Deletes an exchange from an activity."""
    if amount:
        for exchange in activity.exchanges():
            if (
                exchange.input["name"] == activity_to_delete["name"]
                and exchange["amount"] == amount
            ):
                exchange.delete()
                logging.info(f"Deleted {exchange}")
                return

    else:
        for exchange in activity.exchanges():
            if exchange.input["name"] == activity_to_delete["name"]:
                exchange.delete()
                logging.info(f"Deleted {exchange}")
                return
    logging.error(f"Did not find exchange {activity_to_delete}. No exchange deleted")


def new_exchange(activity, new_activity, new_amount=None, activity_to_copy_from=None):
    """Create a new exchange. If an activity_to_copy_from is provided, the amount is copied from this activity. Otherwise, the amount is new_amount."""
    assert (
        new_amount is not None or activity_to_copy_from is not None
    ), "No amount or activity to copy from provided"
    if new_amount is None and activity_to_copy_from is not None:
        for exchange in list(activity.exchanges()):
            if exchange.input["name"] == activity_to_copy_from["name"]:
                new_amount = exchange["amount"]
                break
        else:
            logging.error(
                f"Exchange to duplicate from :{activity_to_copy_from} not found. No exchange added"
            )
            return

    new_exchange = activity.new_exchange(
        name=new_activity["name"],
        input=new_activity,
        amount=new_amount,
        type="technosphere",
        unit=new_activity["unit"],
        comment="added by Ecobalyse",
    )
    new_exchange.save()
    logging.info(f"Exchange {new_activity} added with amount: {new_amount}")


def compute_impacts(frozen_processes, default_db):
    """Add impacts to processes dictionary

    Args:
        frozen_processes (frozendict): dictionary of processes of which we want to compute the impacts
    Returns:
    dictionary of processes with impacts. Example :

    {"sunflower-oil-organic": {
        "id": "sunflower-oil-organic",
        name": "...",
        "impacts": {
            "acd": 3.14,
            ...
            "ecs": 34.3,
        },
        "unit": ...
        },
    "tomato":{
    ...
    }
    """
    processes = dict(frozen_processes)
    print("Computing impacts:")
    for index, (_, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        if "search" not in process:
            print(f"This process has hardcoded impacts: {process['displayName']}")
            continue
        # simapro
        activity = cached_search(process.get("source", default_db), process["search"])
        results = compute_simapro_impacts(activity, main_method)
        # WARNING assume remote is in m3 or MJ (couldn't find unit from COM intf)
        if process["unit"] == "kilowatt hour" and isinstance(results, dict):
            results = {k: v * 3.6 for k, v in results.items()}
        if process["unit"] == "litre" and isinstance(results, dict):
            results = {k: v / 1000 for k, v in results.items()}

        process["impacts"] = results

        if isinstance(results, dict) and results:
            # simapro succeeded
            process["impacts"] = results
            print(f"got impacts from simapro for: {process['name']}")
        else:
            # simapro failed (unexisting Ecobalyse project or some other reason)
            # brightway
            process["impacts"] = compute_brightway_impacts(activity, main_method)
            print(f"got impacts from brightway for: {process['name']}")

        # compute subimpacts
        process["impacts"] = with_subimpacts(process["impacts"])

        # remove unneeded attributes
        for attribute in ["search"]:
            if attribute in process:
                del process[attribute]

    return frozendict({k: frozendict(v) for k, v in processes.items()})


def compare_impacts(frozen_processes, default_db):
    """This is compute_impacts slightly modified to store impacts from both bw and wp"""
    processes = dict(frozen_processes)
    print("Computing impacts:")
    for index, (key, process) in enumerate(processes.items()):
        progress_bar(index, len(processes))
        # simapro
        activity = cached_search(process.get("source", default_db), process["search"])
        results = compute_simapro_impacts(activity, main_method)
        print(f"got impacts from SimaPro for: {process['name']}")
        # WARNING assume remote is in m3 or MJ (couldn't find unit from COM intf)
        if process["unit"] == "kilowatt hour" and isinstance(results, dict):
            results = {k: v * 3.6 for k, v in results.items()}
        if process["unit"] == "litre" and isinstance(results, dict):
            results = {k: v / 1000 for k, v in results.items()}

        process["simapro_impacts"] = results

        # brightway
        process["brightway_impacts"] = compute_brightway_impacts(activity, main_method)
        print(f"got impacts from Brightway for: {process['name']}")

        # compute subimpacts
        process["simapro_impacts"] = with_subimpacts(process["simapro_impacts"])
        process["brightway_impacts"] = with_subimpacts(process["brightway_impacts"])

    processes_corrected_simapro = with_corrected_impacts(
        IMPACTS_DEF_ECOBALYSE, processes, "simapro_impacts"
    )
    processes_corrected_smp_bw = with_corrected_impacts(
        IMPACTS_DEF_ECOBALYSE, processes_corrected_simapro, "brightway_impacts"
    )

    return frozendict({k: frozendict(v) for k, v in processes_corrected_smp_bw.items()})


def plot_impacts(ingredient_name, impacts_smp, impacts_bw, folder):
    impact_labels = impacts_smp.keys()
    normalization_factors = compute_normalization_factors()

    simapro_values = [
        impacts_smp[label] * normalization_factors[label] for label in impact_labels
    ]
    brightway_values = [
        impacts_bw[label] * normalization_factors[label] for label in impact_labels
    ]

    x = numpy.arange(len(impact_labels))
    width = 0.35

    fig, ax = matplotlib.pyplot.subplots(figsize=(12, 8))

    ax.bar(x - width / 2, simapro_values, width, label="SimaPro")
    ax.bar(x + width / 2, brightway_values, width, label="Brightway")

    ax.set_xlabel("Impact Categories")
    ax.set_ylabel("Impact Values")
    ax.set_title(f"Environmental Impacts for {ingredient_name}")
    ax.set_xticks(x)
    ax.set_xticklabels(impact_labels, rotation=90)
    ax.legend()

    matplotlib.pyplot.tight_layout()
    matplotlib.pyplot.savefig(f"{folder}/{ingredient_name}.png")
    matplotlib.pyplot.close()


def csv_export_impact_comparison(compared_impacts, folder):
    rows = []
    for product_id, process in compared_impacts.items():
        simapro_impacts = process.get("simapro_impacts", {})
        brightway_impacts = process.get("brightway_impacts", {})
        for impact in simapro_impacts:
            row = {
                "id": product_id,
                "name": process["name"],
                "impact": impact,
                "simapro": simapro_impacts.get(impact),
                "brightway": brightway_impacts.get(impact),
            }
            row["diff_abs"] = abs(row["simapro"] - row["brightway"])
            row["diff_rel"] = (
                row["diff_abs"] / abs(row["simapro"]) if row["simapro"] != 0 else None
            )

            rows.append(row)

    df = pd.DataFrame(rows)
    df.to_csv(f"{PROJECT_ROOT_DIR}/data/{folder}/{COMPARED_IMPACTS_FILE}", index=False)
