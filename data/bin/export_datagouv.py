#!/usr/bin/env -S uv run --script


import csv
import json
import re
import textwrap
from pathlib import Path, PurePath

import typer
from typing_extensions import Annotated

from ecobalyse_data.logging import logger

CURRENT_DIR = Path(__file__).parent.resolve()
DATA_DIR = CURRENT_DIR.parent / "public" / "data"


def clean_impacts(process: dict) -> dict:
    """Removes the empty impacts values."""
    impacts = process.pop("impacts")
    result = {**process, "impacts": {"ecs": impacts["ecs"]}}
    return result


def rearrange_keys(process: dict) -> dict:
    """Manually sort the columns to improve the readability of the data set."""
    return {
        "id": process["id"],
        "displayName": process["displayName"],
        "technicalName": process["activityName"],
        "location": process["location"],
        "comment": process["comment"].strip('"'),
        "scopes": process["scopes"],
        "categories": process["categories"],
        "unit": process["unit"],
        "massPerUnit": process["massPerUnit"],
        "elecMJ": process["elecMJ"],
        "heatMJ": process["heatMJ"],
        "waste": process["waste"],
        "source": process["source"],
        "ecs": process["impacts"]["ecs"],
    }


def flatten_keys(process: dict) -> dict:
    """Flatten the processes to make them compatible with tabular formats."""
    result = {
        **process,
        "scopes": ",".join(process["scopes"]),
        "categories": ",".join(process["scopes"]),
    }
    return result


def main(
    output_path: Annotated[
        Path,
        typer.Option(
            dir_okay=True,
            exists=True,
            writable=True,
            resolve_path=True,
            help="The absolute path of the directory where the generated files will be written.",
        ),
    ] = DATA_DIR / "export",
    file_prefix: Annotated[
        str,
        typer.Option(help="The filename (without extension) of the generated files."),
    ] = "ecobalyse-processes",
    dryrun: Annotated[
        bool,
        typer.Option(
            "--dry-run", "-n", help="Dry run. Will only show what would be done."
        ),
    ] = False,
):
    """
    Convert the `processes.json` file to the formats published on data.gouv.fr.
    """
    json_filename = PurePath(file_prefix).with_suffix(".json")
    csv_filename = PurePath(file_prefix).with_suffix(".csv")

    if dryrun:
        print(
            textwrap.dedent(
                f"""
            Would write:

            - {json_filename}
            - {csv_filename}

            to:
              {output_path}
            """
            )
        )
        return

    with open(DATA_DIR / "processes.json") as processes_fp:
        processes: list[dict] = [
            rearrange_keys(clean_impacts(process))
            for process in json.load(processes_fp)
        ]

        if len(processes) < 1:
            raise Exception(f"{DATA_DIR / 'processes.json'} is empty")

        # Export the JSON version
        logger.info(f"Writing {json_filename} to {output_path}")
        with open(output_path / json_filename, "w", encoding="utf-8") as json_fp:
            json.dump(processes, json_fp, indent=2, ensure_ascii=False)

        # Export the CSV version
        logger.info(f"Writing {csv_filename} to {output_path}")
        flat_processes: list[dict] = [flatten_keys(process) for process in processes]

        with open(output_path / csv_filename, "w", encoding="utf-8") as csv_file:
            writer = csv.writer(
                csv_file,
                delimiter=",",
                doublequote=True,
                lineterminator="\n",
                quoting=csv.QUOTE_ALL,
            )
            header = [
                # Convert the header names to snake_case
                re.sub("([A-Z]+)", r"_\1", key).lower()
                for key in flat_processes[0].keys()
            ]
            writer.writerow(header)
            for p in flat_processes:
                writer.writerow([v for v in p.values()])
        logger.info("Export done.")


if __name__ == "__main__":
    typer.run(main)
