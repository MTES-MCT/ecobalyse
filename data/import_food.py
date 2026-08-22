#!/usr/bin/env python3
import argparse

import bw2data

from common import brightway_patch as brightway_patch
from common.bw.strategies import SIMAPRO_BIOSPHERE_NAMES, SIMAPRO_STRATEGIES
from common.import_ import (
    import_simapro_csv,
    setup_project,
)
from config import settings
from ecobalyse_data.bw.migration import (
    AGRIBALYSE_MIGRATIONS,
    GINKO_MIGRATIONS,
    PASTOECO_MIGRATIONS,
)
from ecobalyse_data.bw.strategy import (
    extract_ciqual,
    extract_simapro_location,
    extract_simapro_metadata,
    extract_tags,
    fix_lentil_ldu,
    lower_formula_parameters,
    remove_acetamiprid,
    remove_azadirachtine,
    remove_creosote,
    remove_negative_land_use_on_tomato,
)
from ecobalyse_data.logging import logger

PROJECT = "ecobalyse"
BIOSPHERE = "biosphere3"


STRATEGIES = SIMAPRO_STRATEGIES + SIMAPRO_BIOSPHERE_NAMES


GINKO_STRATEGIES = [
    extract_simapro_metadata,
    extract_simapro_location,
    extract_ciqual,
    extract_tags,
    remove_negative_land_use_on_tomato,
    remove_azadirachtine,
    remove_creosote,
    fix_lentil_ldu,
]
AGB_STRATEGIES = [
    extract_simapro_metadata,
    extract_simapro_location,
    extract_ciqual,
    extract_tags,
    remove_negative_land_use_on_tomato,
    remove_creosote,
    remove_acetamiprid,
]
WFLDB_STRATEGIES = [
    extract_simapro_metadata,
    extract_simapro_location,
    extract_ciqual,
    extract_tags,
    remove_creosote,
    remove_acetamiprid,
]

if __name__ == "__main__":
    """Import Agribalyse and additional processes"""
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--recreate-activities",
        action="store_true",
        help="Delete and re-create the created activities",
    )
    args = parser.parse_args()

    setup_project()

    # AGRIBALYSE
    if (db := settings.bw.agribalyse) not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.AGRIBALYSE,
            settings.dbfiles.AGRIBALYSE_MD5,
            db,
            migrations=AGRIBALYSE_MIGRATIONS,
            strategies=[lower_formula_parameters] + STRATEGIES + AGB_STRATEGIES,
        )
    else:
        logger.info(f"{db} already imported")

    # PASTO ECO
    if (db := "PastoEco") not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.PASTOECO,
            settings.dbfiles.PASTOECO_MD5,
            db,
            external_db=settings.bw.AGRIBALYSE,
            migrations=PASTOECO_MIGRATIONS,
            strategies=STRATEGIES,
        )
    else:
        logger.info(f"{db} already imported")

    # GINKO
    if (db := "Ginko 2025") not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.GINKO,
            settings.dbfiles.GINKO_MD5,
            db,
            external_db=settings.bw.AGRIBALYSE,
            strategies=STRATEGIES + GINKO_STRATEGIES,
            migrations=GINKO_MIGRATIONS + AGRIBALYSE_MIGRATIONS,
        )
    else:
        logger.info(f"{db} already imported")

    # CTCPA
    if (db := "CTCPA") not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.CTCPA,
            settings.dbfiles.CTCPA_MD5,
            db,
            strategies=STRATEGIES,
        )
    else:
        logger.info(f"{db} already imported")

    # WFLDB
    if (db := "WFLDB") not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.WFLDB,
            settings.dbfiles.WFLDB_MD5,
            db,
            strategies=STRATEGIES + WFLDB_STRATEGIES,
        )
    else:
        logger.info(f"{db} already imported")

    if args.recreate_activities and "Ecobalyse_custom_lci" in bw2data.databases:
        del bw2data.databases["Ecobalyse_custom_lci"]
