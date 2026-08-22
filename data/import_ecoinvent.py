#!/usr/bin/env python3

import bw2data
from bw2io.strategies import (
    convert_activity_parameters_to_list,
    normalize_biosphere_names,
)

from common import brightway_patch as brightway_patch
from common.bw.strategies import SIMAPRO_BIOSPHERE_NAMES, SIMAPRO_STRATEGIES
from common.import_ import (
    import_simapro_csv,
    setup_project,
)
from config import settings
from ecobalyse_data.bw.migration import WOOLMARK_MIGRATIONS
from ecobalyse_data.bw.strategy import (
    extract_ciqual,
    extract_name_location_product,
    # extract_simapro_location,
    extract_simapro_metadata,
    extract_tags,
    lower_formula_parameters,
    remove_acetamiprid,
    remove_creosote,
    use_unit_processes,
)
from ecobalyse_data.logging import logger

STRATEGIES = (
    SIMAPRO_STRATEGIES
    + [normalize_biosphere_names]
    + SIMAPRO_BIOSPHERE_NAMES
    + [convert_activity_parameters_to_list]
)
ECOINVENT_STRATEGIES = [
    extract_simapro_metadata,
    # extract_simapro_location,
    extract_ciqual,
    extract_name_location_product,
    extract_tags,
    remove_creosote,
    remove_acetamiprid,
]

WOOLMARK_STRATEGIES = [use_unit_processes]


def main():
    setup_project()

    if (db := "Ecoinvent 3.11") not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.EI311,
            settings.dbfiles.EI311_MD5,
            db,
            strategies=STRATEGIES + ECOINVENT_STRATEGIES,
        )
    else:
        logger.info(f"{db} already imported")

    if (db := "Ecoinvent 3.9.1") not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.EI391,
            settings.dbfiles.EI391_MD5,
            db,
            strategies=STRATEGIES + ECOINVENT_STRATEGIES,
        )
    else:
        logger.info(f"{db} already imported")

    if (db := "Woolmark") not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.WOOL,
            settings.dbfiles.WOOL_MD5,
            db,
            migrations=WOOLMARK_MIGRATIONS,
            strategies=[lower_formula_parameters] + STRATEGIES + WOOLMARK_STRATEGIES,
            external_db="Ecoinvent 3.9.1",
        )
    else:
        logger.info(f"{db} already imported")


if __name__ == "__main__":
    main()
