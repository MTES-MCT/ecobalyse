#!/usr/bin/env python
# from pprint import pprint
import json
import sys

from bw2data.project import projects

projects.create_project("textile", activate=True, exist_ok=True)

with open("../../../ecobalyse-private/data/textile/processes_impacts.json") as f:
    processes = {p["uuid"]: p for p in json.loads(f.read())}
with open("../../public/data/textile/materials.json") as f:
    materials = json.loads(f.read())
with open("codes.json") as f:
    codes = {c["code"]: c["name"] for c in json.loads(f.read())}


activities = dict()

# recreate activities.json
for process in processes.values():
    activity = process.copy()
    if not process["source"].startswith("Base Impact"):
        del activity["impacts"]
        del activity["name"]
        del activity["unit"]

    activities[activity["uuid"]] = activity

for material in materials:
    puuid = material["materialProcessUuid"]
    # check no missing process
    if material["materialProcessUuid"] not in [p["uuid"] for p in processes.values()]:
        print(f"missing process: {material}")
        sys.exit()

    activities[puuid]["material_id"] = material["id"]
    if (r := material["recycledProcessUuid"]) is not None and r in processes:
        activities[puuid]["recycledProcessUuid"] = r
        del r
    if recycledFrom := material["recycledFrom"]:
        activities[puuid]["recycledFrom"] = recycledFrom
    for key in (
        "shortName",
        "origin",
        "primary",
        "geographicOrigin",
        "defaultCountry",
        "priority",
        "cff",
    ):
        if material[key]:
            activities[puuid][key] = material[key]

open("activities.json", "w").write(
    json.dumps(list(activities.values()), indent=2, ensure_ascii=False)
)

# Mix électrique réseau, AN (antilles néerlandaises)
# Mix électrique réseau, non spécifié
