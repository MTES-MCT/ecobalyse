#!/usr/bin/env python3
"""Import BAFU from its own EcoSpold 1 package rather than from a SimaPro CSV export.

The two are the same database seen through two exporters, and they do not name flows the
same way. Measured on the raw names, before any normalization: the native names are
ecoinvent flows for 86.9% of the biosphere exchanges, SimaPro's for 69.0%. SimaPro writes
`Chromium (VI)`, `Copper, ion` and `Zinc (II)` where the package writes `Chromium VI`,
`Copper` and `Zinc`, so most of `simapro-biosphere.json` has no object here.

The package is not on S3, so the directory holding the `process_<uuid>.xml` files is
given on the command line:

    just import-bafu-ecospold1 "/path/to/BAFU-2025_LCI ecoSpold v1 Files"
"""

import argparse
import functools
import tempfile
from pathlib import Path

import bw2data
from bw2io.importers import SingleOutputEcospold1Importer
from bw2io.strategies import (
    assign_only_product_as_production,
    clean_integer_codes,
    drop_unspecified_subcategories,
    migrate_datasets,
    migrate_exchanges,
    normalize_biosphere_categories,
    normalize_biosphere_names,
    normalize_simapro_biosphere_categories,
    normalize_simapro_biosphere_names,
    normalize_units,
    set_code_by_activity_hash,
    strip_biosphere_exc_locations,
    update_ecoinvent_locations,
)

from common import brightway_patch as brightway_patch
from common.bw.ecospold1 import (
    UNIT_MIGRATION,
    capitalize_compartments,
    fix_reference_units,
    register_unit_migration,
    repair,
    stop_validating_ecospold1,
)
from common.import_ import link_and_write, setup_project
from config import settings
from ecobalyse_data.logging import logger

# The two `simapro` strategies are here despite their name. Neither is about SimaPro: one
# maps the ecoinvent 2 compartment vocabulary (`Emissions to air/high. pop.`) and the
# other the ecoinvent 2 substance names (`1-Butanol` to `Butanol`), and openLCA wrote both
# into this package. Measured on BAFU 2025 v2, the compartments take the flows that have
# to be fabricated from 2678 to 1114, and the names from 1114 to 1002.
#
# What genuinely does not belong is the rest of the SimaPro chain: there is no `{CH} U`
# suffix to split here, and no product/activity naming to take apart.

# `normalize_units` only renames: it turns `Bq` into `Becquerel` and leaves it there,
# a thousand times smaller than the `kilo Becquerel` the method characterizes. The
# conversions live in a migration, which the SimaPro importer applies and the EcoSpold 1
# one does not. Without one, 1180 radionuclide exchanges of the package are counted as
# zero. bw2io's own table cannot be used as it stands: see `common.bw.ecospold1`.
UNIT_MIGRATIONS = [
    functools.partial(migrate_datasets, migration=UNIT_MIGRATION),
    functools.partial(migrate_exchanges, migration=UNIT_MIGRATION),
]

STRATEGIES = [
    normalize_units,
    *UNIT_MIGRATIONS,
    fix_reference_units,
    update_ecoinvent_locations,
    assign_only_product_as_production,
    # The `number` attribute of an EcoSpold 1 dataset is only unique within its file.
    clean_integer_codes,
    drop_unspecified_subcategories,
    strip_biosphere_exc_locations,
    capitalize_compartments,
    normalize_simapro_biosphere_categories,
    normalize_biosphere_categories,
    normalize_biosphere_names,
    normalize_simapro_biosphere_names,
    functools.partial(set_code_by_activity_hash, overwrite=True),
]


def repair_package(source: Path, target: Path) -> int:
    """Copy the package, making each dataset readable on the way. See `common.bw.ecospold1`."""
    datasets = sorted(source.glob("*.xml"))
    if not datasets:
        raise FileNotFoundError(f"no EcoSpold 1 dataset in {source}")
    for dataset in datasets:
        (target / dataset.name).write_text(
            repair(dataset.read_text(encoding="utf-8")), encoding="utf-8"
        )
    return len(datasets)


def import_bafu_ecospold1(source: Path, dbname: str) -> None:
    stop_validating_ecospold1()
    register_unit_migration()
    with tempfile.TemporaryDirectory() as tempdir:
        repaired = Path(tempdir)
        logger.info(f"🟢 Repairing {source}")
        count = repair_package(source, repaired)
        logger.info(f"🟢 Importing {count} datasets into {dbname}")

        # Single process: a dataset the extractor refuses raises inside the worker, and
        # the pool loses the message trying to pickle it, so the reason is never seen.
        database = SingleOutputEcospold1Importer(str(repaired), dbname, use_mp=False)

    database.statistics()
    database.strategies = STRATEGIES
    database.apply_strategies()
    database.statistics()

    link_and_write(database, biosphere=settings.bw.BIOSPHERE)
    logger.info(f"🟢 Finished importing {dbname}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "source",
        type=Path,
        help="directory holding the EcoSpold 1 `process_<uuid>.xml` datasets",
    )
    parser.add_argument(
        "--dbname",
        default=f"{settings.bw.BAFU} ecospold1",
        help="name of the Brightway database to create",
    )
    args = parser.parse_args()

    setup_project()
    if args.dbname in bw2data.databases:
        logger.info(f"{args.dbname} already imported")
        return
    import_bafu_ecospold1(args.source, args.dbname)


if __name__ == "__main__":
    main()
