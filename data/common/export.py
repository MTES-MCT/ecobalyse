# Only pure functions here
import decimal
import functools
import json
import logging
from copy import deepcopy

import bw2data
from bw2io.utils import activity_hash
from frozendict import frozendict

logging.basicConfig(level=logging.ERROR)


def spproject(activity):
    """return the current simapro project for an activity"""
    match activity.get("database"):
        case "Ginko":
            return "Ginko w/o azadirachtin"
        case "Ecobalyse":
            # return a non existing project to force looking at brightway
            return "EcobalyseIsNotASimaProProject"
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


class CustomJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (float, decimal.Decimal)):
            # Format to 6 significant figures
            return f"{obj:.6g}"
        return super().default(obj)


def export_json_ordered(data, filename):
    """
    Export data to a JSON file, with added newline at the end.
    Make sure to sort impacts in the json file and format numbers consistently.
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
        json.dump(
            sorted_data, file, indent=2, ensure_ascii=False, cls=CustomJSONEncoder
        )
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


def format_number(num):
    if isinstance(num, (int, float)):
        # Use scientific notation without leading zeros in exponent
        num_py_g = f"{num:.6g}"
        return num_py_g.replace("e+0", "e").replace("e-0", "e-").replace("e+", "e")
    return str(num)
