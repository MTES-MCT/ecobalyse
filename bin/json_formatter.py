#!/usr/bin/env -S uv run --script


import json
from pathlib import Path
from typing import Annotated

import typer
from ecobalyse.json import CompactJSONEncoder, activities_processes_sort_key
from ecobalyse.logging import logger

EXCLUDED_PATHS: list[str] = [
    "/.git",
    "/.venv/",
    "/.vscode",
    "/node_modules/",
    "/package-lock.json",
    "/package.json",
    "/tests/activities-schema.json",
    "/tests/processes-schema.json",
    "/data/common/distances/distances_raw.json",
]

SORT_PATHS = [
    "processes.json",
    "processes_impacts.json",
    "processes_generic.json",
    "processes_generic_impacts.json",
]


def _lint_and_fix(path: Path, fix: bool, number_precision: int):
    logger.debug(f"Checking {path}")

    with open(path, "r", encoding="utf-8") as fp:
        src_data = fp.read()

        assert src_data is not None
        try:
            input_data = json.loads(src_data)

            precision = None
            if path.name in SORT_PATHS:
                input_data.sort(key=activities_processes_sort_key)
                # Only apply precision number to processes files
                precision = number_precision

            formatted_data = json.dumps(
                input_data,
                ensure_ascii=False,
                sort_keys=True,
                indent=2,
                cls=CompactJSONEncoder,
                number_precision=precision,
            )
            formatted_data += "\n"

            if formatted_data == src_data:
                logger.debug(f"{path} is already properly formatted")
                return True
            elif fix:
                logger.info(f"Reformatting {path}")
                with open(path, "w", encoding="utf-8") as fp:
                    fp.write(formatted_data)
                    return True
            logger.error(f"{path} needs formatting")
        except Exception:
            print(f"json_formatter error in {path}")
            raise
    return False


def is_excluded(path: Path):
    # TODO: starting with Python 3.13, we should be able to use
    # https://docs.python.org/3.13/library/pathlib.html#pathlib.PurePath.full_match
    # return any([path.full_match(exclusion) for exclusion in EXCLUDED_PATHS])
    return any(exclusion in str(path) for exclusion in EXCLUDED_PATHS)


def main(
    paths: Annotated[
        list[Path],
        typer.Argument(
            dir_okay=True,
            exists=True,
            writable=True,
            resolve_path=True,
            help="The paths of json files or of directories containing json files",
        ),
    ],
    number_precision: Annotated[
        int,
        typer.Option(
            help="Float precision to apply to process files",
        ),
    ] = 4,
    fix: Annotated[
        bool,
        typer.Option(
            "--fix",
            help="Format the file(s) and write back the changes to the original file(s)",
        ),
    ] = False,
):
    """
    JSON formatter.

    By default, this will check that the files passed as arguments are properly formatted.
    With the --fix option, this will additionaly format them in place.
    """
    for path in paths:
        if is_excluded(path):
            logger.debug(f"ignoring {path}")
            continue
        if path.is_file():
            success = _lint_and_fix(path, fix, number_precision)
            if not success:
                raise typer.Exit(-1)
        else:
            assert path.is_dir()
            json_files = path.glob("**/*.json")

            for json_file in json_files:
                if is_excluded(json_file):
                    logger.debug(f"ignoring {json_file}")
                    continue
                success = _lint_and_fix(json_file, fix, number_precision)
                if not success:
                    raise typer.Exit(-1)


if __name__ == "__main__":
    typer.run(main)
