#!/usr/bin/env -S uv run --script


import json
import os
import posixpath
from pathlib import Path
from typing import Annotated

import pathspec
import typer
from data.common.export import activities_processes_sort_key
from ecobalyse.json import CompactJSONEncoder
from ecobalyse.logging import logger


def load_ignore_spec_file(ignore_file: Path) -> pathspec.PathSpec:
    """Charge un fichier de patterns au format gitignore"""
    with open(ignore_file, encoding="utf-8") as f:
        return load_ignore_spec(f.read().splitlines())


def load_ignore_spec(lines: list[str]) -> pathspec.PathSpec:
    return pathspec.GitIgnoreSpec.from_lines("gitignore", lines)


SORT_PATHS = [
    "processes.json",
    "processes_impacts.json",
    "processes_generic.json",
    "processes_generic_impacts.json",
]


def lint_and_fix(path: Path, fix: bool, number_precision: int):
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


def is_excluded(path: Path | str, ignore_spec: pathspec.PathSpec, rel_dir: Path):
    return ignore_spec.match_file(posixpath.relpath(path, rel_dir))


def rel_path(name: str, rel_dir: Path) -> str:
    return name if rel_dir == Path(".") else (rel_dir / name).as_posix()


def find_json_files(
    root: Path, ignore_spec: pathspec.PathSpec, ignore_file_dir_path: Path
) -> list[Path]:
    """Returns all the *.json under `root`, taking into account `ignore_spec`"""
    matches: list[Path] = []

    for dirpath, dirnames, filenames in os.walk(root):
        rel_dir = Path(dirpath).relative_to(root)

        """
        Optimize os.walk by removing excluded dirs from the parsing

        https://docs.python.org/3/library/os.html#os.walk
        When topdown is True, the caller can modify the dirnames list in-place (perhaps using del or slice assignment),
        and walk() will only recurse into the subdirectories whose names remain in dirnames;
        """
        dirnames[:] = [
            d
            for d in dirnames
            if not is_excluded(
                rel_path(d, rel_dir) + "/", ignore_spec, ignore_file_dir_path
            )
        ]
        for name in filenames:
            if not name.lower().endswith(".json"):
                continue
            rel = rel_path(name, rel_dir)
            if not is_excluded(rel, ignore_spec, ignore_file_dir_path):
                matches.append(Path(dirpath) / name)

    return matches


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
    ignore_file: Annotated[
        Path,
        typer.Option(
            help="Float precision to apply to process files",
        ),
    ] = Path(".jsonformatignore"),
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
    ignore_file_dir_path = Path(os.path.dirname(os.path.realpath(ignore_file)))
    ignore_spec = load_ignore_spec_file(ignore_file)

    # logger.setLevel(logging.DEBUG)
    files_to_format: list[Path] = []

    for path in paths:
        # Check if the Paths are not directly excluded
        if is_excluded(path, ignore_spec, ignore_file_dir_path):
            logger.debug(f"ignoring {path}")
            continue
        else:
            # We can lint the file directly as we’re sure it was not excluded
            if path.is_file():
                files_to_format.append(path)
            else:
                assert path.is_dir()
                files_to_format = files_to_format + find_json_files(
                    path, ignore_spec, ignore_file_dir_path
                )

    for file_to_format in files_to_format:
        logger.debug(f"formatting {file_to_format}")
        success = lint_and_fix(file_to_format, fix, number_precision)
        if not success:
            raise typer.Exit(-1)


if __name__ == "__main__":
    typer.run(main)
