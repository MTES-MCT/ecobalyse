import pandas as pd
import json
import fjson
import pprint
import os

"""Script to compute the precalculated process :
     "Fin de vie hors voiture (transport en camion, incinération, mise en décharge)"    
    """

# adapt path
f = open("../../../public/data/processes.json")
f = open("eol_processes.json")
processes = json.load(f)

def get_process(process_name):
    matches = [x for x in processes if x["name"] == process_name]
    if len(matches) > 1 or len(matches) == 0:
        print("Error : proc name matches 0 or multiple processes")
    else:
        return matches[0]


proc_landfill = "Mise en décharge de textiles, FR"
proc_incineration = "Incinération de déchets - Déchets textiles, FR"
proc_transport = "Transport en camion 7,5t (3t) France (dont parc, utilisation et infrastructure) (50%) [tkm], FR"
proc_elec = "Mix électrique réseau, FR"


# these constants are calculated based on a table in the doc : https://fabrique-numerique.gitbook.io/wikicarbone/methodologie/etape-7-fin-de-vie
# total distance of truck transport for an apparel (67.48 km)
d_camion = 30 * 80.5 / 100 + 130 * 19.5 / 100 + 100 * 16.9 / 100 + 30 * 3.6 / 100
incineration_share = (80.5 / 100 + 2.6 / 100) * 45 / 100
landfill_share = (80.5 / 100 + 2.6 / 100) * 55 / 100

# the figure for the amount of elec generated during incineration comes from Base Impacts : https://base-impacts.ademe.fr/personalspace/read-process/id/379113/idVersion/32
# in MJ/kg
incineration_elec_generated = 2.24


# get processes from eol_processes.json
process_landfill = get_process(proc_landfill)
process_transport = get_process(proc_transport)
process_incineration = get_process(proc_incineration)
process_elec = get_process(proc_elec)
eol_process_impacts = {}

# iterate on impacts to calculate the impact of the aggregate process
for impact, value in process_landfill["impacts"].items():
    # the transport impact per kg is equal to the average eol distance in km travelled by an apparel multiplied by the transport impact of a ton.km
    # given that we are working in kg we have to divide the impact by 1000
    impact_transport = d_camion * process_transport["impacts"][impact] / 1000
    # to compute the impact of incineration we have to substract the impact of the electricity generated (divided by 3.6 to convert from MJ to kWh)
    # we don't take into account the heat generated during the burning as it is not classified as a "valuable substance" acccording to Base Impact documentation : https://base-impacts.ademe.fr/personalspace/read-process/id/379113/idVersion/32
    impact_incineration = incineration_share * (
        process_incineration["impacts"][impact]
        - incineration_elec_generated / 3.6 * process_elec["impacts"][impact]
    )
    impact_landfill = landfill_share * process_landfill["impacts"][impact]
    # the total impact of the eol_process is the sum of the incineration + transport + landfill
    total_impact = impact_incineration + impact_transport + impact_landfill
    eol_process_impacts[impact] = total_impact


eol_process = {
    "name": "Fin de vie hors voiture (transport en camion, incinération, mise en décharge)",
    "info": "Fin de vie > Aggrégation multi-impacts > ",
    "unit": "kg",
    "source": "Base Impacts",
    "uuid": "266fa378-77c0-11ec-90d6-0242ac120003 ",
    "impacts": eol_process_impacts,
    "heat_MJ": 0.0,
    "elec_pppm": 0.0,
    "elec_MJ": 0.0,
    "waste": 0.0,    
    "alias": "end-of-life",
}
# We convert floats to scientific notation with 5 digits of precision
eol_process_string = fjson.dumps(eol_process, float_format=".5e")

with open("precalculated_eol_process.json", "w", encoding="utf-8") as outfile:
    outfile.write(eol_process_string)
