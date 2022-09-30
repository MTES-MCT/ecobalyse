import json
import pwd
import os
import pandas as pd

dirname = os.path.dirname(__file__)

with open(dirname + r"/products.json") as f:
    products = json.load(f)

with open(dirname + r"/ciqual_plant_transport.txt") as f:
    lines = f.readlines()


plant_transport_procs = [l.replace("\n", "") for l in lines]

transport_modes = {
    r"Transport, freight, inland waterways, barge {RER}| processing | Cut-off, S - Copied from Ecoinvent": "inland_water",
    r"Transport, freight, inland waterways, barge with reefer, cooling {GLO}| processing | Cut-off, S - Copied from Ecoinvent": "inland_water",
    r"Transport, freight, lorry 16-32 metric ton, euro6 {RER}| market for transport, freight, lorry 16-32 metric ton, EURO6 | Cut-off, S - Copied from Ecoinvent": "road",
    r"Transport, freight, lorry >32 metric ton, EURO4 {RER}| transport, freight, lorry >32 metric ton, EURO4 | Cut-off, S - Copied from Ecoinvent": "road",
    r"Transport, freight, lorry 16-32 metric ton, EURO4 {RER}| transport, freight, lorry 16-32 metric ton, EURO4 | Cut-off, S - Copied from Ecoinvent": "road",
    r"Transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling {GLO}| transport, freight, lorry with refrigeration machine, 7.5-16 ton, EURO5, R134a refrigerant, cooling | Cut-off, S - Copied from Ecoinvent": "road",
    r"Transport, freight, lorry 16-32 metric ton, EURO5 {RER}| transport, freight, lorry 16-32 metric ton, EURO5 | Cut-off, S - Copied from Ecoinvent": "road",
    r"Transport, freight train {RER}| market group for transport, freight train | Cut-off, S - Copied from Ecoinvent": "train",
    r"Transport, freight, sea, transoceanic ship {GLO}| processing | Cut-off, S - Copied from Ecoinvent": "sea",
    r"Transport, freight, sea, transoceanic ship {GLO}| market for | Cut-off, S - Copied from Ecoinvent": "sea",
    r"Transport, freight, sea, transoceanic ship with reefer, cooling {GLO}| processing | Cut-off, S - Copied from Ecoinvent": "sea",
    r"Transport, freight, aircraft {RER}| intercontinental | Cut-off, S - Copied from Ecoinvent": "air",
}

output = []
for p in plant_transport_procs:

    # 1st compute the mass transported at plant to convert t.km -> km
    mass = 0
    try:
        mass_procs = products[p]["plant"]["material"]
    except KeyError:
        mass_procs = products[p]["plant"]["processing"]

    for m_p in mass_procs:
        mass += m_p["amount"]

    # 2nd using the t.km per mode and the mass convert to km per mode
    distances = {"road": 0, "train": 0, "sea": 0, "inland_water": 0, "air": 0}
    for t_p in products[p]["plant"]["transport"]:
        t_p_name = t_p["processName"]
        value_km = t_p["amount"] * 1000 / mass

        distances[transport_modes[t_p_name]] = distances.get(t_p_name, 0) + value_km
    output.append(
        [
            p,
            distances["road"],
            distances["train"],
            distances["sea"],
            distances["inland_water"],
            distances["air"],
        ]
    )

df = pd.DataFrame(
    output, columns=["proc", "road", "train", "sea", "inland_water", "air"]
)
df.to_csv(dirname + r"/transport_at_plant.csv", index=None, float_format="%.f")
