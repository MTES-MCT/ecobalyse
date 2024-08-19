import logging
import pathlib
from typing import Tuple

# Tell ruff to not delete the unused import by rexporting it using as
# See https://docs.astral.sh/ruff/rules/unused-import/
from ecobalyse import logging_config as logging_config

logger = logging.getLogger(__name__)


def patch_storage_key(index_js_string: str, version: str) -> Tuple[str, int]:
    nb = index_js_string.count('storeKey = "store"')
    data = None
    if nb >= 0:
        data = index_js_string.replace(
            'storeKey = "store"', f'storeKey = "store{version}"'
        )

    return (data, nb)


def patch_version_string(elm_version_string: str) -> Tuple[str, int]:
    nb = elm_version_string.count('"/version.json')
    data = None
    if nb >= 0:
        data = elm_version_string.replace('"/version.json', '"version.json')

    return (data, nb)


def write_patched_data(nb_patched: int, data: str, dest_file: pathlib.Path) -> bool:
    if nb_patched == 1:
        with open(dest_file, "w") as f:
            f.write(data)
            logger.info(f"Content patched successfully in `{dest_file}`.")
            return True
    else:
        logger.info(f"No content to patch in `{dest_file}`, doing nothing.")

    return False


def patch_version_file(elm_version_file: pathlib.Path):
    (data, nb) = (None, 0)

    with open(elm_version_file, "r") as file:
        data = file.read()
        (data, nb) = patch_version_string(data)

    write_patched_data(nb, data, elm_version_file)


def patch_index_js_file(index_js_file: pathlib.Path, version: str):
    (data, nb) = (None, 0)

    with open(index_js_file, "r") as file:
        data = file.read()
        (data, nb) = patch_storage_key(data, version)

    write_patched_data(nb, data, index_js_file)
