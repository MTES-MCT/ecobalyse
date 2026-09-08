import functools

from bw2io.strategies import (
    assign_only_product_as_production,
    change_electricity_unit_mj_to_kwh,
    drop_unspecified_subcategories,
    fix_zero_allocation_products,
    migrate_datasets,
    migrate_exchanges,
    normalize_biosphere_categories,
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

SIMAPRO_STRATEGIES = [
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
    set_lognormal_loc_value_uncertainty_safe,
    normalize_biosphere_categories,
    normalize_simapro_biosphere_categories,
]

SIMAPRO_BIOSPHERE_NAMES = [normalize_simapro_biosphere_names]
