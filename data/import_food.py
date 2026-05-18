#!/usr/bin/env python3
import argparse
import functools

import bw2data
from bw2io.strategies import (
    assign_only_product_as_production,
    change_electricity_unit_mj_to_kwh,
    # convert_activity_parameters_to_list,
    drop_unspecified_subcategories,
    # fix_localized_water_flows,
    fix_zero_allocation_products,
    # link_technosphere_based_on_name_unit_location,
    migrate_datasets,
    migrate_exchanges,
    normalize_biosphere_categories,
    # normalize_biosphere_names,
    normalize_simapro_biosphere_categories,
    normalize_simapro_biosphere_names,
    normalize_units,
    set_code_by_activity_hash,
    sp_allocate_products,
    split_simapro_name_geo,
    strip_biosphere_exc_locations,
    update_ecoinvent_locations,
)
from bw2io.strategies.simapro import set_lognormal_loc_value_uncertainty_safe

from common import brightway_patch as brightway_patch
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


STRATEGIES = [
    normalize_units,
    update_ecoinvent_locations,
    assign_only_product_as_production,
    drop_unspecified_subcategories,
    sp_allocate_products,
    fix_zero_allocation_products,
    split_simapro_name_geo,
    strip_biosphere_exc_locations,
    functools.partial(migrate_datasets, migration="default-units"),
    functools.partial(migrate_exchanges, migration="default-units"),
    functools.partial(set_code_by_activity_hash, overwrite=True),
    change_electricity_unit_mj_to_kwh,
    # link_technosphere_based_on_name_unit_location,
    set_lognormal_loc_value_uncertainty_safe,
    normalize_biosphere_categories,
    normalize_simapro_biosphere_categories,
    # normalize_biosphere_names,
    normalize_simapro_biosphere_names,
    # functools.partial(migrate_exchanges, migration="simapro-water"),
    # fix_localized_water_flows,
]


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

    if args.recreate_activities:
        if "Ecobalyse" in bw2data.databases:
            del bw2data.databases["Ecobalyse"]
