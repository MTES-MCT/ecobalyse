"""
EcoSpold 1 Exporter for Brightway2 databases.

Exports Brightway2 datasets to EcoSpold 1 XML format compatible with SimaPro.
"""

from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Union

import numpy as np
from lxml import etree
from stats_arrays.distributions import (
    LognormalUncertainty,
    NormalUncertainty,
    NoUncertainty,
    TriangularUncertainty,
    UndefinedUncertainty,
    UniformUncertainty,
)

from ecobalyse_data.logging import logger

# XML namespace configuration
attr_qname = etree.QName("http://www.w3.org/2001/XMLSchema-instance", "schemaLocation")
nsmap = {
    None: "http://www.EcoInvent.org/EcoSpold01",
    "xsi": "http://www.w3.org/2001/XMLSchema-instance",
}

# Unit mapping for SimaPro compatibility
UNITS = {
    "year": "a",
    "Becquerel": "Bq",
    "gram": "g",
    "gigajoule": "GJ",
    "hour": "h",
    "hectare": "ha",
    "kilo Becquerel": "kBq",
    "kilogram": "kg",
    "kilogram kilometer": "kgkm",
    "kilogram day": "kg*day",
    "kilometer": "km",
    "kilojoule": "kJ",
    "kilowatt hour": "kWh",
    "litre": "l",
    "livestock unit": "LU",
    "meter": "m",
    "meter-year": "m*a",
    "square meter": "m2",
    "square meter-year": "m2a",
    "cubic meter": "m3",
    "cubic meter-year": "m3a",
    "ton kilometer": "tkm",
    "megajoule": "MJ",
    "normal cubic meter": "Nm3",
    "standard cubic meter": "Sm3",
    "person kilometer": "pkm",
    "ton": "t",
    "vehicle kilometer": "vkm",
    "kilogram separative work unit": "kg SWU",
    "kilometer-year": "km*a",
    "watt hour": "Wh",
    "unit": "p",
    "piece": "p",
}

# Location mapping for EcoSpold (max 7 chars)
LOCATIONS = {
    "Europe without Switzerland": "RER",
}


def bool_to_text(b: Union[bool, str, None]) -> str:
    """Convert a boolean-like value to 'true' or 'false' string."""
    if b in (True, "yes", "Yes", "true", "True"):
        return "true"
    elif b in (False, None, "", "False", "false", "No", "no"):
        return "false"
    else:
        raise ValueError(f"Can't convert {b} to boolean string")


def stripper(obj: str, prefix: str) -> str:
    """Strip a prefix from a string if present."""
    if obj and obj.startswith(prefix):
        return obj[len(prefix) :]
    else:
        return obj or ""


def pretty_number(val: float) -> str:
    """Format a number nicely for XML output."""
    if 1e-2 < abs(val) < 1e2:
        return np.format_float_positional(val, precision=6, trim="0")
    else:
        return np.format_float_scientific(val, precision=6, trim="0")


class Ecospold1Exporter:
    """Export one or more datasets to Ecospold1 XML."""

    def __init__(self, schema_location: Union[str, None] = None):
        self.root = etree.Element(
            "ecoSpold",
            {
                attr_qname: schema_location
                or "https://raw.githubusercontent.com/sami-m-g/pyecospold/main/pyecospold/schemas/v1/EcoSpold01Dataset.xsd"
            },
            nsmap=nsmap,
        )
        self.count = 0

    def add_dataset(self, node: Dict[str, Any], key_to_dsnum=None) -> None:
        self.count += 1
        tags = dict(node.get("tags", []))
        # Normalize timestamp without microseconds (friendlier to some parsers)
        timestamp = tags.get(
            "ecoSpold01timestamp",
            datetime.now().replace(microsecond=0).isoformat(),
        )

        dataset = etree.SubElement(
            self.root,
            "dataset",
            attrib={
                "validCompanyCodes": "CompanyCodes.xml",
                "validRegionalCodes": "RegionalCodes.xml",
                "validCategories": "Categories.xml",
                "validUnits": "Units.xml",
                "number": str(self.count),
                "timestamp": timestamp,
                "generator": "bw2io",
            },
        )
        meta_information = etree.SubElement(dataset, "metaInformation")

        category = tags.get("ecoSpold01category", node.get("category"))
        subcategory = tags.get(
            "ecoSpold01subCategory", node.get("subcategory", category)
        )
        comments = node.get("comments", {}) or {}

        process_information = etree.SubElement(meta_information, "processInformation")

        ref_attrs = {
            "datasetRelatesToProduct": bool_to_text(
                tags.get("ecoSpold01datasetRelatesToProduct", True)
            ),
            "name": node["name"],
            "localName": tags.get("ecoSpold01localName", node["name"]),
            "infrastructureProcess": bool_to_text(
                tags.get("ecoSpold01infrastructureProcess")
            ),
            "amount": "1.0",
            "unit": UNITS.get(u := node["unit"], u),
            "includedProcesses": comments.get("includedProcesses", ""),
            "generalComment": comments.get("generalComment", ""),
            "infrastructureIncluded": bool_to_text(
                tags.get("ecoSpold01infrastructureIncluded")
            ),
        }

        # Only include categories if not explicitly omitted AND you have values
        if not tags.get("ecoSpold01omitCategories", False) and category and subcategory:
            ref_attrs.update(
                {
                    "category": category,
                    "subCategory": subcategory,
                    "localCategory": node.get("localCategory", category),
                    "localSubCategory": node.get("localSubCategory", subcategory),
                }
            )

        etree.SubElement(process_information, "referenceFunction", attrib=ref_attrs)

        raw_loc = (
            tags.get("ecoSpold01geographyLocation") or node.get("location") or "GLO"
        )
        geo_loc = LOCATIONS.get(raw_loc, raw_loc)
        geo_text = (
            tags.get("ecoSpold01geographyText")
            or stripper(comments.get("location", ""), "Location: ")
            or "Unspecified"
        )
        etree.SubElement(
            process_information,
            "geography",
            attrib={"location": geo_loc, "text": geo_text},
        )
        etree.SubElement(
            process_information,
            "technology",
            attrib={"text": stripper(comments.get("technology", ""), "Technology: ")},
        )
        data_valid_entire = tags.get("ecoSpold01dataValidForEntirePeriod", "")
        time_period = etree.SubElement(
            process_information,
            "timePeriod",
            attrib={
                "text": stripper(comments.get("timePeriod", ""), "Time period: ")
                or "Unspecified",
                "dataValidForEntirePeriod": str(data_valid_entire),
            },
        )
        start = etree.SubElement(time_period, "startDate")
        start.text = tags.get("ecoSpold01startDate", "1900-01-01")
        end = etree.SubElement(time_period, "endDate")
        end.text = tags.get("ecoSpold01endDate", "1900-01-01")

        etree.SubElement(
            process_information,
            "dataSetInformation",
            attrib={
                "type": str(tags.get("ecoSpold01type", "1")),
                "impactAssessmentResult": bool_to_text(
                    tags.get("ecoSpold01impactAssessmentResult")
                ),
                "timestamp": timestamp,
                "version": tags.get("ecoSpold01version", "0.00"),
                "internalVersion": tags.get("ecoSpold01internalVersion", "0.0"),
                "energyValues": str(tags.get("ecoSpold01energyValues", "0")),
                "languageCode": tags.get("ecoSpold01languageCode", "en"),
                "localLanguageCode": tags.get("ecoSpold01localLanguageCode", "de"),
            },
        )

        m_and_v = etree.SubElement(meta_information, "modellingAndValidation")
        etree.SubElement(
            m_and_v,
            "representativeness",
            attrib={
                "productionVolume": stripper(
                    comments.get("productionVolume", "unknown"), "Production volume: "
                ),
                "samplingProcedure": stripper(
                    comments.get("sampling", "unknown"), "Sampling: "
                ),
                "extrapolations": stripper(
                    comments.get("extrapolations", "unknown"), "Extrapolations: "
                ),
                "uncertaintyAdjustments": stripper(
                    comments.get("uncertaintyAdjustments", "unknown"),
                    "Uncertainty adjustments: ",
                ),
            },
        )

        SOURCE_MAP: Dict[str, str] = {
            "Undefined (default)": "0",
            "Article": "1",
            "Chapters in anthology": "2",
            "Seperate publication": "3",
            "Measurement on site": "4",
            "Oral communication": "5",
            "Personal written communication": "6",
            "Questionnaries": "7",
        }

        SOURCE_FIELDS = {
            "nameOfEditors": "editors",
            "pageNumbers": "pages",
            "year": "year",
            "title": "title",
            "titleOfAnthology": "anthology",
            "placeOfPublications": "place_of_publication",
            "publisher": "publisher",
            "journal": "journal",
            "volumeNo": "volume",
            "issueNo": "issue",
            "text": "text",
        }

        # Build sources; keep track of numbers we used
        sources: List[Dict[str, Any]] = node.get("references", []) or []
        for index, source in enumerate(sources):
            authors = source.get("authors", []) or [""]
            first_author = authors[0] if authors else ""
            additional_authors = "; ".join(authors[1:]) if len(authors) > 1 else ""
            etree.SubElement(
                m_and_v,
                "source",
                attrib={
                    "number": str(source.get("identifier", index + 1)),
                    "sourceType": SOURCE_MAP.get(source.get("type"), "0"),
                    "firstAuthor": first_author,
                    "additionalAuthors": additional_authors,
                }
                | {
                    k: str(source.get(v))
                    for k, v in SOURCE_FIELDS.items()
                    if source.get(v) is not None
                },
            )

        admin = etree.SubElement(meta_information, "administrativeInformation")

        # Use a safe, local value (don't rely on loop variables that may not exist)
        data_entry_number = str(
            node.get("authors", {}).get("data_entry", {}).get("identifier", 1)
        )
        etree.SubElement(
            admin,
            "dataEntryBy",
            attrib={
                "person": data_entry_number,
                "qualityNetwork": "1",
            },
        )

        etree.SubElement(
            admin,
            "dataGeneratorAndPublication",
            attrib={
                "person": data_entry_number,
                "dataPublishedIn": "1",
                "referenceToPublishedSource": "1",
                "accessRestrictedTo": "0",
                "copyright": "true",
            },
        )

        PERSON_FIELDS = [
            ("identifier", "number", "1"),
            ("address", "address", "Unknown"),
            ("company", "companyCode", "Unknown"),
            ("country", "countryCode", "FR"),  # Default to France for Ecobalyse
            ("email", "email", "unknown@example.com"),
            ("name", "name", "Unknown"),
        ]

        people = node.get("authors", {}).get("people", []) or []
        # Schema requires at least one person element
        if not people:
            people = [{"identifier": 1, "name": "Unknown"}]

        for person in people:
            etree.SubElement(
                admin,
                "person",
                attrib={b: str(person.get(a, c)) for a, b, c in PERSON_FIELDS},
            )

        RESOURCES = {
            "natural resource",
            "natural resources",
            "resource",
            "resources",
            "raw",
        }

        UNCERTAINTY_MAPPING = {
            None: "0",
            NoUncertainty.id: "0",
            UndefinedUncertainty.id: "0",
            LognormalUncertainty.id: "1",
            TriangularUncertainty.id: "3",
            UniformUncertainty.id: "4",
        }

        EXCHANGE_FIELDS = {
            "generalComment": "comment",
            "CASNumber": "CAS number",
            "location": "location",
            "formula": "chemical formula",
            "referenceToSource": "source_reference",
            "pageNumbers": "pages",
        }

        flow_data = etree.SubElement(dataset, "flowData")

        # Reference product exchange (outputGroup=0, number=0)
        ref_unit = UNITS.get(u := node["unit"], u)
        ref_exc = etree.SubElement(
            flow_data,
            "exchange",
            attrib={
                "number": "0",
                "name": node["name"],
                "unit": ref_unit,
                "meanValue": pretty_number(node.get("production amount", 1.0)),
                "infrastructureProcess": bool_to_text(False),
                "uncertaintyType": "0",
            },
        )
        etree.SubElement(ref_exc, "outputGroup").text = "0"

        exc_number = 0
        for exc in node.get("exchanges", []) or []:
            if exc["type"] == "production":
                continue  # already emitted as reference product above
            exc_number += 1
            # For technosphere inputs, use supplier's dataset number
            if exc.get("type") == "technosphere" and key_to_dsnum:
                number = str(key_to_dsnum.get(exc.get("input_key"), 0))
            else:
                number = str(exc_number)
            cats = exc.get("categories") or []
            attrs = {
                "number": number,
                "unit": UNITS.get(u := str(exc.get("unit", "")), u),
                "name": exc.get("name", ""),
                "meanValue": pretty_number(exc["amount"]),
                "infrastructureProcess": bool_to_text(exc.get("infrastructureProcess")),
            } | {
                k: exc.get(v)
                for k, v in EXCHANGE_FIELDS.items()
                if exc.get(v) is not None
            }

            # Always include uncertaintyType; default to 0 (none)
            utype = exc.get("uncertainty type")
            attrs["uncertaintyType"] = UNCERTAINTY_MAPPING.get(utype, "0")

            if cats and cats[0]:
                attrs["category"] = cats[0]
            if len(cats) > 1 and cats[1]:
                attrs["subCategory"] = cats[1]

            # 95% standard deviation where applicable (preserve zeros)
            if utype == LognormalUncertainty.id and exc.get("scale") is not None:
                attrs["standardDeviation95"] = pretty_number(np.exp(exc["scale"]) ** 2)
            elif utype == NormalUncertainty.id and exc.get("scale") is not None:
                attrs["standardDeviation95"] = pretty_number(exc["scale"] * 2)

            # Preserve zero min/max
            if exc.get("minimum") is not None:
                attrs["minValue"] = pretty_number(exc["minimum"])
            if exc.get("maximum") is not None:
                attrs["maxValue"] = pretty_number(exc["maximum"])

            exc_element = etree.SubElement(flow_data, "exchange", attrib=attrs)

            # Group mapping with safe biosphere branch
            etype = exc["type"]
            if etype == "technosphere":
                etree.SubElement(exc_element, "inputGroup").text = "5"
            elif etype == "substitution":
                etree.SubElement(exc_element, "outputGroup").text = "1"
            elif etype == "biosphere":
                is_resource = bool(cats and cats[0] and cats[0].lower() in RESOURCES)
                if is_resource:
                    etree.SubElement(exc_element, "inputGroup").text = "4"
                else:
                    etree.SubElement(exc_element, "outputGroup").text = "4"
            else:
                raise ValueError(f"Can't map exchange type {etype}")

    @property
    def bytes(self) -> bytes:
        return etree.tostring(
            self.root, encoding="utf-8", xml_declaration=True, pretty_print=True
        )

    def __repr__(self) -> str:
        return self.bytes.decode("utf-8")

    def write_to_file(self, filepath: Path) -> None:
        with open(filepath, "wb") as f:
            f.write(self.bytes)


def _simapro_geography_name(ds):
    """Builds a SimaPro-like '[LOC] short process name' string."""
    loc = ds.get("location", "GLO")
    name = ds.get("name", "")
    short = name
    if "|" in name:
        parts = [p.strip() for p in name.split("|")]
        if len(parts) >= 2:
            short = parts[1]
    short = short.replace("{%s}" % loc, "").strip()
    return f"[{loc}] {short}"


def _prepare_dataset(activity):
    """Prepare a Brightway activity dict for EcoSpold 1 export."""
    ds = activity.as_dict()

    # Fetch exchanges (not included in as_dict())
    ds["exchanges"] = []
    for exc in activity.exchanges():
        exc_data = exc.as_dict()
        exc_data["type"] = exc["type"]
        exc_data["amount"] = exc["amount"]
        exc_data["unit"] = exc.get("unit", exc.input.get("unit", ""))
        exc_data["name"] = exc.input.get("name", "")
        exc_data["categories"] = exc.input.get("categories", [])
        if exc["type"] == "technosphere":
            exc_data["input_key"] = exc["input"]
        ds["exchanges"].append(exc_data)

    # Add production exchange if missing (required for reference product output)
    has_production = any(exc.get("type") == "production" for exc in ds["exchanges"])
    if not has_production:
        ds["exchanges"].insert(
            0,
            {
                "type": "production",
                "amount": ds.get("production amount", 1.0),
                "unit": ds.get("unit", "kilogram"),
                "name": ds.get("name", ""),
                "categories": [],
            },
        )

    # Skip datasets without exchanges (EcoSpold schema requires at least one)
    if not ds["exchanges"]:
        logger.warning(f"Skipping '{ds['name']}' (no exchanges)")
        return None

    # Patch category fields to SimaPro-ish buckets
    if isinstance(ds.get("tags"), list):
        ds["tags"] = dict(ds["tags"])
    ds.setdefault("tags", {})
    ds["tags"]["ecoSpold01category"] = "Others"
    ds["tags"]["ecoSpold01subCategory"] = "Carbon content biogenic materials"

    ds["category"] = ds["tags"]["ecoSpold01category"]
    ds["localCategory"] = ds["tags"]["ecoSpold01category"]
    ds["localSubCategory"] = ds["tags"]["ecoSpold01subCategory"]

    # Geography
    ds["tags"]["ecoSpold01geographyLocation"] = ds.get("location", "GLO")
    ds["tags"]["ecoSpold01geographyText"] = _simapro_geography_name(ds)

    # Time period defaults like SimaPro sample
    ds["tags"]["ecoSpold01dataValidForEntirePeriod"] = "true"
    ds["tags"]["ecoSpold01startDate"] = "1900-01-01"
    ds["tags"]["ecoSpold01endDate"] = "1900-01-01"

    # Dataset info defaults to align formatting
    ds["tags"]["ecoSpold01version"] = "0.00"
    ds["tags"]["ecoSpold01internalVersion"] = "0.0"
    ds["tags"]["ecoSpold01languageCode"] = "en"
    ds["tags"]["ecoSpold01localLanguageCode"] = "de"

    # Provide a minimal default source (SimaPro file has one)
    if not ds.get("references"):
        ds["references"] = [
            {
                "identifier": 1,
                "type": "Undefined (default)",
                "authors": ["SimaPro"],
                "year": 2025,
                "title": "Dummy",
                "place_of_publication": "Unspecified",
            }
        ]

    return ds


def export_db_to_ecospold(activities, filepath):
    """Export an iterable of Brightway activities to a single EcoSpold 1 XML file."""
    exporter = Ecospold1Exporter()

    # First pass: prepare datasets and assign dataset numbers
    prepared = []
    key_to_dsnum = {}
    for activity in activities:
        ds = _prepare_dataset(activity)
        if ds is not None:
            exporter.count += 1
            key_to_dsnum[activity.key] = exporter.count
            prepared.append(ds)

    # Second pass: write with correct supplier references
    exporter.count = 0
    for ds in prepared:
        exporter.add_dataset(ds, key_to_dsnum)

    exporter.write_to_file(filepath)
    logger.info(f"Exported {exporter.count} datasets to '{filepath}'")
