# Only pure functions here
import functools


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
def search(db, name):
    results = db.search(name)
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


def display_changes(oldprocesses, processes):
    """Display a nice sorted table of impact changes to review"""
    old = {p["id"]: p["impacts"] for p in oldprocesses}
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
