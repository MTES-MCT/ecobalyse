from xxlimited import new
import pandas as pd
import json
import fjson
import pprint
import os
import uuid
import random as rd

f = open(r"../src/wikicarbone-data/data_prep/materials.json")
materials = json.load(f)
f = open(r"../src/wikicarbone-data/data_prep/processes.json")
processes = json.load(f)


material_without_spinning = ["neoprene"]


def get_process(uuid):
    matches = [x for x in processes if x["uuid"] == uuid]
    if len(matches) > 1 or len(matches) == 0:
        return "Error : proc name matches 0 or multiple processes"
    else:
        return matches[0]


def get_virgin_material(id):
    matches = [x for x in materials if x["id"] == id]
    if len(matches) > 1 or len(matches) == 0:
        raise ValueError("Error : proc name matches 0 or multiple processes")
    else:
        return matches[0]


def get_elec_process(country_code):
    elec_process = "Mix électrique réseau, " + country_code

    matches = [x for x in processes if x["name"] == elec_process]
    if len(matches) > 1 or len(matches) == 0:
        raise ValueError("Error : proc name matches 0 or multiple processes")
    else:
        return get_process(matches[0]["uuid"])


# build a dictionary of recycled material -> material
r_materials_dic = {}
for current_material in materials:
    if current_material["category"] == "Recyclées":
        virgin_material = get_virgin_material(current_material["recycledFrom"])
        r_materials_dic[current_material["id"]] = virgin_material["category"]


# build a dictionary of material with the materialProcessUuid and defaultCountry
materials_dic = {}
materials_uuids = []
for current_material in materials:
    if current_material["id"] not in material_without_spinning:

        # assign a category ("Synthétiques et artificielles", "Naturelles") to each material
        # for recycled material we use the category of the virgin material
        if current_material["category"] == "Recyclées":
            category = r_materials_dic[current_material["id"]]

        else:
            category = current_material["category"]

        materials_dic[current_material["id"]] = {
            "uuid": current_material["materialProcessUuid"],
            "defaultCountry": current_material["defaultCountry"],
            "shortName": current_material["shortName"],
            "category": category,
        }
        materials_uuids += current_material["materialProcessUuid"]

newMaterialProcessUuid = {}
old_to_new_uuid = {}
# iterate on all materials to update data
i = 0
for current_material_id, current_material in materials_dic.items():
    material_process = get_process(current_material["uuid"])
    elec_process = get_elec_process(current_material["defaultCountry"])

    process_name = material_process["name"]

    # update the process info to reflect it's now a process only about the material production
    # and not about the material spinning
    material_process["name"] = current_material["shortName"]
    material_process["info"] = (
        material_process["info"] + " uuid_bi=" + material_process["uuid"]
    )
    material_process["source"] = "Wikicarbone"

    # generate a new uuid, as it's a new process
    rd.seed(i)
    new_uuid = str(uuid.UUID(int=rd.getrandbits(128)))
    old_to_new_uuid[material_process["uuid"]] = new_uuid
    material_process["uuid"] = new_uuid

    # save in a dic the shortName -> new_uuid to update the materialProcessUuid in materials.json
    newMaterialProcessUuid[material_process["name"]] = material_process["uuid"]

    # compute the new waste ratio
    # pour la filature c'est 8% pour la filature naturelle, 2% pour les synthétiques

    material_spinning_waste_ratio = material_process["waste"]

    if current_material["category"] == "Naturelles":
        spinning_waste_ratio_multiplier = 0.08

    if current_material["category"] == "Synthétiques et artificielles":
        spinning_waste_ratio_multiplier = 0.02

    # compute the new waste ratio
    # the material_spinning_waste_ratio is a divider ratio (m_output = m /(1+ratio)) whereas  the spinning_waste_ratio is a multiplier ratio (m_output = m * (1-ratio))

    spinning_waste_ratio = 1 / (1 - spinning_waste_ratio_multiplier) - 1
    material_waste_ratio = (material_spinning_waste_ratio - spinning_waste_ratio) / (
        1 + spinning_waste_ratio
    )
    """ material_waste_ratio = (
        material_spinning_waste_ratio
        - spinning_waste_ratio_multiplier
        - spinning_waste_ratio_multiplier * material_spinning_waste_ratio
    ) """

    # if the computed material_waste_ratio is negative we make the hypothesis that the waste ratio is 0 (no waste)
    # we still use the default spinning ratio so we still consider that there is more waste than
    # this happens for synthetic materials (polyuréthane, aramide, acrylique)
    if material_waste_ratio >= 0:
        material_process["waste"] = material_waste_ratio
    else:
        print(
            f"NEGATIVE VALUE {material_waste_ratio:.3e} before {material_spinning_waste_ratio:.3e} for {process_name}|waste ratio"
        )
        material_process["waste"] = 0

    # iterate on all impacts
    for impact, value in material_process["impacts"].items():
        # # for recycled material we make the hypothesis that the material impact is = 0
        # if "recyclé" in process_name:
        #     new_material_impact = 0
        #        else:
        # we substract the impact of electricity from the given country
        # we have to account for the waste in the spinning process
        new_material_impact = (value - 3.21 * elec_process["impacts"][impact]) / (
            1 + spinning_waste_ratio
        )

        if new_material_impact < 0:
            print(
                f"NEGATIVE VALUE {new_material_impact:.3e} before {value:.3e} for {process_name}|{impact}"
            )
            new_material_impact = 0

        material_process["impacts"][impact] = new_material_impact
    i += 1


# update the materialProcessUuid / recycledProcessUuid / spinningProcessUuid in materials.json
for current_material in materials:
    if current_material["id"] not in material_without_spinning:
        # update materialProcessUuid
        current_material["materialProcessUuid"] = newMaterialProcessUuid[
            current_material["shortName"]
        ]
        current_category = materials_dic[current_material["id"]]["category"]

        # update recycledProcessUuid
        if current_material["recycledProcessUuid"] is not None:
            current_material["recycledProcessUuid"] = old_to_new_uuid[
                current_material["recycledProcessUuid"]
            ]

        # update spinningProcessUuid
        if current_category == "Naturelles":
            current_material[
                "spinningProcessUuid"
            ] = "4c5438c3-c360-413c-b357-fba2a851e44c"
        if current_category == "Synthétiques et artificielles":
            current_material[
                "spinningProcessUuid"
            ] = "6f8b64d7-24bf-4024-b0f5-0e3a6597d825"
    else:
        current_material["spinningProcessUuid"] = None

# We convert floats to scientific notation with 5 digits of precision
# for that have to use fjson.dumps which only accepts dictionnaries
# so we have to iterate on our process list on concatenate the resulting strings
processes_string = "["
for process in processes:
    proc_formatted = fjson.dumps(process, float_format=".5e")
    processes_string += proc_formatted + ","
processes_string = processes_string[:-1] + "]"

with open(
    r"../src/wikicarbone-data/data_prep/processes_new.json", "w", encoding="utf-8"
) as outfile:
    outfile.write(processes_string)


materials_string = json.dumps(materials, ensure_ascii=False)
with open(
    r"../src/wikicarbone-data/data_prep/materials_new.json", "w", encoding="utf-8"
) as outfile:
    outfile.write(materials_string)
print("SUCCESS : Finished writing processes_new.json and materials_new.json")
