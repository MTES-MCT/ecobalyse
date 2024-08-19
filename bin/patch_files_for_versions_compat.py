#!/usr/bin/env python
import argparse
import logging
import pathlib

# Tell ruff to not delete the unused import by rexporting it using as
# See https://docs.astral.sh/ruff/rules/unused-import/
from ecobalyse import logging_config as logging_config
from ecobalyse.patch_files import patch_index_js_file, patch_version_file

logger = logging.getLogger(__name__)

ELM_VERSION_FILE = "src/Request/Version.elm"
INDEX_JS_FILE = "index.js"


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Patch old versions of ecobalyse to be compatible with the new versionning system."
    )

    parser.add_argument(
        "version",
        type=str,
        help="The version used to prepend to the local storage key.",
    )
    parser.add_argument(
        "--elm_version_file",
        type=pathlib.Path,
        nargs="?",
        help=f"The Version.elm file path. Default to '{ELM_VERSION_FILE}'.",
        default=ELM_VERSION_FILE,
    )

    parser.add_argument(
        "--index_js_file",
        type=pathlib.Path,
        nargs="?",
        help=f"The JS index.js file path. Default to '{INDEX_JS_FILE}'.",
        default=INDEX_JS_FILE,
    )

    parser.add_argument(
        "--loglevel",
        type=str.upper,
        help="Override default logging level for current module.",
        choices=logging.getLevelNamesMapping().keys(),
    )

    args = parser.parse_args()

    logger.info(
        f"Trying to patch '{args.elm_version_file}' and '{args.index_js_file}'."
    )

    patch_version_file(args.elm_version_file)
    patch_index_js_file(args.index_js_file, args.version)
