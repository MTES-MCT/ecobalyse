#!/usr/bin/env python
# from pprint import pprint
from bw2data.project import projects
import bw2data
import json

projects.create_project("Ecobalyse", activate=True, exist_ok=True)

with open("processes.json") as f:
    processes = json.loads(f.read())
with open("materials.json") as f:
    materials = json.loads(f.read())
with open("codes.json") as f:
    codes = {c["code"]: c["name"] for c in json.loads(f.read())}

dmaterials = {m["name"]: m for m in materials}

for process in processes:
    if process["name"] in dmaterials:
        process.update(dmaterials[process["name"]])
    if process["step_usage"] == "Energie":
        process["source"] = "Ecoinvent 3.9.1"
        del process["impacts"]
        # ELEC
        if process["name"].startswith("Mix électrique réseau"):
            (pname, ccode) = process["name"].split(", ", maxsplit=1)
            pname = pname.replace(
                "Mix électrique réseau", "Market for electricity, medium voltage"
            )
            process["name"] = f"{pname} {codes[ccode]}"
        # STEAM
        elif process["name"].startswith("Mix Vapeur"):
            if process["name"].endswith("FR") or process["name"].endswith("RER"):
                process["name"] = "heat from steam in chemical industry RER"
            elif process["name"].endswith("RSA"):
                process["name"] = "heat from steam in chemical industry ROW"
            else:
                assert False
        elif process["name"].startswith("Vapeur à partir de gaz naturel"):
            if process["name"].endswith("RER"):
                process["name"] = "market for heat natural gas europe"
            elif process["name"].endswith("RSA"):
                process["name"] = "market for heat natural gas ROW"
            else:
                assert False
        elif process["name"].startswith("Vapeur à partir de fioul") or process[
            "name"
        ].startswith("Vapeur à partir de charbon"):
            if process["name"].endswith("RER"):
                process["name"] = "market for heat other Europe"
            elif process["name"].endswith("RSA"):
                process["name"] = "market for heat other ROW"
            else:
                assert False

        new_process = bw2data.Database("Ecoinvent 3.9.1").search(process["name"])
        match len(new_process):
            case 0:
                print(f'Could not find process {process["name"]}')
            case _:
                process["uuid"] = new_process[0].as_dict()["activity"]
    if process["source"] == "Base Impacts":
        process["source"] = "Base Impacts 2.01"

processes = [
    {p[0]: p[1].encode("utf-8") if type(p) is str else p[1] for p in process.items()}
    for process in processes
]

open("activities.json", "w").write(json.dumps(processes, indent=2, ensure_ascii=False))

# Mix électrique réseau, AN (antilles néerlandaises)
# Mix électrique réseau, non spécifié
