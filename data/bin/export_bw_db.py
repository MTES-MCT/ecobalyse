#!/usr/bin/env python3

import json
import os
from pathlib import Path
from typing import List, Optional

import bw2data
import typer
from bw2data.project import projects
from typing_extensions import Annotated

from config import PROJECT_ROOT_DIR, settings
from ecobalyse_data.bw import ecospold_export, simapro_export
from ecobalyse_data.bw.search import cached_search_one
from ecobalyse_data.logging import logger
from ecobalyse_data.typer import bw_database_validation, bw_databases_validation

# Init BW project
projects.set_current(settings.bw.project)
available_bw_databases = ", ".join(bw2data.databases)

app = typer.Typer()


@app.command()
def simapro(
    output_file: Annotated[
        Optional[Path],
        typer.Argument(help="The output CSV file."),
    ] = Path("simapro_export.csv"),
    db_name: Annotated[
        Optional[str],
        typer.Argument(
            callback=bw_database_validation,
            help=f"Brightway databases you want to compute impacts for. Default to all. You can specify multiple `--db`.\n\nAvailable databases are: {available_bw_databases}.",
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


@app.command()
def ecospold1(
    db_names: Annotated[
        Optional[List[str]],
        typer.Argument(
            callback=bw_databases_validation,
            help="Brightway database(s) to export (merged into one file).",
        ),
    ] = None,
    output_file: Annotated[
        Optional[Path],
        typer.Option(
            "--output", "-o", help="Output XML file (default: <db_names>.XML)."
        ),
    ] = None,
    from_activities: Annotated[
        bool,
        typer.Option(
            "--activities",
            "-a",
            help="Export activities defined in the lci_catalog/ tree.",
        ),
    ] = False,
):
    """Export one or more Brightway databases to EcoSpold 1 XML format."""
    if from_activities:
        lci_catalog = PROJECT_ROOT_DIR / "lci_catalog"
        logger.info(f"Loading activities from {lci_catalog}")
        eco_activities = []
        for lci_path in sorted(lci_catalog.glob("*/*.json")):
            with open(lci_path, "r") as f:
                eco_activities.append(json.load(f))

        bw_activities = []
        for eco_activity in eco_activities:
            if eco_activity.get("impacts"):
                logger.debug(
                    f"Skipping '{eco_activity.get('displayName', eco_activity.get('activityName'))}' (hardcoded impacts)"
                )
                continue
            bw_activity = cached_search_one(
                eco_activity["source"],
                eco_activity["activityName"],
                location=eco_activity.get("location"),
            )
            bw_activities.append(bw_activity)

        logger.info(f"Found {len(bw_activities)} activities to export")

        if output_file is None:
            output_file = Path("Ecoplus.XML")

        ecospold_export.export_db_to_ecospold(bw_activities, output_file)
        return

    if not db_names:
        logger.error("Provide database name(s), or use --activities.")
        raise typer.Exit(code=1)

    if output_file is None:
        output_file = Path(f"{'_'.join(n.lower() for n in db_names)}.XML")

    activities = [act for name in db_names for act in bw2data.Database(name)]
    ecospold_export.export_db_to_ecospold(activities, output_file)


if __name__ == "__main__":
    app()
