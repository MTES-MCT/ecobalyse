import json
import os
from typing import Iterable

import bw2io
from bw2data import methods
from bw2data.backends.proxies import Activity
from bw2data.method import Method
from bw2data.utils import get_geocollection, get_node
from bw2io.extractors import simapro_csv
from bw2io.importers.simapro_lcia_csv import SimaProLCIACSVExtractor
from bw2io.strategies import simapro

from ecobalyse_data.logging import logger


# We need to load a custom biosphere normalization file but the one that
# BW loads is harcoded in the `bw2io` code. So we need to patch the json_load function
# to load our own json file.
#
# Remember, don't try this at home, kids. This ugly hack was written by a professional.
def patched_load_json_data_file(filename):
    BW2IO_DATA_DIR = os.path.join(os.path.dirname(bw2io.utils.__file__), "data")
    CURRENT_FILE_DIR = os.path.dirname(__file__)

    if filename[-5:] != ".json":
        filename = filename + ".json"

    # If BW tries to load his bundled biosphere normalization, load our custom biosphere file instead
    if filename == "simapro-biosphere.json":
        # Use the simapro-biosphere.json from this repo
        filepath = os.path.join(CURRENT_FILE_DIR, "..", filename)
        logger.info(f"#### Loading custom biosphere normalization from {filepath}")
    else:
        # Else load whatever BW wants to load from its data directory
        filepath = os.path.join(BW2IO_DATA_DIR, filename)

    return json.load(open(filepath, encoding="utf-8"))


# We add Normalization detection at it’s part of our CSV files
# https://github.com/ccomb/brightway2-io/commit/183b25d6bb224aea3939fd3bf77833d0759db327
def get_normalization_weighting_data(data, index):
    logger.info("#### -> Custom `get_normalization_weighting_data`")

    nw_data = []
    name = data[index][0]
    index += 2
    assert data[index][0] == "Normalization"
    index += 1
    while data[index]:
        cat, norm = data[index][:2]
        index += 1
        if norm == "0":
            continue
        nw_data.append((cat, float(norm.replace(",", "."))))
    index += 1
    assert data[index][0] == "Weighting"
    index += 1
    while data[index]:
        cat, weight = data[index][:2]
        index += 1
        if weight == "0":
            continue
        nw_data.append((cat, float(weight.replace(",", "."))))
    return (name, nw_data), index


# https://github.com/ccomb/brightway2-io/commit/183b25d6bb224aea3939fd3bf77833d0759db327
def read_method_data_set(data, index, filepath):
    """
    Patch for `bw2io/extractors/simapro_lcia_csv.py`

    Normalization data seems
    """

    logger.info("#### -> Custom `read_method_data_set`")

    metadata, index = SimaProLCIACSVExtractor.read_metadata(data, index)
    method_root_name = metadata.pop("Name")
    description = metadata.pop("Comment")
    category_data, nw_data, damage_category_data, completed_data = [], [], [], []

    # `index` is now the `Impact category` line
    while not data[index] or data[index][0] != "End":
        if not data[index] or not data[index][0]:
            index += 1
        elif data[index][0] == "Impact category":
            catdata, index = SimaProLCIACSVExtractor.get_category_data(data, index + 1)
            category_data.append(catdata)
        elif data[index][0] == "Normalization-Weighting set":
            nw_dataset, index = get_normalization_weighting_data(data, index + 1)
            nw_data.append(nw_dataset)
        elif data[index][0] == "Damage category":
            catdata, index = SimaProLCIACSVExtractor.get_damage_category_data(
                data, index + 1
            )
            damage_category_data.append(catdata)
        else:
            raise ValueError

    for ds in category_data:
        completed_data.append(
            {
                "description": description,
                "name": (method_root_name, ds[0]),
                "unit": ds[1],
                "filename": filepath,
                "exchanges": ds[2],
            }
        )

    return completed_data, index


# Patch for https://github.com/brightway-lca/brightway2-io/issues/277#issuecomment-2363494947
def patched_write_method(self, data, process=True):
    """Serialize intermediate data to disk.

    Sets the metadata key ``num_cfs`` automatically."""

    if self.name not in self._metadata:
        self.register()
    self.metadata["num_cfs"] = len(data)

    def normalize_ids(line: Iterable) -> tuple:
        if isinstance(line[0], Activity):
            return (line[0].id, *line[1:])
        elif isinstance(line[0], tuple):
            return (get_node(key=line[0]).id, *line[1:])
        # Don't touch anything when it's a list to be backward compatible with old biosphere LCIA
        elif isinstance(line[0], list):
            return line
        elif not isinstance(line[0], int):
            raise ValueError(
                f"Can't understand elementary flow identifier {line[0]} in data line {line}"
            )
        else:
            return tuple(line)

    data = [normalize_ids(line) for line in data]

    geocollections = {
        get_geocollection(
            elem[2] if len(elem) == 3 else None, default_global_location=True
        )
        for elem in data
    }

    if None in geocollections:
        geocollections.discard(None)

    self.metadata["geocollections"] = sorted(geocollections)
    super(Method, self).write(data, process=process)
    methods.flush()


simapro.load_json_data_file = patched_load_json_data_file
bw2io.load_json_data_file = patched_load_json_data_file

# @ccomb commit https://github.com/ccomb/brightway2-io/commit/3d3d9dea3cbfd212873eee1f757fecede6a3ec3f
simapro_csv.strip_whitespace_and_delete = lambda obj: (
    obj.replace("\x7f", "\n").strip() if isinstance(obj, str) else obj
)

SimaProLCIACSVExtractor.read_method_data_set = read_method_data_set
Method.write = patched_write_method
