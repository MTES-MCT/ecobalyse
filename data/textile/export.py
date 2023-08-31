#!/usr/bin/env python
# coding: utf-8

"""Export des matières et procédés du textile"""

from bw2data.project import projects
from common.export import (
    with_subimpacts,
    search,
    with_corrected_impacts,
    display_changes,
)
from common.impacts import impacts as impacts_definition
import bw2calc
import bw2data
import json

# Input
PROJECT = "Textile"
DBNAME = "Ecoinvent 3.9.1"
DB = bw2data.Database(DBNAME)
BIOSPHERE = "biopshere3"
ACTIVITIES = "activities.json"
IMPACTS = "../../public/data/impacts.json"  # TODO move the impact definition somewhere else and remove base impact
# Output
MATERIALS = "../../public/data/textile/materials.json"
PROCESSES = "../../public/data/textile/processes.json"

projects.create_project(PROJECT, activate=True, exist_ok=True)
bw2data.config.p["biosphere_database"] = BIOSPHERE


def isUuid(txt):
    return type(txt) is str and len(txt.split("-")) == 5


def uuidOrSearch(txt):
    return txt if isUuid(txt) or txt is None else search(DB, txt)


def nameOrSearch(db, activity):
    """returns the provided name or the real name of the activity if there is a search field"""
    return (
        activity["name"]
        if "name" in activity
        else search(db, activity["search"])["name"]
        + " {"
        + search(db, activity["search"])["location"]
        + "}"
    )


if __name__ == "__main__":
    # keep the previous processes with old impacts
    with open(PROCESSES) as f:
        oldprocesses = json.load(f)

    with open(ACTIVITIES, "r") as f:
        activities = json.load(f)

    print("Computing real name of activities...")
    for activity in activities:
        activity["name"] = nameOrSearch(DB, activity)

    print("Creating material list...")
    materials = [
        {
            "id": activity["id"],
            "materialAndSpinningProcessUuid": uuidOrSearch(
                activity["materialAndSpinningProcessUuid"]
            ),
            "materialProcessUuid": uuidOrSearch(activity["materialProcessUuid"]),
            "recycledProcessUuid": uuidOrSearch(activity["recycledProcessUuid"]),
            "recycledFrom": activity["recycledFrom"],
            "search": activity["search"] if "search" in activity else "",
            "name": activity["name"],
            "shortName": activity["shortName"],
            "origin": activity["origin"],
            "primary": activity["primary"],
            "geographicOrigin": activity["geographicOrigin"],
            "defaultCountry": activity["defaultCountry"],
            "priority": activity["priority"],
            "cff": activity["cff"],
        }
        for activity in activities
        if "id" in activity
    ]

    print("Creating process list...")
    processes = {
        activity["name"]: {
            "search": activity["search"] if "search" in activity else "",
            "name": activity["name"],
            "info": activity["info"],
            "unit": activity["unit"],
            "source": activity["source"],
            "uuid": activity["uuid"],
            "impacts": activity["impacts"]
            if activity["source"].startswith("Base Impacts")
            else {},
            "heat_MJ": activity.get("heatMJ", 0),
            "elec_pppm": activity.get("elec_pppm", 0),
            "elec_MJ": activity.get("elec_MJ", 0),
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
                lca = bw2calc.LCA({search(DB, process["search"]): 1})
                lca.lci()
                for key, method in impacts_definition.items():
                    lca.switch_method(method)
                    lca.lcia()
                    process.setdefault("impacts", {})[key] = float(
                        "{:.10g}".format(lca.score)
                    )
                    process["impacts"]["bvi"] = 0

                # compute subimpacts
                process = with_subimpacts(process)

            case _:
                continue

    # cleanup the search term
    for m in materials:
        if "search" in m:
            del m["search"]
    for m in materials:
        if "search" in m:
            del m["search"]

    print("Computing corrected impacts (etf-c, htc-c, htn-c)...")
    with open(IMPACTS, "r") as f:
        processes = with_corrected_impacts(json.load(f), processes)

    # export materials
    with open(MATERIALS, "w") as outfile:
        json.dump(materials, outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"\nExported {len(materials)} materials to {MATERIALS}")

    # display impacts that have changed
    display_changes("uuid", oldprocesses, processes)

    # export processes
    with open(PROCESSES, "w") as outfile:
        json.dump(list(processes.values()), outfile, indent=2, ensure_ascii=False)
        # Add a newline at the end of the file, to avoid creating a diff with editors adding a newline
        outfile.write("\n")
    print(f"Exported {len(processes)} processes to {PROCESSES}")
