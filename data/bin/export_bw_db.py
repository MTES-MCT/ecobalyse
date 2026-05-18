#!/usr/bin/env python3

import os
from pathlib import Path
from typing import Optional

import bw2data
import typer
from bw2data.project import projects
from typing_extensions import Annotated

from config import PROJECT_ROOT_DIR, settings
from ecobalyse_data.bw import simapro_export
from ecobalyse_data.logging import logger
from ecobalyse_data.typer import bw_database_validation

# Init BW project
projects.set_current(settings.bw.project)
available_bw_databases = ", ".join(bw2data.databases)


def main(
    output_file: Annotated[
        Optional[Path],
        typer.Argument(help="The output CSV file."),
    ] = Path("simapro_export.csv"),
    db_name: Annotated[
        Optional[str],
        typer.Argument(
            callback=bw_database_validation,
            help=f"Brightway databases you want to computate impacts for. Default to all. You can specify multiple `--db`.\n\nAvailable databases are: {available_bw_databases}.",
        ),
    ] = "Ecobalyse",
):
    logger.info(f"Exporting from db '{db_name}'")

    db = bw2data.Database(db_name)

    # Specify data paths
    data_dir = PROJECT_ROOT_DIR / "ecobalyse_data" / "data"

    filepath_simapro_units = os.path.join(data_dir, "simapro_units.yml")
    filepath_simapro_compartments = os.path.join(data_dir, "simapro_compartments.yml")

    biosphere_flows = {
        "3.9": os.path.join(data_dir, "flows_biosphere_39.csv"),
        "3.10": os.path.join(data_dir, "flows_biosphere_310.csv"),
    }

    simapro_biosphere_path = PROJECT_ROOT_DIR / "simapro-biosphere.json"
    simapro_categories_path = data_dir / "simapro_categories.csv"
    references_path = data_dir / "references.csv"

    simapro_export.export_db_to_simapro(
        db,
        output_file,
        simapro_units_path=filepath_simapro_units,
        simapro_compartments_path=filepath_simapro_compartments,
        simapro_biosphere_path=simapro_biosphere_path,
        simapro_categories_path=simapro_categories_path,
        references_path=references_path,
        biosphere_flows=biosphere_flows,
    )


if __name__ == "__main__":
    typer.run(main)
