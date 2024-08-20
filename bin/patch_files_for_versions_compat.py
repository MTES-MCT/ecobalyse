#!/usr/bin/env python
import logging
import pathlib
from enum import Enum

import typer

# Tell ruff to not delete the unused import by rexporting it using as
# See https://docs.astral.sh/ruff/rules/unused-import/
from ecobalyse import logging_config as logging_config
from ecobalyse.patch_files import (
    patch_elm_version_file,
    patch_index_js_file,
)
from typing_extensions import Annotated

logger = logging.getLogger(__name__)


class LoggingLevels(str, Enum):
    CRITICAL = "CRITICAL"
    DEBUG = "DEBUG"
    ERROR = "ERROR"
    INFO = "INFO"
    NOTSET = "NOTSET"
    WARNING = "WARNING"


app = typer.Typer(
    help="Patch old versions of ecobalyse to be compatible with the new versionning system."
)


@app.callback()
def main(
    loglevel: Annotated[
        LoggingLevels, typer.Option("--loglevel", "-l")
    ] = LoggingLevels.INFO,
):
    logger.setLevel(loglevel.value)


@app.command()
def elm_version(
    elm_version_file: Annotated[
        pathlib.Path,
        typer.Argument(
            help="The full path to the Version.elm file.",
            exists=True,
            file_okay=True,
            dir_okay=False,
            writable=True,
            readable=True,
            resolve_path=True,
        ),
    ],
):
    """
    Patch Version.elm file to remove the absolute call to /version.json
    """
    patch_elm_version_file(elm_version_file)


@app.command()
def local_storage_key(
    index_js_file: Annotated[
        pathlib.Path,
        typer.Argument(
            help="The full path to the index.js file.",
            exists=True,
            file_okay=True,
            dir_okay=False,
            writable=True,
            readable=True,
            resolve_path=True,
        ),
    ],
    suffix: Annotated[
        str, typer.Argument(help="The suffix to append to the storage key.")
    ],
):
    """
    Patch main index.js file to add the version to the local storage key
    """
    patch_index_js_file(index_js_file, suffix)


if __name__ == "__main__":
    app()
