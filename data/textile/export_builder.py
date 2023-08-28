#!/usr/bin/env python
# coding: utf-8

"""Export des matières et procédés du builder textile"""

from bw2data.project import projects
from textile.impacts import impacts as impacts_definition
import bw2calc
import bw2data
import functools
import hashlib
import json
import uuid

# Input
PROJECT = "Textile"
DBNAME = "Ecoinvent 3.9.1"
BIOSPHERE = "biopshere3"
ACTIVITIES = "activities.json"
IMPACTS = "../../public/data/impacts.json"  # TODO move the impact definition somewhere else and remove base impact
# Output
MATERIALS = "../../public/data/textile/materials.json"
PROCESSES = "../../public/data/textile/processes.json"

projects.create_project(PROJECT, activate=True, exist_ok=True)
bw2data.config.p["biosphere_database"] = BIOSPHERE
db = bw2data.Database(DBNAME)


def isUuid(txt):
    return type(txt) is str and len(txt.split("-")) == 5


def uuidOrSearch(txt):
    return txt if isUuid(txt) or txt is None else search(txt)


@functools.cache
def search(name):
    results = db.search(name)
    if len(results) == 0:
        import pdb; pdb.set_trace()  # fmt: skip
    assert len(results) >= 1, f"'{name}' was not found in Brightway"
    return results[0]


if __name__ == "__main__":
    # keep the previous processes with old impacts
    with open(PROCESSES) as f:
        oldbuilder = json.load(f)

    with open(ACTIVITIES, "r") as f:
        activities = json.load(f)

    print("Creating material list...")
    materials = [
        {
            "id": activity["id"],
            "name": activity["name"],
            "shortName": activity["shortName"],
            "origin": activity["origin"],
            "primary": activity["primary"],
            "geographicOrigin": activity["geographicOrigin"],
            "defaultCountry": activity["defaultCountry"],
            "priority": activity["priority"],
            "cff": activity["cff"],
            "materialAndSpinningProcessUuid": uuidOrSearch(
                activity["materialAndSpinningProcessUuid"]
            ),
            "materialProcessUuid": uuidOrSearch(activity["materialProcessUuid"]),
            "recycledProcessUuid": uuidOrSearch(activity["recycledProcessUuid"]),
            "recycledFrom": activity["recycledFrom"],
        }
        for activity in activities
        if "id" in activity
    ]

    print("Creating process list...")
    processes = {
        activity["name"]: {
            "name": activity["name"],
            "info": activity["info"],
            "unit": activity["unit"],
            "source": activity["source"],
            "uuid": activity["uuid"],
            "impacts": activity["impacts"]
            if activity["source"].startswith("Base Impacts")
            else {},
            "heatMJ": activity.get("heatMJ", "XXXX"),
            "elec_pppm": activity.get("elec_pppm"),
            "elec_MJ": activity.get("elec_MJ"),
            "waste": activity["waste"],
            "alias": activity["alias"],
            "step_usage": activity["step_usage"],
            "correctif": activity["correctif"],
        }
        for activity in activities
    }

    # compute the impacts
    for index, (key, process) in enumerate(processes.items()):
        print(f"Computing impacts: {str(index)}/{len(processes)}", end="\r")
        match process["source"]:
            case "Ecoinvent 3.9.1":
                lca = bw2calc.LCA({search(process["name"]): 1})
                lca.lci()
                for key, method in impacts_definition.items():
                    lca.switch_method(method)
                    lca.lcia()
                    process.setdefault("impacts", {})[key] = float(
                        "{:.10g}".format(lca.score)
                    )
            case _:
                continue

    with open(MATERIALS, "w") as outfile:
        json.dump(materials, outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"\nExported {len(materials)} materials to {MATERIALS}")

    # display impacts that have changed
    old = {(p.get("id") or p["uuid"]): p["impacts"] for p in oldbuilder}
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

    with open(PROCESSES, "w") as outfile:
        json.dump(list(processes.values()), outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"Exported {len(processes)} processes to {PROCESSES}")
