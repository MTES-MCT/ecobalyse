#!/usr/bin/env python3

import bw2data
from bw2io.strategies import (
    change_electricity_unit_mj_to_kwh,
    normalize_units,
)

from common import brightway_patch as brightway_patch
from common.import_ import (
    import_simapro_csv,
    setup_project,
)
from config import settings
from ecobalyse_data.bw.strategy import (
    extract_simapro_metadata,
    extract_tags,
)
from ecobalyse_data.logging import logger
from import_ecoinvent import STRATEGIES

# BAFU is a SimaPro CSV export of the Swiss KBOB ecoSpold project. It reuses the ecoinvent
# normalization chain (STRATEGIES). Two ecoinvent-only strategies are intentionally left out:
# - `extract_name_location_product`: its regex expects the ecoinvent-v3 SimaPro naming
#   `product {CC}| activity`; BAFU uses the older UVEK/v2 convention (`name, at ... {CH} U`),
#   with no product/activity split. `split_simapro_name_geo` + `assign_only_product_as_production`
#   (both in STRATEGIES) already set location and reference product.
# - the `remove_*` drop strategies: they would silently discard BAFU flows. Any later
#   adjustment is driven by the flow diagnostic and the VoLCA cross-check, not by dropping data.
BAFU_STRATEGIES = [
    extract_simapro_metadata,
    extract_tags,
]


def main():
    setup_project()

    if (db := settings.bw.BAFU) not in bw2data.databases:
        import_simapro_csv(
            settings.dbfiles.BAFU,
            settings.dbfiles.BAFU_MD5,
            db,
            # A handful of BAFU electricity products are defined in MJ. The shared chain
            # converts electricity MJ->kWh only after set_code_by_activity_hash, which desyncs
            # the dataset unit from its production exchange and breaks the production self-link.
            # Prepend normalize_units + the conversion so assign_only_product_as_production and
            # set_code_by_activity_hash already see consistent kWh (both steps are idempotent).
            strategies=[normalize_units, change_electricity_unit_mj_to_kwh]
            + STRATEGIES
            + BAFU_STRATEGIES,
        )
    else:
        logger.info(f"{db} already imported")


if __name__ == "__main__":
    main()
