"""Update builder.json impacts by adding corrected impacts computed from 
sub-impacts from agb3.1.1.csv (manually exported from simapro).

example : python compute_corrected_impacts.py

This should be run after the `update_impacts_311.py` script has run, which adds
the sub-impacts like htc-o, htc-i, htc-m...

"""

import json
from food.export_agb.export_builder import export_json

# INPUT
IMPACTS = "../../../public/data/impacts.json"
# OUTPUT
PROCESSES = "../../../public/data/food/processes/builder.json"

if __name__ == "__main__":
    with open(PROCESSES) as json_file:
        processes_list = json.load(json_file)

    with open(IMPACTS, "r") as f:
        impacts_ecobalyse = json.load(f)

    corrections = {k: v["correction"] for (k, v) in impacts_ecobalyse.items()
                   if "correction" in v}

    for (impact_to_correct, correction) in corrections.items():  # For each impact to correct (eg: htc)
        for process_data in processes_list:  # For each process in the exported processes list that contains the sub-impacts instead of the corrected impacts
            print("correcting ", process_data["name"])
            corrected_impact = 0
            try:
                for correction_item in correction:  # For each sub-impact and its weighting
                    sub_impact_name = correction_item["sub-impact"]
                    sub_impact = process_data["impacts"][sub_impact_name]
                    corrected_impact += sub_impact * correction_item["weighting"]
                    del process_data["impacts"][sub_impact_name]
                process_data["impacts"][impact_to_correct] = corrected_impact
            except Exception as e:
                print(f"\033[91mFailed to correct impact {impact_to_correct} for \"process {process_data['name']}:\"\033[0m")

    export_json(processes_list, PROCESSES)
