import json
import fjson
import uuid
import sys
import random as rd
import copy

# This script is used to compute to separate the impact of the raw material and the impact of spinning

f = open("../../../public/data/materials.json")
materials = json.load(f)
f = open("../../../public/data/processes.json")
processes = json.load(f)

material_without_spinning = ["neoprene"]


def get_process(uuid):
    matches = [x for x in processes if x["uuid"] == uuid]
    if len(matches) > 1 or len(matches) == 0:
        raise ValueError("Error : proc name matches 0 or multiple processes")
    else:
        return matches[0], processes.index(matches[0])


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
        return get_process(matches[0]["uuid"])[0]


# build a dictionary of recycled material -> material
# because we need to be able to know the category (synthetic or natural) of a recycled material
r_materials_dic = {}
for current_material in materials:
    if current_material["category"] == "Recyclées":
        virgin_material = get_virgin_material(current_material["recycledFrom"])
        r_materials_dic[current_material["id"]] = virgin_material["category"]

## Update processes.json ##

# build a dictionary of material with the materialAndSpinningProcessUuid and defaultCountry
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
            "uuid": current_material["materialAndSpinningProcessUuid"],
            "defaultCountry": current_material["defaultCountry"],
            "shortName": current_material["shortName"],
            "category": category,
        }
        materials_uuids += current_material["materialAndSpinningProcessUuid"]

newMaterialProcessUuid = {}
old_to_new_uuid = {}
new_materials_process = []

# iterate on all materials to update data
for index, (current_material_id, current_material) in enumerate(materials_dic.items()):
    material_process_original, material_index = get_process(current_material["uuid"])
    material_process = copy.deepcopy(material_process_original)
    elec_process = get_elec_process(current_material["defaultCountry"])

    process_name = material_process["name"]

    # update the process info to reflect it's now a process only about the material production
    # and not about the material spinning
    material_process["name"] = current_material["shortName"]
    material_process["info"] = (
        material_process["info"] + " uuid_bi=" + material_process["uuid"]
    )
    material_process[
        "source"
    ] = "Séparation matière-filature Ecobalyse à partir de Base Impacts"

    # generate a new uuid, as it's a new process
    rd.seed(index)
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
    elif current_material["category"] == "Synthétiques et artificielles":
        spinning_waste_ratio_multiplier = 0.02
    else:
        print("spinning_waste_ratio_multiplier is undefined" )
        sys.exit(1)


    # compute the new waste ratio
    # the material_spinning_waste_ratio is a divider ratio (m_output = m /(1+ratio)) whereas  the spinning_waste_ratio is a multiplier ratio (m_output = m * (1-ratio))

    spinning_waste_ratio = 1 / (1 - spinning_waste_ratio_multiplier) - 1
    material_waste_ratio = (material_spinning_waste_ratio - spinning_waste_ratio) / (
        1 + spinning_waste_ratio
    )

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
        # we substract the impact of electricity from the given country
        # we have to account for the waste in the spinning process
        only_material_impact = (value - 3.21 * elec_process["impacts"][impact]) / (
            1 + spinning_waste_ratio
        )

        if only_material_impact < 0:
            print(
                f"NEGATIVE VALUE {only_material_impact:.3e} before {value:.3e} for {process_name}|{impact}"
            )
            only_material_impact = 0

        material_process["impacts"][impact] = only_material_impact
    new_materials_process.append(material_process)

# once we have finished our new process "material_process" we insert it in the processes list after the Base Impacts process
for index, new_material_process in enumerate(new_materials_process):
    # delete old process
    matches = [
        proc for proc in processes if proc["uuid"] == new_material_process["uuid"]
    ]
    processes.remove(matches[0])
    # add new process
    processes.insert(material_index + index + 1, new_material_process)


## Update materials.json ##
# update the materialProcessUuid / recycledProcessUuid / spinningProcessUuid in materials.json
for current_material in materials:
    if current_material["id"] not in material_without_spinning:
        # update materialProcessUuid
        current_material["materialProcessUuid"] = newMaterialProcessUuid[
            current_material["shortName"]
        ]
        current_category = materials_dic[current_material["id"]]["category"]

        # update recycledProcessUuid
        """  if current_material["recycledProcessUuid"] is not None:
            current_material["recycledProcessUuid"] = old_to_new_uuid[
                current_material["recycledProcessUuid"]
            ] """

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

with open("processes_new.json", "w", encoding="utf-8") as outfile:
    outfile.write(processes_string)


materials_string = json.dumps(materials, ensure_ascii=False)
with open("materials_new.json", "w", encoding="utf-8") as outfile:
    outfile.write(materials_string)
print("SUCCESS : Finished writing processes_new.json and materials_new.json")
