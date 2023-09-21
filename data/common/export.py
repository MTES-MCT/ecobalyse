# Only pure functions here
import functools
import bw2data
from peewee import IntegrityError


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
def search(dbname, name):
    results = bw2data.Database(dbname).search(name)
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


def create_new_activity(dbname, base_process, new_activity_name):
    try:
        new_activity = base_process.copy(new_activity_name)

        new_activity["name"] = new_activity_name
        new_activity["System description"] =  "Ecobalyse"
        new_activity.save()
        print(f"create_new_process: Created process {new_activity}")
        return new_activity
    except IntegrityError as e:
        print(e)
        print("create_new_process: Process already exist")
        return search(dbname, new_activity_name)


def delete_exchange(activity, activity_to_delete, amount=False):
    if amount:
        for exchange in activity.exchanges():
            if (
                exchange.input["name"] == activity_to_delete["name"]
                and exchange["amount"] == amount
            ):
                exchange.delete()
                print(f"delete_exchange : Deleted {exchange}")
                return True

    else:
        for exchange in activity.exchanges():
            if exchange.input["name"] == activity_to_delete["name"]:
                exchange.delete()
                print(f"delete_exchange : Deleted {exchange}")
                return True
    print(
        f"delete_exchange : Did not find exchange {activity_to_delete}, no exchange deleted"
    )


def duplicate_exchange(activity, activity_to_duplicate, new_activity, new_amount=None):
    if any(exch.input["name"] == new_activity["name"] for exch in activity.exchanges()):
        print(
            f"duplicate_exchange : Exchange with {new_activity} already added, no exchange added"
        )
        return False

    for exchange in activity.exchanges():
        if exchange.input["name"] == activity_to_duplicate["name"]:
            if not new_amount:
                new_amount = exchange["amount"]
            new_exchange = activity.new_exchange(
                name=new_activity["name"],
                input=new_activity,
                amount=new_amount,
                type=exchange["type"],
                unit=exchange["unit"]
            )
            new_exchange.save()
            print(
                f"duplicate_exchange: Duplicated exchange {activity_to_duplicate} with new name {new_activity} and amount: {new_amount}"
            )
            return True

    print("duplicate_exchange: Exchange to duplicate not found. No exchange was added")
    return False
