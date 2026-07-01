#!/usr/bin/env python3
import functools
import tempfile
from zipfile import ZipFile

import bw2data
import bw2io
from bw2io.strategies import (
    # drop_unlinked_cfs,
    drop_unspecified_subcategories,
    link_iterable_by_fields,
    match_subcategories,
    normalize_biosphere_categories,
    normalize_biosphere_names,
    normalize_simapro_biosphere_categories,
    normalize_simapro_biosphere_names,
    normalize_units,
    set_biosphere_type,
)
from frozendict import frozendict

from common import brightway_patch as brightway_patch
from common.impacts import impacts
from common.import_ import setup_project
from config import settings
from ecobalyse_data import s3
from ecobalyse_data.bw.strategy import noLT, uraniumFRU
from ecobalyse_data.logging import logger

# Agribalyse 3.2, Ginko, WFLDB and Ecoinvent 3.9.1 carry the legacy SimaPro flow
# names. EF 3.1 1.03 renamed a number of substances (keeping the same CAS) to newer
# names, so the new method stopped characterizing the legacy-named biosphere flows: their
# impact (ozone depletion, freshwater ecotoxicity) would be silently undercounted on
# those databases. We re-characterize each legacy flow with its modern synonym's
# factor, so the substance is counted whatever naming vintage a source database uses.
#
# Mapping is modern name -> legacy name (as it appears in biosphere3).
# Every entry must be a clean rename, i.e. the legacy name must
# be absent from the 1.03 method; add_legacy_flow_synonyms only fills that gap and never
# overrides a factor the method already defines (which would double-count).
METHOD_FLOW_SYNONYMS = {
    # Ozone depletion (emissions to air)
    "Bromomethane": "Methane, bromo-, Halon 1001",
    "Bromotrifluoromethane": "Methane, bromotrifluoro-, Halon 1301",
    "Bromochlorodifluoromethane": "Methane, bromochlorodifluoro-, Halon 1211",
    "1,1,1-Trichloroethane": "Ethane, 1,1,1-trichloro-, HCFC-140",
    # Freshwater ecotoxicity (pesticides, emissions to soil/water/air)
    "Quizalofop-ethyl": "Quizalofop ethyl ester",
    "Pyrethrins": "Pyrethrum",
    "Pyrethrin II": "Pyrethrin",
    "Flupyrsulfuron-methyl sodium": "Flupyrsulfuron-methyl",
    "Flurochloridone": "Fluorochloridone",
    # Human toxicity, non-cancer: Mecoprop-P keeps its ecotoxicity factor in 1.03 but
    # lost its human-toxicity one, so the gap-filling guard re-adds it only there.
    "Mecoprop": "Mecoprop-P",
}


def add_legacy_flow_synonyms(db):
    """Re-characterize each legacy-named biosphere flow with its modern synonym's
    factor (see METHOD_FLOW_SYNONYMS). Only fills gaps: a legacy name the 1.03 method
    already characterizes is left untouched, so no factor is ever double-counted."""
    for method in db:
        present = {(cf["name"], cf.get("categories")) for cf in method["exchanges"]}
        method["exchanges"].extend(
            {**cf, "name": METHOD_FLOW_SYNONYMS[cf["name"]]}
            for cf in list(method["exchanges"])
            if cf.get("name") in METHOD_FLOW_SYNONYMS
            and (METHOD_FLOW_SYNONYMS[cf["name"]], cf.get("categories")) not in present
        )
    return db


# EF 3.1 depletes minerals per element (ADP, ultimate reserve), but Ecoinvent/WFLDB emit
# ore-grade-specific resource flows ("Gold, Au 9.7E-4%, in mixed ore, in ground", …). The
# 1.03 method lists only a subset of those name variants, so most Copper/Gold/Silver grades
# lost their factor and mru is silently undercounted on those databases. Every grade of an
# element carries the same per-element factor, so we broadcast it to all of them.
MRU_CATEGORY = impacts["mru"][1]
# A few flows use the element symbol; their full-name twin carries the surviving factor.
MINERAL_ELEMENT_ALIASES = {
    "Cu": "Copper",
    "Ni": "Nickel",
    "Pd": "Palladium",
    "Pt": "Platinum",
}


def broadcast_mineral_grades(db):
    """Characterize every ore-grade mineral resource flow with its element's factor (taken
    from the grades the method still lists), so mru is counted whatever grade names a source
    database uses. Only fills gaps; an already-characterized flow is left untouched."""
    biosphere = bw2data.Database(settings.bw.BIOSPHERE)
    for method in db:
        if method["name"][1] != MRU_CATEGORY:
            continue
        factor_for = {}
        for cf in method["exchanges"]:
            factor_for.setdefault(cf["name"].split(",")[0].strip(), cf)
        present = {
            (cf["name"], tuple(cf.get("categories") or ()))
            for cf in method["exchanges"]
        }
        for flow in biosphere:
            categories = tuple(flow.get("categories") or ())
            if (
                flow.get("type") != "emission"
                or not categories
                or categories[0] != "natural resource"
            ):
                continue
            key = (flow["name"], categories)
            if key in present:
                continue
            element = flow["name"].split(",")[0].strip()
            base = factor_for.get(element) or factor_for.get(
                MINERAL_ELEMENT_ALIASES.get(element, "")
            )
            if base is None:
                continue
            method["exchanges"].append(
                {
                    **base,
                    "name": flow["name"],
                    "categories": categories,
                }
            )
            present.add(key)
    return db


def import_method():
    """
    Import file at path `datapath` linked to biosphere named `dbname`
    """

    logger.debug(
        f"{settings.bw.BIOSPHERE} size: {len(bw2data.Database(settings.bw.BIOSPHERE))}"
    )
    logger.info(f"🟢 Importing {settings.dbfiles.METHOD}")
    datapath = s3.get_file(settings.dbfiles.METHOD, settings.dbfiles.METHOD_MD5)
    # unzip
    with tempfile.TemporaryDirectory() as tempdir:
        logger.debug(f"-> Extracting the zip file {datapath}")
        with ZipFile(datapath) as zf:
            extracted_fn = zf.extract(zf.namelist()[0], tempdir)
            logger.debug(f"-> Extracted the zip file as {extracted_fn}")

            ef = bw2io.importers.SimaProLCIACSVImporter(
                extracted_fn, biosphere=settings.bw.BIOSPHERE
            )

            ef.statistics()

            ef.strategies = [
                normalize_units,
                set_biosphere_type,
                drop_unspecified_subcategories,
                functools.partial(normalize_biosphere_categories, lcia=True),
                functools.partial(normalize_biosphere_names, lcia=True),
                normalize_simapro_biosphere_categories,
                normalize_simapro_biosphere_names,
                add_legacy_flow_synonyms,
                broadcast_mineral_grades,
                functools.partial(
                    link_iterable_by_fields,
                    other=(
                        obj
                        for obj in bw2data.Database(ef.biosphere_name)
                        if obj.get("type") == "emission"
                    ),
                    kind="biosphere",
                ),
                functools.partial(
                    match_subcategories, biosphere_db_name=ef.biosphere_name
                ),
            ]
            ef.strategies.append(noLT)
            ef.strategies.append(uraniumFRU)
            ef.apply_strategies()
            logger.debug(f"biosphere3 size: {len(bw2data.Database('biosphere3'))}")
            ef.statistics()

            # ef.write_excel(METHODNAME)
            # drop CFs which are not linked to a biosphere substance
            ef.drop_unlinked()
            # remove duplicates in exchanges
            for m in ef.data:
                m["exchanges"] = [
                    dict(f) for f in list(set([frozendict(d) for d in m["exchanges"]]))
                ]

            ef.write_methods(overwrite=True)
    logger.info(f"🟢 Finished importing {settings.bw.METHOD}")


if __name__ == "__main__":
    setup_project()

    if (
        len([method for method in bw2data.methods if method[0] == settings.bw.METHOD])
        == 0
    ):
        import_method()
    else:
        logger.debug(f"{settings.bw.METHOD} already imported")
