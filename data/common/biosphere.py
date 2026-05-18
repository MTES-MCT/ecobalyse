import json
import zipfile

from bw2io.importers import Ecospold2BiosphereImporter
from bw2io.importers.base_lcia import LCIAImporter


def create_ecospold_biosphere(dbname, filepath, overwrite=False):
    eb = Ecospold2BiosphereImporter(name=dbname, filepath=filepath)
    eb.apply_strategies()
    eb.write_database(overwrite=overwrite)


def create_biosphere_lcia_methods(filepath, overwrite=False):
    with zipfile.ZipFile(filepath, mode="r") as archive:
        data = json.load(archive.open("data.json"))

    for method in data:
        method["name"] = tuple(method["name"])

    ei = LCIAImporter(filepath)
    ei.data = data
    ei.write_methods(overwrite=overwrite)
