import csv
import json
import os
import re
from datetime import datetime
from pathlib import Path

import yaml

from ecobalyse_data.logging import logger


def get_delimiter(data=None, filepath=None) -> str:
    sniffer = csv.Sniffer()
    if filepath:
        with open(filepath, "r", encoding="utf-8") as stream:
            data = stream.readline()
    delimiter = str(sniffer.sniff(data).delimiter)
    return delimiter


def reformat(value):
    if isinstance(value, (list, tuple)):
        return "::".join([reformat(x) for x in value])
    else:
        return value


def exchange_as_dict(exc):
    inp = exc.input
    inp_fields = ("name", "unit", "location", "categories")
    skip_fields = ()
    data = {k: v for k, v in exc._data.items() if k not in skip_fields}
    data.update(**{k: inp[k] for k in inp_fields if inp.get(k)})
    return data


def get_exchanges(act):
    exchanges = [exchange_as_dict(exc) for exc in act.exchanges()]
    exchanges.sort(key=lambda x: (x.get("type"), x.get("name")))
    return exchanges


def get_activity(act):
    data = act.as_dict()
    data["exchanges"] = get_exchanges(act)
    return data


def biosphere_flows_dictionary(version, biosphere_flows):
    """
    Create a dictionary with biosphere flows
    (name, category, sub-category, unit) -> code
    """
    fp = biosphere_flows.get(version)

    if not Path(fp).is_file():
        raise FileNotFoundError("The dictionary of biosphere flows could not be found.")

    csv_dict = {}

    with open(fp, encoding="utf-8") as file:
        input_dict = csv.reader(
            file,
            delimiter=get_delimiter(filepath=fp),
        )
        for row in input_dict:
            csv_dict[(row[0], row[1], row[2], row[3])] = row[-1]

    return csv_dict


def replace_unsupported_characters(text):
    if text:
        if isinstance(text, str):
            return (
                text.encode("cp1252", errors="replace")
                .decode("cp1252")
                # Replace newline comments by the separator used in Simapro
                .replace("\n", "\x7f")
            )
        else:
            return text
    else:
        return ""


def get_uuids(db):
    uuids = {}

    for ds in db:
        uuids[ds["name"]] = ds["code"]

    return uuids


def get_simapro_biosphere_dictionnary(filepath):
    """
    Load a dictionary with biosphere flows to use for Simapro export.
    """
    # Load the matching dictionary between ecoinvent and Simapro biosphere flows
    if not os.path.isfile(filepath):
        raise FileNotFoundError(
            "The dictionary of biosphere flow match between ecoinvent "
            "and Simapro could not be found."
        )
    with open(filepath, encoding="utf-8") as json_file:
        data = json.load(json_file)
    dict_bio = {}
    for row in data:
        dict_bio[row[2]] = row[1]

    return dict_bio


def get_simapro_category_of_exchange(filepath):
    """Load a dictionary with categories to use for Simapro export based on ei 3.7"""

    # Load the matching dictionary
    if not os.path.isfile(filepath):
        raise FileNotFoundError(
            "The dictionary of Simapro categories could not be found."
        )
    with open(
        filepath,
        encoding="cp1252",
    ) as file:
        csv_reader = csv.DictReader(file)

        dict_cat = {}
        # first row are headers
        for row in csv_reader:
            dict_cat[(row["name"].lower(), row["product"].lower())] = dict(row)

    return dict_cat


def load_references(filepath):
    """Load a dictionary with references of datasets"""

    # Load the matching dictionary
    if not os.path.isfile(filepath):
        raise FileNotFoundError("The dictionary of references could not be found.")
    with open(filepath, encoding="utf-8") as file:
        csv_list = [[val.strip() for val in r.split(";")] for r in file.readlines()]
    _, *data = csv_list

    dict_reference = {}
    for row in data:
        name, source, description = row
        dict_reference[name] = {"source": source, "description": description}

    return dict_reference


def export_db_to_simapro(
    db,
    filepath,
    simapro_units_path,
    simapro_compartments_path,
    simapro_biosphere_path,
    simapro_categories_path,
    references_path,
    biosphere_flows,
    olca_compartments=False,
):
    dict_bio = get_simapro_biosphere_dictionnary(simapro_biosphere_path)

    uuids = get_uuids(db)

    headers = [
        "{SimaPro 9.1.1.7}",
        "{processes}",
        "{Project: ecobalyse export" + f"{datetime.today():%d.%m.%Y}" + "}",
        "{CSV Format version: 9.0.0}",
        "{CSV separator: Semicolon}",
        "{Decimal separator: .}",
        "{Date separator: .}",
        "{Short date format: dd.MM.yyyy}",
        "{Export platform IDs: No}",
        "{Skip empty fields: No}",
        "{Convert expressions to constants: No}",
        "{Related objects(system descriptions, substances, units, etc.): Yes}",
        "{Include sub product stages and processes: Yes}",
    ]

    fields = [
        "Process",
        "Category type",
        "Type",
        "Process name",
        "Time Period",
        "Geography",
        "Technology",
        "Representativeness",
        "Waste treatment allocation",
        "Cut off rules",
        "Capital goods",
        "Date",
        "Boundary with nature",
        "Infrastructure",
        "Record",
        "Generator",
        "Literature references",
        "External documents",
        "Comment",
        "Collection method",
        "Data treatment",
        "Verification",
        "System description",
        "Allocation rules",
        "Products",
        "Waste treatment",
        "Materials/fuels",
        "Resources",
        "Emissions to air",
        "Emissions to water",
        "Emissions to soil",
        "Non material emission",
        "Social issues",
        "Economic issues",
        "Waste to treatment",
        "End",
    ]

    # mapping between BW2 and Simapro units
    simapro_units = None
    with open(simapro_units_path, "r", encoding="utf-8") as fp:
        simapro_units = yaml.safe_load(fp)

    # mapping between BW2 and Simapro sub-compartments
    simapro_subs = {}
    if not olca_compartments:
        with open(simapro_compartments_path, "r", encoding="utf-8") as fp:
            simapro_subs = yaml.safe_load(fp)

    dict_cat_simapro = get_simapro_category_of_exchange(simapro_categories_path)
    dict_refs = load_references(references_path)

    unlinked_biosphere_flows = []
    unmatched_category_flows = []

    bio_dict = biosphere_flows_dictionary("3.9", biosphere_flows)

    data_as_dict = []
    with open(filepath, "w", newline="", encoding="cp1252") as csvFile:
        writer = csv.writer(csvFile, delimiter=";")
        for item in headers:
            writer.writerow([item])
        writer.writerow([])

        for ds in db:
            ds = get_activity(ds)
            data_as_dict.append(ds)
            if "reference product" in ds and "product" not in ds:
                ds["product"] = ds["reference product"]

            try:
                main_category, sub_category = (
                    dict_cat_simapro[
                        (ds["name"].lower(), ds["reference product"].lower())
                    ]["category"],
                    dict_cat_simapro[
                        (ds["name"].lower(), ds["reference product"].lower())
                    ]["sub_category"],
                )
            except KeyError:
                main_category, sub_category = ("material", "Others\\Transformation")
                unmatched_category_flows.append(
                    (ds["name"], ds.get("reference product"))
                )

            for item in fields:
                if main_category.lower() == "waste treatment" and item == "Products":
                    continue

                if main_category.lower() != "waste treatment" and item in (
                    "Waste treatment",
                    "Waste treatment allocation",
                ):
                    continue

                writer.writerow([item])

                if item == "Process name":
                    name = ds["name"]

                    writer.writerow([name])

                if item == "Type":
                    writer.writerow(["Unit process"])

                if item == "Category type":
                    writer.writerow([main_category])

                if item == "Generator":
                    writer.writerow(["Ecobalyse export"])

                if item == "Geography":
                    writer.writerow([ds.get("location", "Unspecified")])

                if item == "Date":
                    writer.writerow([f"{datetime.today():%d.%m.%Y}"])

                if item == "Comment":
                    string = ""
                    if ds["name"] in dict_refs:
                        string = re.sub(
                            "[^a-zA-Z0-9 .,]", "", dict_refs[ds["name"]]["source"]
                        )

                        if dict_refs[ds["name"]]["description"] != "":
                            string += " " + re.sub(
                                "[^a-zA-Z0-9 .,]",
                                "",
                                dict_refs[ds["name"]]["description"],
                            )

                    else:
                        if "comment" in ds:
                            string = re.sub("[^a-zA-Z0-9 .,]", "", ds["comment"])

                    # Add dataset UUID to comment filed
                    string += f" | ID: {ds['code']}"

                    writer.writerow([string])

                if item in (
                    "Cut off rules",
                    "Capital goods",
                    "Technology",
                    "Representativeness",
                    "Waste treatment allocation",
                    "Boundary with nature",
                    "Allocation rules",
                    "Collection method",
                    "Verification",
                    "Time Period",
                    "Record",
                ):
                    writer.writerow(["Unspecified"])
                if item == "System description":
                    writer.writerow(["Ecoinvent v3"])
                if item == "Infrastructure":
                    writer.writerow(["No"])
                if item == "External documents":
                    writer.writerow(["https://ecobalyse.beta.gouv.fr/"])
                if item in ("Waste treatment", "Products"):
                    for e in ds["exchanges"]:
                        if e["type"] == "production":
                            name = e["name"]

                            if item == "Waste treatment":
                                writer.writerow(
                                    [
                                        name,
                                        simapro_units[e["unit"]],
                                        1.0,
                                        "not defined",
                                        sub_category,
                                        f"{replace_unsupported_characters(e.get('comment'))} | ID = {uuids.get((e['name']))}",
                                    ]
                                )

                            else:
                                writer.writerow(
                                    [
                                        name,
                                        simapro_units[e["unit"]],
                                        1.0,
                                        "100%",
                                        "not defined",
                                        sub_category,
                                        f"{replace_unsupported_characters(e.get('comment'))} | ID = {uuids.get((e['name']))}",
                                    ]
                                )
                            e["used"] = True
                if item == "Materials/fuels":
                    for e in ds["exchanges"]:
                        if e["type"] == "technosphere":
                            key = (e["name"].lower(), e.get("product", "").lower())
                            if key in dict_cat_simapro:
                                exc_cat = dict_cat_simapro.get(key)["category"]
                            else:
                                exc_cat = "material"

                            if exc_cat != "waste treatment":
                                name = e["name"]

                                writer.writerow(
                                    [
                                        name,
                                        simapro_units[e["unit"]],
                                        f"{e['amount']:.3E}",
                                        "undefined",
                                        0,
                                        0,
                                        0,
                                        f"{replace_unsupported_characters(e.get('comment'))} | ID = {uuids.get((e['name']))}",
                                    ]
                                )
                                e["used"] = True
                if item == "Resources":
                    for e in ds["exchanges"]:
                        if (
                            e["type"] == "biosphere"
                            and e["categories"][0] == "natural resource"
                        ):
                            if e["name"] not in dict_bio:
                                unlinked_biosphere_flows.append(
                                    [e["name"], " - ", e["categories"][0]]
                                )

                            sub_compartment = ""
                            if len(e["categories"]) > 1:
                                if e["categories"][1] != "fossil well":
                                    sub_compartment = simapro_subs.get(
                                        e["categories"][1], e["categories"][1]
                                    )

                            writer.writerow(
                                [
                                    dict_bio.get(e["name"], e["name"]),
                                    sub_compartment,
                                    simapro_units[e["unit"]],
                                    f"{e['amount']:.3E}",
                                    "undefined",
                                    0,
                                    0,
                                    0,
                                    f"{replace_unsupported_characters(e.get('comment'))} | ID = {bio_dict.get((e['name'], e['categories'][0], 'unspecified' if len(e['categories']) == 1 else e['categories'][1], e['unit']))}",
                                ]
                            )
                            e["used"] = True
                if item == "Emissions to air":
                    for e in ds["exchanges"]:
                        if e["type"] == "biosphere" and e["categories"][0] == "air":
                            if len(e["categories"]) > 1:
                                sub_compartment = simapro_subs.get(
                                    e["categories"][1], e["categories"][1]
                                )
                            else:
                                sub_compartment = ""

                            if e["name"].lower() == "water":
                                unit = "kilogram"
                                # e["unit"] = "kilogram"
                                # going from cubic meters to kilograms
                                e["amount"] *= 1000
                            else:
                                unit = e["unit"]

                            if e["name"] not in dict_bio:
                                unlinked_biosphere_flows.append(
                                    [e["name"], " - ", e["categories"][0]]
                                )

                            writer.writerow(
                                [
                                    dict_bio.get(e["name"], e["name"]),
                                    sub_compartment,
                                    simapro_units[unit],
                                    f"{e['amount']:.3E}",
                                    "undefined",
                                    0,
                                    0,
                                    0,
                                    f"{replace_unsupported_characters(e.get('comment'))} | ID = {bio_dict.get((e['name'], e['categories'][0], 'unspecified' if len(e['categories']) == 1 else e['categories'][1], e['unit']))}",
                                ]
                            )
                            e["used"] = True
                if item == "Emissions to water":
                    for e in ds["exchanges"]:
                        if e["type"] == "biosphere" and e["categories"][0] == "water":
                            if len(e["categories"]) > 1:
                                sub_compartment = simapro_subs.get(
                                    e["categories"][1], e["categories"][1]
                                )
                            else:
                                sub_compartment = ""

                            if e["name"].lower() == "water":
                                unit = "kilogram"
                                # e["unit"] = "kilogram"
                                e["amount"] *= 1000
                            else:
                                unit = e["unit"]

                            if e["name"] not in dict_bio:
                                unlinked_biosphere_flows.append(
                                    [e["name"], " - ", e["categories"][0]]
                                )

                            writer.writerow(
                                [
                                    dict_bio.get(e["name"], e["name"]),
                                    sub_compartment,
                                    simapro_units[unit],
                                    f"{e['amount']:.3E}",
                                    "undefined",
                                    0,
                                    0,
                                    0,
                                    f"{replace_unsupported_characters(e.get('comment'))} | ID = {bio_dict.get((e['name'], e['categories'][0], 'unspecified' if len(e['categories']) == 1 else e['categories'][1], e['unit']))}",
                                ]
                            )
                            e["used"] = True
                if item == "Emissions to soil":
                    for e in ds["exchanges"]:
                        if e["type"] == "biosphere" and e["categories"][0] == "soil":
                            if len(e["categories"]) > 1:
                                sub_compartment = simapro_subs.get(
                                    e["categories"][1], e["categories"][1]
                                )
                            else:
                                sub_compartment = ""

                            if e["name"] not in dict_bio:
                                unlinked_biosphere_flows.append(
                                    [e["name"], " - ", e["categories"][0]]
                                )

                            writer.writerow(
                                [
                                    dict_bio.get(e["name"], e["name"]),
                                    sub_compartment,
                                    simapro_units[e["unit"]],
                                    f"{e['amount']:.3E}",
                                    "undefined",
                                    0,
                                    0,
                                    0,
                                    f"{replace_unsupported_characters(e.get('comment'))} | ID = {bio_dict.get((e['name'], e['categories'][0], 'unspecified' if len(e['categories']) == 1 else e['categories'][1], e['unit']))}",
                                ]
                            )
                            e["used"] = True
                if item == "Waste to treatment":
                    for e in ds["exchanges"]:
                        if e["type"] == "technosphere":
                            key = (e["name"].lower(), e.get("product", "").lower())
                            if key in dict_cat_simapro:
                                exc_cat = dict_cat_simapro.get(key)["category"]
                            else:
                                exc_cat = "material"

                            if exc_cat == "waste treatment":
                                name = e["name"]

                                writer.writerow(
                                    [
                                        name,
                                        simapro_units[e["unit"]],
                                        f"{e['amount'] * -1:.3E}",
                                        "undefined",
                                        0,
                                        0,
                                        0,
                                        f"{replace_unsupported_characters(e.get('comment'))} | ID = {uuids[(e['name'])]}",
                                    ]
                                )
                                e["used"] = True

                writer.writerow([])

        # System description
        writer.writerow(["System description"])
        writer.writerow([])
        writer.writerow(["Name"])
        writer.writerow(["Ecoinvent v3"])
        writer.writerow([])
        writer.writerow(["Category"])
        writer.writerow(["Others"])
        writer.writerow([])
        writer.writerow(["Description"])
        writer.writerow([""])
        writer.writerow([])
        writer.writerow(["Cut-off rules"])
        writer.writerow([""])
        writer.writerow([])
        writer.writerow(["Energy model"])
        writer.writerow([])
        writer.writerow([])
        writer.writerow(["Transport model"])
        writer.writerow([])
        writer.writerow([])
        writer.writerow(["Allocation rules"])
        writer.writerow([])
        writer.writerow(["End"])
        writer.writerow([])

    csvFile.close()

    # check that all exchanges have been used
    unused_exchanges = []
    for ds in data_as_dict:
        for e in ds["exchanges"]:
            if "used" not in e:
                if [
                    e["name"][:40],
                    e.get("product", "")[:40],
                    e.get("categories"),
                    e.get("location"),
                ] not in unused_exchanges:
                    unused_exchanges.append(
                        [
                            e["name"][:40],
                            e.get("product", "")[:40],
                            e.get("categories"),
                            e.get("location"),
                        ]
                    )

    if len(unused_exchanges) > 0:
        logger.warning(
            "The following exchanges have not been used in the Simapro export:"
        )
        for i in unused_exchanges:
            logger.warning(i)

    if len(unmatched_category_flows) > 0:
        logger.warning(
            f"{len(unmatched_category_flows)} unmatched flow categories. Check unlinked.log."
        )
        # save the list of unmatched flow to unlinked.log
        with open("unlinked.log", "a") as f:
            for item in unmatched_category_flows:
                f.write(f"{item}\n")

    logger.info(f"Simapro CSV file saved in '{filepath}'")
