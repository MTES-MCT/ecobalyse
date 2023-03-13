"""Update builder.json impacts with impacts from agb3.1.1.csv (manually exported from simapro)
example : python update_impacts_3.1.1.py"""

import copy
import pandas as pd
import json
import hashlib
import uuid

# INPUT
PROCESSES_AGB311 = "agb311.csv"
INGREDIENTS_BASE = "../export_agb/ingredients_base.json"
IMPACTS = "../../../public/data/impacts.json"
# OUTPUT
PROCESSES = "../../../public/data/food/processes/builder.json"

def export_json(content, filename):
    with open(filename, "w") as outfile:
        json.dump(content, outfile, indent=2, ensure_ascii=False)
        outfile.write("\n")  # Add a newline at the end of the file, as many editors do.


def parse_ingredient_list(ingredients_base):
    processes_to_add = []

    for ingredient in ingredients_base:
        for variant_name, variant in ingredient["variants"].items():
            if isinstance(variant, dict):
                # This is a complex ingredient, we need to create a new process from the elements we have.
                processes_to_add.append(variant["simple_ingredient_default"])
                processes_to_add.append(variant["simple_ingredient_variant"])
    return processes_to_add

class ProcessNotFoundByIdError(Exception):
    def __init__(self, process_id):
        self.message = f"Procédé non trouvé pour l'id {process_id}"
        super().__init__(self.message)

def get_process_by_id(processes, process_id):
    for process in processes.values():
        if process["simapro_id"] == process_id:
            return process
    raise ProcessNotFoundByIdError(process_id)


class ProcessNotFoundByNameError(Exception):
    def __init__(self, process_name):
        self.message = f"Procédé non trouvé pour le nom {process_name}"
        super().__init__(self.message)


def get_process_by_name(processes, process_name):
    new_name = name_change_dict.get(process_name,process_name)
    for process in processes.values():        
        if process["name"] == new_name:
            return process
    raise ProcessNotFoundByNameError(process_name)


def compute_complex_ingredient(processes, ingredients_base):
    new_processes = []

    for ingredient in ingredients_base:
        for variant_name, variant in ingredient["variants"].items():
            if isinstance(variant, dict):
                # This is a complex ingredient, we need to create a new process from the elements we have.
                complex_ingredient_default = get_process_by_id(
                    processes, ingredient["default"]
                )
                # The ratio is the quantity of simple ingredient necessary to produce 1 unit of complex ingredient
                # For example, you need 1.16 kg of wheat (simple) to produce 1 kg of flour (complex) -> ratio = 1.16
                ratio = variant["ratio"]

                simple_ingredient_default = get_process_by_name(
                    processes, variant["simple_ingredient_default"]
                )
                simple_ingredient_variant = get_process_by_name(
                    processes, variant["simple_ingredient_variant"]
                )

                new_process = copy.deepcopy(complex_ingredient_default)
                new_process[
                    "name"
                ] = f"{ingredient['id']}, {variant_name}, constructed by ecobalyse"
                new_process["system_description"] = "ecobalyse"

                # We generate a uuid using the process name as a seed
                m = hashlib.md5()
                seed = new_process["name"]
                m.update(seed.encode("utf-8"))
                new_process["simapro_id"] = str(uuid.UUID(m.hexdigest()))

                for impact in new_process["impacts"]:
                    # Formula: Impact farine bio = impact farine conventionnel + ratio * ( impact blé bio -  impact blé conventionnel)
                    new_process["impacts"][impact] = new_process["impacts"][
                        impact
                    ] + ratio * (
                        simple_ingredient_variant["impacts"][impact]
                        - simple_ingredient_default["impacts"][impact]
                    )
                ingredient["variants"][variant_name] = new_process["simapro_id"]

                new_processes.append(new_process)

    return (ingredients_base, new_processes)

def compute_pef(impacts_ecobalyse, impacts_dic):
    pef = 0
    total_weighting = 0
    for k in impacts_ecobalyse.keys():
        if k == "pef" or impacts_ecobalyse[k]["pef"] is None:
            continue
        norm = impacts_ecobalyse[k]["pef"]["normalization"]
        weight = impacts_ecobalyse[k]["pef"]["weighting"]
        total_weighting += weight
        pef += impacts_dic[k] * weight / norm
    # The PEF is computed for a total weighting of 1 (100%), if we are above
    # (because of BVI for example), then normalize it
    pef /= total_weighting
    pef *= 1000000  # We need the result in µPt, but we have it in Pt
    return pef


if __name__ == "__main__":

    # prepare the impacts exported from simapro (agb3.1.1.csv)

    df = pd.read_csv(PROCESSES_AGB311)

    rename_columns = {
        'Climate change': 'cch',
        'Ozone depletion': 'ozd',
        'Ionising radiation': 'ior',
        'Photochemical ozone formation': 'pco',
        'Particulate matter': 'pma',
        'Human toxicity, non-cancer': 'htn',
        'Human toxicity, cancer': 'htc',
        'Acidification': 'acd',
        'Eutrophication, freshwater': 'fwe',
        'Eutrophication, marine': 'swe',
        'Eutrophication, terrestrial': 'tre',
        'Ecotoxicity, freshwater': 'etf',
        'Land use': 'ldu',
        'Water use': 'wtu',
        'Resource use, fossils': 'fru',
        'Resource use, minerals and metals': 'mru',
        'Climate change - Fossil': '',
        'Climate change - Biogenic': '',
        'Climate change - Land use and LU change': '',
        'Human toxicity, non-cancer - organics': 'htn-o',
        'Human toxicity, non-cancer - inorganics': 'htn-i',
        'Human toxicity, non-cancer - metals': 'htn-m',
        'Human toxicity, cancer - organics': 'htc-o',
        'Human toxicity, cancer - inorganics': 'htc-i',
        'Human toxicity, cancer - metals': 'htc-m',
        'Ecotoxicity, freshwater - organics': 'etf-o',
        'Ecotoxicity, freshwater - inorganics': 'etf-i',
        'Ecotoxicity, freshwater - metals': 'etf-m'
    }

    df.rename(columns=rename_columns, inplace=True)
    df.drop(columns = [''], inplace=True)
    df.set_index("name", inplace = True, verify_integrity=True)
    agb311_dict = df.to_dict('index')

    print(agb311_dict)

    # processes name changed between agb3.1 and agb3.11 
    # so we have to update the names

    name_change_df =pd.read_csv("name_change.csv")
    name_change_df.set_index("name3.1", inplace = True, verify_integrity=True)
    name_change_dict = name_change_df.to_dict('index')
    name_change_dict = {k:v["name3.1.1"] for (k,v) in name_change_dict.items()}

    print(name_change_dict)

    with open(PROCESSES) as json_file:
        processes_list = json.load(json_file)

    with open(IMPACTS, "r") as f:
        impacts_ecobalyse = json.load(f)

        
    for proc in processes_list:
        # replace old name with new names is there is one    
        if proc["name"] in name_change_dict.keys():
            print(f"Process replacement : AGB3.1 {proc['name']} replaced by AGB3.1.1 {name_change_dict[proc['name']]}")
            proc["name"] = name_change_dict[proc["name"]]

        # update builder.json with agb3.1.1 
        try:
            for impact,value in agb311_dict[proc["name"]].items():
                proc["impacts"][impact] = value

            proc["impacts"]["pef"] = compute_pef(impacts_ecobalyse, proc["impacts"])
        except KeyError as e:
            print(f"KeyError, normal for complex ingredients 'constructed by ecobalyse', which are computed in the next step : {e}")

    # Compute impacts for complex ingredients. Complex ingredients impacts are computed from other ingredients impacts 

    # Parse the ingredients_base.json, which contains complex ingredients to add/compute
    with open(INGREDIENTS_BASE, "r") as f:
        ingredients_base = json.load(f)

    processes_dic = {p["name"]:p for p in processes_list}

    (ingredient_list, complex_processes) = compute_complex_ingredient(
        processes_dic, ingredients_base
    )
    # update processes_dic with complex impacts
    for complex_p in complex_processes:
        processes_dic[complex_p["name"]] = complex_p 
    
    processes_list = [v for (k,v) in processes_dic.items()]
    export_json(processes_list, PROCESSES)