#!/usr/bin/env python

from subprocess import call
from zipfile import ZipFile
import bw2data
import bw2io
from bw2io.importers.simapro_csv import SimaProCSVImporter
from bw2io.migrations import Migration
from bw2data import Database

CSVFILE = "AGB3.1.1.20230306.CSV"
PROJECT = "AGB3.1.1"
DATABASE = "agribalyse3.1"

with ZipFile(CSVFILE + ".zip") as zf:
    print("Extracting the agribalyse zip file...")
    zf.extractall()

print("Importing the agribalyse database in the brightway database...")


# sed is faster than Python
call("sed -i 's/yield/Yield_/g' " + CSVFILE, shell=True)
call("sed -i 's/01\\/03\\/2005/1\\/3\\/5/g' " + CSVFILE, shell=True)
call("sed -i 's/0;001172/0,001172/' " + CSVFILE, shell=True)

bw2data.projects.set_current(PROJECT)
bw2io.bw2setup()

agb_technosphere_migration_data = {
    "fields": ["name", "unit"],
    "data": [
        (
            (
                "Wastewater, average {Europe without Switzerland}| market for wastewater, average | Cut-off, S - Copied from Ecoinvent",
                "litre",
            ),
            {"unit": "cubic meter", "multiplier": 1e-3},
        ),
        (
            (
                "Wastewater, from residence {RoW}| market for wastewater, from residence | Cut-off, S - Copied from Ecoinvent",
                "litre",
            ),
            {"unit": "cubic meter", "multiplier": 1e-3},
        ),
        (
            (
                "Heat, central or small-scale, natural gas {Europe without Switzerland}| market for heat, central or small-scale, natural gas | Cut-off, S - Copied from Ecoinvent",
                "kilowatt hour",
            ),
            {"unit": "megajoule", "multiplier": 3.6},
        ),
        (
            (
                "Heat, district or industrial, natural gas {Europe without Switzerland}| heat production, natural gas, at industrial furnace >100kW | Cut-off, S - Copied from Ecoinvent",
                "kilowatt hour",
            ),
            {"unit": "megajoule", "multiplier": 3.6},
        ),
        (
            (
                "Heat, district or industrial, natural gas {RER}| market group for | Cut-off, S - Copied from Ecoinvent",
                "kilowatt hour",
            ),
            {"unit": "megajoule", "multiplier": 3.6},
        ),
        (
            (
                "Heat, district or industrial, natural gas {RoW}| market for heat, district or industrial, natural gas | Cut-off, S - Copied from Ecoinvent",
                "kilowatt hour",
            ),
            {"unit": "megajoule", "multiplier": 3.6},
        ),
        (
            (
                "Land use change, perennial crop {BR}| market group for land use change, perennial crop | Cut-off, S - Copied from Ecoinvent",
                "square meter",
            ),
            {"unit": "hectare", "multiplier": 1e-4},
        ),
    ],
}
agb_importer = SimaProCSVImporter(CSVFILE, DATABASE)

agb_technosphere_migration = Migration("agb-technosphere")
agb_technosphere_migration.write(
    agb_technosphere_migration_data,
    description="Specific technosphere fixes for Agribalyse 3",
    #  'name': 'Cauliflower, winter, conventional, nitrogen management with decision support tool Pilazo, at farm gate {FR} U'
)

agb_importer.apply_strategies()
agb_importer.migrate("agb-technosphere")
agb_importer.statistics()
# agb_importer.write_excel(only_unlinked=True)
Database(DATABASE + " biosphere").register()
agb_importer.add_unlinked_flows_to_biosphere_database(DATABASE + " biosphere")
agb_importer.add_unlinked_activities()
agb_importer.statistics()

# packagings = [
#    "PS",
#    "LDPE",
#    "PP",
#    "Cardboard",
#    "No packaging",
#    "Already packed - PET",
#    "Glass",
#    "Steel",
#    "PVC",
#    "PET",
#    "Paper",
#    "HDPE",
#    "Already packed - PP/PE",
#    "Already packed - Aluminium",
#    "Already packed - Steel",
#    "Already packed - Glass",
#    "Corrugated board and aluminium packaging",
#    "Corrugated board and LDPE packaging",
#    "Aluminium",
#    "PP/PE",
#    "Corrugated board and PP packaging",
# ]
# stages = ["at consumer", "at packaging", "at supermarket", "at distribution"]
# transport_types = [
#    "Chilled",
#    "Ambient (average)",
#    "Ambient (long)",
#    "Ambient (short)",
#    "Frozen",
# ]
# preparation_modes = [
#    "Oven",
#    "No preparation",
#    "Microwave",
#    "Boiling",
#    "Chilled at consumer",
#    "Pan frying",
#    "Water cooker",
#    "Deep frying",
# ]
#
# import re
#
# from tqdm import tqdm
#
# dqr_pattern = r"The overall DQR of this product is: (?P<overall>[\d.]+) {P: (?P<P>[\d.]+), TiR: (?P<TiR>[\d.]+), GR: (?P<GR>[\d.]+), TeR: (?P<TeR>[\d.]+)}"
# ciqual_pattern = r"\[Ciqual code: (?P<ciqual>[\d_]+)\]"
# location_pattern = r"\{(?P<location>[\w ,\/\-\+]+)\}"
# location_pattern_2 = r"\/\ *(?P<location>[\w ,\/\-]+) U$"
#
# for activity in tqdm(agb_importer):
#    # Getting activities locations
#    if "name" not in activity:
#        agb_importer.data = [i for i in agb_importer.data if i != activity]
#        continue
#    if activity.get("location") is None:
#        match = re.search(pattern=location_pattern, string=activity["name"])
#        if match is not None:
#            activity["location"] = match["location"]
#        else:
#            match = re.search(pattern=location_pattern_2, string=activity["name"])
#            if match is not None:
#                activity["location"] = match["location"]
#            elif ("French production," in activity["name"]) or (
#                "French production mix," in activity["name"]
#            ):
#                activity["location"] = "FR"
#            elif "CA - adapted for maple syrup" in activity["name"]:
#                activity["location"] = "CA"
#            elif ", IT" in activity["name"]:
#                activity["location"] = "IT"
#            elif ", TR" in activity["name"]:
#                activity["location"] = "TR"
#            elif "/GLO" in activity["name"]:
#                activity["location"] = "GLO"
#
#    # Getting products CIQUAL code when relevant
#    if "ciqual" in activity["name"].lower():
#        match = re.search(pattern=ciqual_pattern, string=activity["name"])
#        if match is not None:
#            activity["ciqual_code"] = match["ciqual"]
#
#    # Putting SimaPro metadata in the activity fields directly and removing references to SimaPro
#    if "simapro metadata" in activity:
#        for sp_field, value in activity["simapro metadata"].items():
#            if value != "Unspecified":
#                activity[sp_field] = value
#
#        # Getting the Data Quality Rating of the data when relevant
#        if "Comment" in activity["simapro metadata"]:
#            match = re.search(
#                pattern=dqr_pattern, string=activity["simapro metadata"]["Comment"]
#            )
#
#            if match:
#                activity["DQR"] = {
#                    "overall": float(match["overall"]),
#                    "P": float(match["P"]),
#                    "TiR": float(match["TiR"]),
#                    "GR": float(match["GR"]),
#                    "TeR": float(match["TeR"]),
#                }
#
#        del activity["simapro metadata"]
#
#    # Getting activity tags
#    name_without_spaces = activity["name"].replace(" ", "")
#    for packaging in packagings:
#        if f"|{packaging.replace(' ', '')}|" in name_without_spaces:
#            activity["packaging"] = packaging
#
#    for stage in stages:
#        if f"|{stage.replace(' ', '')}" in name_without_spaces:
#            activity["stage"] = stage
#
#    for transport_type in transport_types:
#        if f"|{transport_type.replace(' ', '')}|" in name_without_spaces:
#            activity["transport_type"] = transport_type
#
#    for preparation_mode in preparation_modes:
#        if f"|{preparation_mode.replace(' ', '')}|" in name_without_spaces:
#            activity["preparation_mode"] = preparation_mode
#
#    if "simapro name" in activity:
#        del activity["simapro name"]
#
#    if "filename" in activity:
#        del activity["filename"]

# deduplicate
dsdict = {ds["code"]: ds for ds in agb_importer.data}
agb_importer.data = list(dsdict.values())

# remove exchanges with no inputs (?!)
for ds in agb_importer.data:
    for i, e in enumerate(ds.get("exchanges", [])):
        if "input" not in e:
            del ds["exchanges"][i]

agb_importer.write_database()

# bw.BW2Package.export_objs(
#    [bw.Database(DATABASE + " biosphere"), bw.Database(DATABASE)],
#    filename=DATABASE,
#    folder=os.path.join(os.path.realpath(""), "data"),
# )
