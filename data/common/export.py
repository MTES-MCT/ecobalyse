# Only pure functions here
import functools
import bw2data
from peewee import IntegrityError
import logging
import hashlib
import uuid

logging.basicConfig(level=logging.INFO)


def with_subimpacts(process):
    """compute subimpacts in the process"""
    # etf-o = etf-o1 + etf-o2
    process["impacts"]["etf-o"] = (
        process["impacts"]["etf-o1"] + process["impacts"]["etf-o2"]
    )
    del process["impacts"]["etf-o1"]
    del process["impacts"]["etf-o2"]
    # etf = etf1 + etf2
    process["impacts"]["etf"] = process["impacts"]["etf1"] + process["impacts"]["etf2"]
    del process["impacts"]["etf1"]
    del process["impacts"]["etf2"]
    return process


@functools.cache
def search(dbname, name, excluded_term = None):
    results = bw2data.Database(dbname).search(name)
    if excluded_term:    
        results = [res for res in results if excluded_term not in res["name"]]
    assert len(results) >= 1, f"'{name}' was not found in Brightway"
    return results[0]


def with_corrected_impacts(impacts_ecobalyse, processes):
    """Add corrected impacts to the processes"""
    corrections = {
        k: v["correction"] for (k, v) in impacts_ecobalyse.items() if "correction" in v
    }

    for process in processes.values():
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
    return processes


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
    try:
        if base_activity:
            new_activity = base_activity.copy(new_activity_name)
        else:
            new_activity = bw2data.Database(dbname).new_activity(
                {                    
                    "production amount": 1,
                    "unit": "kilogram",
                    "type": "process",                    
                    "comment": "added by Ecobalyse",
                }
            )
        if "constructed by Ecobalyse" not in new_activity_name:
            new_activity_name = f"{new_activity_name}, constructed by Ecobalyse"
        new_activity["name"] = new_activity_name
        new_activity["System description"] = "Ecobalyse"
        code =  str(
            uuid.UUID(
                hashlib.md5(
                    new_activity_name.encode("utf-8")
                ).hexdigest()
            )
        )
        new_activity["code"] = code
        new_activity["Process identifier"] = code
        new_activity.save()
        logging.info(f"Created activity {new_activity}")
        return new_activity
    except (IntegrityError, bw2data.errors.DuplicateNode):
        logging.warning(f"Activity {new_activity_name} already exists")
        return search(dbname, new_activity_name)



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
    logging.warning(f"Did not find exchange {activity_to_delete}. No exchange deleted")


def new_exchange(activity, new_activity, new_amount=None, activity_to_copy_from=None):
    """Create a new exchange. If an activity_to_copy_from is provided, the amount is copied from this activity. Otherwise, the amount is new_amount."""
    if not new_amount and not activity_to_copy_from:
        logging.warning(
            "No amount or activity to copy from provided. No exchange added"
        )
        return
    if not new_amount and activity_to_copy_from:
        for exchange in activity.exchanges():
            if exchange.input["name"] == activity_to_copy_from["name"]:
                new_amount = exchange["amount"]
                break
        else:
            logging.warning(
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


