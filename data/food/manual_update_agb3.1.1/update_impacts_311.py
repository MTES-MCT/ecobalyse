"""Update builder.json impacts with impacts from agb3.1.1.csv (manually exported from simapro)
example : python update_impacts_3.1.1.py"""

import copy
import pandas as pd
import json
import hashlib
import uuid
from food.export_agb import export_builder

# INPUT
PROCESSES_AGB311 = "agb311.csv"
INGREDIENTS_BASE = "../export_agb/ingredients_base.json"
IMPACTS = "../../../public/data/impacts.json"
# OUTPUT
PROCESSES = "../../../public/data/food/processes/builder.json"



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

            proc["impacts"]["pef"] = export_builder.compute_pef(impacts_ecobalyse, proc["impacts"])
        except KeyError as e:
            print(f"KeyError, normal for complex ingredients 'constructed by ecobalyse', which are computed in the next step : {e}")

    # Compute impacts for complex ingredients. Complex ingredients impacts are computed from other ingredients impacts 

    # Parse the ingredients_base.json, which contains complex ingredients to add/compute
    with open(INGREDIENTS_BASE, "r") as f:
        ingredients_base = json.load(f)

    processes_dic = {p["name"]:p for p in processes_list}

    (ingredient_list, complex_processes) = export_builder.compute_ingredient_list(
        processes_dic, ingredients_base
    )
    # update processes_dic with complex impacts
    for complex_p in complex_processes:
        processes_dic[complex_p["name"]] = complex_p 
    
    processes_list = list(processes_dic.values())
    export_builder.export_json(processes_list, PROCESSES)