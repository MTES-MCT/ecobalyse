import json

"""Concatenate processes from selected_processes.json and processes.json to build builder_processes.json
    """

processes_to_concatenate = [
"Carrot, organic, Lower Normandy, at farm gate",
"Carrot, conventional, national average, at farm gate",
"Soft wheat grain, conventional, national average, animal feed, at farm gate, production",
"Soft wheat grain, organic, 15% moisture, Central Region, at farm gate",
"Soft wheat grain, conventional, breadmaking quality, 15% moisture, at farm gate",
"Egg, national average, at farm gate",
"Egg, organic, at farm gate",
"Egg, Bleu Blanc Coeur, outdoor system, at farm gate",
"Cow milk, national average, at farm gate",
"Steel, unalloyed {RER}| steel production, converter, unalloyed | Cut-off, S - Copied from Ecoinvent",
"Packaging film, low density polyethylene {RER}| production | Cut-off, S - Copied from Ecoinvent",
"Polystyrene, expandable {RER}| production | Cut-off, S - Copied from Ecoinvent",
"Packaging glass, white {RER w/o CH+DE}| production | Cut-off, S - Copied from Ecoinvent",
"Polypropylene, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent",
"Corrugated board box {RER}| production | Cut-off, S - Copied from Ecoinvent",
"Kraft paper, unbleached {RER}| production | Cut-off, S - Copied from Ecoinvent",
"Polyvinylchloride, suspension polymerised {RER}| polyvinylchloride production, suspension polymerisation | Cut-off, S - Copied from Ecoinvent",
"Polyethylene terephthalate, granulate, bottle grade {RER}| production | Cut-off, S - Copied from Ecoinvent",
"Polyethylene, high density, granulate {RER}| production | Cut-off, S - Copied from Ecoinvent",
"Aluminium, primary, ingot {RoW}| production | Cut-off, S - Copied from Ecoinvent",
"Canning fruits or vegetables, industrial, 1kg of canned product/ FR U",
"Mixing, processing, at plant \"dummy process\"",
"Cooking, industrial, 1kg of cooked product/ FR U"
]

f = open("selected_processes.json")
selected_processes = json.load(f)
selected_processes_name = [s["name"] for s in selected_processes]

f = open("processes.json")
processes = json.load(f)
processes_name = [s["name"] for s in processes]

builder_processes = []

for proc in processes_to_concatenate:
    if proc in selected_processes_name:
        res = [s for s in selected_processes if s["name"] == proc]
        builder_processes.append(res[0])
    elif proc in processes_name:
        res = [s for s in processes if s["name"] == proc]
        builder_processes.append(res[0])

with open("builder_processes.json", "w") as f:
    json.dump(builder_processes, f, ensure_ascii=False)


    