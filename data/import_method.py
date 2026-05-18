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
