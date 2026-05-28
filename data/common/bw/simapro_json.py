import functools
import tempfile
import zipfile
from pathlib import Path

import orjson
from bw2data import Database, config
from bw2io.extractors.simapro_csv import SimaProCSVExtractor
from bw2io.importers.base_lci import LCIImporter
from bw2io.strategies import (
    assign_only_product_as_production,
    change_electricity_unit_mj_to_kwh,
    convert_activity_parameters_to_list,
    drop_unspecified_subcategories,
    fix_localized_water_flows,
    fix_zero_allocation_products,
    link_iterable_by_fields,
    link_technosphere_based_on_name_unit_location,
    migrate_datasets,
    migrate_exchanges,
    normalize_biosphere_categories,
    normalize_biosphere_names,
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

from common import patch_agb3
from ecobalyse_data.logging import logger

_CP1252_UNDEFINED = bytes([0x81, 0x8D, 0x8F, 0x90, 0x9D])
_CP1252_SANITIZE = bytes.maketrans(_CP1252_UNDEFINED, b"?" * len(_CP1252_UNDEFINED))


def _sanitize_undefined_cp1252_bytes(filepath):
    """Replace bytes undefined in CP1252 with '?'.

    SimaPro CSV files are CP1252 but may contain stray bytes (0x81, 0x8D,
    0x8F, 0x90, 0x9D) that are undefined in CP1252 and meaningless control
    characters in Latin-1.
    """
    p = Path(filepath)
    p.write_bytes(p.read_bytes().translate(_CP1252_SANITIZE))


def export_zipped_csv_to_json(
    input_path: Path,
    output_path: Path,
    db_name: str | None = None,
):
    logger.debug(f"Start json creation for input file '{input_path}'")

    logger.debug(f"-> JSON output to '{output_path}'")
    with tempfile.TemporaryDirectory() as tempdir:
        assert input_path.suffix.lower() == ".zip"
        with zipfile.ZipFile(input_path) as zf:
            logger.debug(f"-> Extracting the zip file in {tempdir}")
            csv_file = zf.extract(zf.namelist()[0], tempdir)
            assert Path(csv_file).name == input_path.stem

            logger.debug(f"-> Reading from CSV file '{csv_file}'")
            data = []
            global_parameters = []
            metadata = []

            if "AGB3" in input_path.name:
                # Path the official AGB3 release file
                patch_agb3(csv_file)

            _sanitize_undefined_cp1252_bytes(csv_file)

            data, global_parameters, metadata = SimaProCSVExtractor.extract(
                filepath=csv_file,
                name=db_name,
                delimiter=";",
                encoding="cp1252",
            )

            logger.debug(f"-> Writing to json file '{output_path}'")

            with open(output_path, "wb") as fp:
                if db_name:
                    for ds in data:
                        ds["database"] = db_name

                extracted_data = {
                    "data": data,
                    "global_parameters": global_parameters,
                    "metadata": metadata,
                }
                fp.write(orjson.dumps(extracted_data))


class SimaProJsonImporter(LCIImporter):
    format = "SimaPro Json"

    def __init__(
        self,
        filepath,
        name,
        delimiter=";",
        encoding="cp1252",
        normalize_biosphere=True,
        biosphere_db=None,
        extractor=SimaProCSVExtractor,
    ):
        logger.debug(f"Importing JSON from {filepath}")
        with open(filepath, "rb") as f:
            json_data = orjson.loads(f.read())
            self.data = json_data["data"]

            if name is not None:
                for ds in self.data:
                    ds["database"] = name

            self.global_parameters = json_data["global_parameters"]
            self.metadata = json_data["metadata"]

        self.db_name = name

        self.strategies = [
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
            link_technosphere_based_on_name_unit_location,
            set_lognormal_loc_value_uncertainty_safe,
        ]
        if normalize_biosphere:
            self.strategies.extend(
                [
                    normalize_biosphere_categories,
                    normalize_simapro_biosphere_categories,
                    normalize_biosphere_names,
                    normalize_simapro_biosphere_names,
                    functools.partial(migrate_exchanges, migration="simapro-water"),
                    fix_localized_water_flows,
                ]
            )
        self.strategies.extend(
            [
                functools.partial(
                    link_iterable_by_fields,
                    other=Database(biosphere_db or config.biosphere),
                    kind="biosphere",
                ),
                convert_activity_parameters_to_list,
            ]
        )

    def write_database(self, data=None, name=None, *args, **kwargs):
        importer = super(SimaProJsonImporter, self)
        db = importer.write_database(data, name, *args, **kwargs)
        db.metadata["simapro import"] = self.metadata
        db._metadata.flush()
        return db
