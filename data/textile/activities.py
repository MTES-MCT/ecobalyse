#!/usr/bin/env python
# from pprint import pprint
from bw2data.project import projects
import bw2data
import json

projects.create_project("textile", activate=True, exist_ok=True)

with open("../../public/data/textile/processes_impacts.json") as f:
    processes = json.loads(f.read())
with open("../../public/data/textile/materials.json") as f:
    materials = {m["name"]: m for m in json.loads(f.read())}
with open("codes.json") as f:
    codes = {c["code"]: c["name"] for c in json.loads(f.read())}


# check no missing process
for material in materials.keys():
    if material not in [p["name"] for p in processes]:
        print(f"missing process: {material}")

for process in processes:
    name = process["name"]
    if name in materials:
        process.update(materials[name])
    if False:  # process["step_usage"] == "Energie":
        process["source"] = "Ecoinvent 3.9.1"
        del process["impacts"]
        # ELEC
        if name.startswith("Mix électrique réseau"):
            (pname, ccode) = name.split(", ", maxsplit=1)
            pname = pname.replace(
                "Mix électrique réseau", "Market for electricity, medium voltage"
            )
            name = f"{pname} {codes[ccode]}"
        # STEAM
        elif name.startswith("Mix Vapeur"):
            if name.endswith("FR") or name.endswith("RER"):
                name = "heat from steam in chemical industry RER"
            elif name.endswith("RSA"):
                name = "heat from steam in chemical industry ROW"
            else:
                assert False
        elif name.startswith("Vapeur à partir de gaz naturel"):
            if name.endswith("RER"):
                name = "market for heat natural gas europe"
            elif name.endswith("RSA"):
                name = "market for heat natural gas ROW"
            else:
                assert False
        elif name.startswith("Vapeur à partir de fioul") or name.startswith(
            "Vapeur à partir de charbon"
        ):
            if name.endswith("RER"):
                name = "market for heat other Europe"
            elif name.endswith("RSA"):
                name = "market for heat other ROW"
            else:
                assert False

        process["name"] = name
        new_process = bw2data.Database("Ecoinvent 3.9.1").search(name)
        match len(new_process):
            case 0:
                print(f"Could not find process {name}")
            case _:
                process["uuid"] = new_process[0].as_dict()["activity"]
    if process["source"] == "Base Impacts":
        process["source"] = "Base Impacts 2.01"
    if process["source"].startswith("Ecoinvent"):
        process["correctif"] = ""

processes = [
    {p[0]: p[1].encode("utf-8") if type(p) is str else p[1] for p in process.items()}
    for process in processes
]

open("activities.json", "w").write(json.dumps(processes, indent=2, ensure_ascii=False))

# Mix électrique réseau, AN (antilles néerlandaises)
# Mix électrique réseau, non spécifié
