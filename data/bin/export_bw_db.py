#!/usr/bin/env python3

import json
from pathlib import Path
from typing import Annotated

import bw2data
import typer
from bw2data.project import projects

from config import DATA_ROOT_DIR, settings
from ecobalyse_data.bw import ecospold_export
from ecobalyse_data.bw.search import cached_search_one
from ecobalyse_data.logging import logger
from ecobalyse_data.typer import bw_databases_validation

# Init BW project
projects.set_current(settings.bw.project)
available_bw_databases = ", ".join(bw2data.databases)

app = typer.Typer(no_args_is_help=True)


@app.command()
def ecospold1(
    db_names: Annotated[
        list[str] | None,
        typer.Argument(
            callback=bw_databases_validation,
            help="Brightway database(s) to export (merged into one file).",
        ),
    ] = None,
    output_filename: Annotated[
        Path | None,
        typer.Option(
            "--output", "-o", help="Output XML file (default: <db_names>.XML)."
        ),
    ] = None,
    whole_lci_catalog: Annotated[
        bool,
        typer.Option(
            "--all",
            "-a",
            help="Export all activities defined in the lci_catalog/ tree.",
        ),
    ] = False,
):
    """Export one or more Brightway databases to EcoSpold 1 XML format."""
    if whole_lci_catalog:
        lci_catalog = DATA_ROOT_DIR / "lci_catalog"
        logger.info(f"Loading activities from {lci_catalog}")
        activities = []
        for lci_path in sorted(lci_catalog.glob("*/*.json")):
            with open(lci_path, "r") as f:
                activities.append(json.load(f))

        bw_activities = []
        for activity in activities:
            if activity.get("source") == "Ecobalyse_manual_lcia":
                logger.debug(
                    f"Skipping '{activity.get('displayName', activity.get('activityName'))}' (hardcoded impacts)"
                )
                continue
            bw_activity = cached_search_one(
                activity["source"],
                activity["activityName"],
                location=activity.get("location"),
            )
            bw_activities.append(bw_activity)

        logger.info(f"Exporting {len(bw_activities)} activities to {output_filename}")

        if output_filename is None:
            output_filename = Path("Ecoplus.XML")

        ecospold_export.export_db_to_ecospold(bw_activities, output_filename)
        return

    if not db_names:
        logger.error("Provide database name(s), or use --activities.")
        raise typer.Exit(code=1)

    if output_filename is None:
        output_filename = Path(f"{'_'.join(n.lower() for n in db_names)}.XML")

    activities = [act for name in db_names for act in bw2data.Database(name)]  # ty:ignore[not-iterable]

    ecospold_export.export_db_to_ecospold(activities, output_filename)


if __name__ == "__main__":
    app()
