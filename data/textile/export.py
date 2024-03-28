#!/usr/bin/env python
# coding: utf-8

"""Export des matières et procédés du textile"""

from bw2data.project import projects
from common.export import (
    with_subimpacts,
    cached_search,
    with_corrected_impacts,
    display_changes,
)
from common.impacts import impacts as impacts_definition
import bw2calc
import json

# Input
PROJECT = "textile"
DBNAME = "Ecoinvent 3.9.1"
ACTIVITIES = "activities.json"
IMPACTS = "../../public/data/impacts.json"  # TODO move the impact definition somewhere else and remove base impact
# Output
MATERIALS = "../../public/data/textile/materials.json"
PROCESSES = "../../public/data/textile/processes_impacts.json"

projects.set_current(PROJECT)
# projects.activate_project(PROJECT)


def isUuid(txt):
    return type(txt) is str and len(txt.split("-")) == 5


def uuidOrSearch(txt):
    return txt if isUuid(txt) or txt is None else cached_search(DBNAME, txt)


if __name__ == "__main__":
    # keep the previous processes with old impacts
    with open(PROCESSES) as f:
        oldprocesses = json.load(f)

    with open(ACTIVITIES, "r") as f:
        activities = json.load(f)

    print("Getting real name and uuid of activities...")
    for activity in activities:
        activity["name"] = (
            activity["name"]
            if "name" in activity
            else cached_search(DBNAME, activity["search"])["name"]
            + " {"
            + cached_search(DBNAME, activity["search"])["location"]
            + "}"
        )
        activity["uuid"] = (
            activity["uuid"]
            if not activity["source"].startswith("BaseImpact")
            else cached_search(DBNAME, activity["search"])["activity"]
        )

    print("Creating material list...")
    materials = [
        {
            "id": activity["id"],
            "materialProcessUuid": uuidOrSearch(activity["materialProcessUuid"]),
            "recycledProcessUuid": uuidOrSearch(activity["recycledProcessUuid"]),
            "recycledFrom": activity["recycledFrom"],
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
            "name": activity["name"],
            "info": activity["info"],
            "unit": activity["unit"],
            "source": activity["source"],
            "uuid": activity["uuid"],
            "impacts": activity["impacts"]
            if not activity["source"].startswith("BaseImpact")
            else {},
            "heat_MJ": activity.get("heat_MJ", 0),
            "elec_pppm": activity.get("elec_pppm", 0),
            "elec_MJ": activity.get("elec_MJ", 0),
            "waste": activity["waste"],
            "alias": activity["alias"],
            "step_usage": activity["step_usage"],
            "correctif": activity["correctif"],
            # "country": activity["country"],
        }
        for activity in activities
    }

    # compute the impacts
    for index, (key, process) in enumerate(processes.items()):
        print(f"Computing impacts: {str(index)}/{len(processes)}", end="\r")
        match process["source"]:
            case "BaseImpact":
                lca = bw2calc.LCA({cached_search(DBNAME, process["search"]): 1})
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
