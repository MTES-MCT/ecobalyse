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
from common.import_ import setup_project
from config import settings
from ecobalyse_data import s3
from ecobalyse_data.bw.strategy import noLT, uraniumFRU
from ecobalyse_data.logging import logger

# Ecoinvent 3.11 uses the modern IUPAC flow names, while Agribalyse 3.2, Ginko,
# WFLDB and Ecoinvent 3.9.1 still use the legacy names. EF 3.1 1.03 renamed these
# substances to the modern names, so it stopped characterizing the legacy-named
# biosphere flows -> the impact (ozone depletion, toxicity) would be silently
# undercounted for the legacy databases. We re-characterize each legacy flow with
# the same factor as its modern synonym, so the substance is counted whatever
# naming vintage a source database uses.
# modern name -> legacy name, for every substance EF 3.1 1.03 renamed AND that
# biosphere3 still carries under both names (so legacy databases keep matching).
# Water region flows (e.g. "Water, SERC" -> "Water, US-SERC") are also renamed but
# are intentionally omitted: they are US-grid return flows (negative CF) and cause
# no measurable change on the legacy (food) databases.
METHOD_FLOW_SYNONYMS = {
    "Bromomethane": "Methane, bromo-, Halon 1001",
    "Bromotrifluoromethane": "Methane, bromotrifluoro-, Halon 1301",
    "Bromochlorodifluoromethane": "Methane, bromochlorodifluoro-, Halon 1211",
    "1,1,1-Trichloroethane": "Ethane, 1,1,1-trichloro-, HCFC-140",
    "Quizalofop-ethyl": "Quizalofop ethyl ester",
    "Pyrethrins": "Pyrethrum",
}


def add_legacy_flow_synonyms(db):
    """Duplicate each renamed substance's factors onto its legacy-named flow."""
    for method in db:
        method["exchanges"].extend(
            {**cf, "name": METHOD_FLOW_SYNONYMS[cf["name"]]}
            for cf in list(method["exchanges"])
            if cf.get("name") in METHOD_FLOW_SYNONYMS
        )
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
