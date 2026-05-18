#!/usr/bin/env python3


import json
from typing import List, Optional

import bw2data
import typer
from bw2data.project import projects
from typing_extensions import Annotated

from common import get_normalization_weighting_factors
from common.export import (
    IMPACTS_JSON,
    display_changes,
    display_changes_table,
    get_changes,
)
from common.impacts import impacts as impacts_py
from common.impacts import main_method
from config import settings
from ecobalyse_data.bw.analyzer import print_recursive_calculation
from ecobalyse_data.bw.search import search_one
from ecobalyse_data.computation import compute_impacts, compute_process_for_bw_activity
from ecobalyse_data.logging import logger
from ecobalyse_data.typer import (
    bw_database_validation,
    ecobalyse_impact_validation,
    method_impact_validation,
)

app = typer.Typer()


# Init BW project
projects.set_current(settings.bw.project)
available_bw_databases = ", ".join(bw2data.databases)


@app.command()
def lcia_impacts(
    activity_name: Annotated[
        str,
        typer.Argument(help="Name of the activity (process) to look for."),
    ],
    database_name: Annotated[
        str,
        typer.Argument(
            callback=bw_database_validation,
            help=f"Brightway database containing the activity.\n\nAvailable databases are: {available_bw_databases}.",
        ),
    ],
    simapro: Annotated[
        bool,
        typer.Option(help="Get impacts from simapro instead of Brightway."),
    ] = False,
):
    """
    Get impacts about an LCIA
    """

    activity = search_one(database_name, activity_name)

    factors = get_normalization_weighting_factors(IMPACTS_JSON)
    (computed_by, impacts) = compute_impacts(
        activity,
        main_method,
        impacts_py,
        IMPACTS_JSON,
        factors,
        simapro=simapro,
    )

    logger.info(impacts.model_dump(by_alias=True))

    return (computed_by, impacts)


@app.command()
def lcia_details(
    activity_name: Annotated[
        str,
        typer.Argument(help="Name of the activity (process) to look for."),
    ],
    database_name: Annotated[
        str,
        typer.Argument(
            callback=bw_database_validation,
            help=f"Brightway database containing the activity.\n\nAvailable databases are: {available_bw_databases}.",
        ),
    ],
    impact: Annotated[
        str,
        typer.Argument(
            callback=method_impact_validation,
            help="The trigram name from the method ('acd', 'cch', …) of the impact you want to get information for.",
        ),
    ],
    simapro: bool = typer.Option(False, "--simapro", "-s"),
):
    """
    Get detailed information about an LCIA
    """

    activity = search_one(database_name, activity_name)
    method = impacts_py[impact]
    logger.info(activity)
    logger.info(method)

    print_recursive_calculation(activity, method, max_level=3)

    factors = get_normalization_weighting_factors(IMPACTS_JSON)
    impacts = compute_process_for_bw_activity(
        activity, main_method, impacts_py, IMPACTS_JSON, factors, simapro=simapro
    ).model_dump(by_alias=True)

    logger.info(impacts)


@app.command()
def compare_processes(
    first_file: Annotated[
        typer.FileText,
        typer.Argument(help="The first json file."),
    ],
    second_file: Annotated[
        typer.FileText,
        typer.Argument(help="The second json file."),
    ],
    impact: Annotated[
        Optional[List[str]],
        typer.Option(
            callback=ecobalyse_impact_validation,
            help="The trigram name ('ecs', 'etf', …) of the impact you want to compare. You can specify multiple `--impact`. If not specified, all impacts are compared.",
        ),
    ] = [],
    min: Annotated[
        float,
        typer.Option(
            help="Don't show changes more than this value in percent",
        ),
    ] = 0.1,
    with_names: Annotated[
        bool,
        typer.Option(help="Also print the process names (before and after)."),
    ] = False,
):
    """
    Compare two `processes_impacts.json` files
    """

    first_processes = json.load(first_file)
    second_processes = json.load(second_file)

    display_changes(
        "displayName",
        first_processes,
        second_processes,
        only_impacts=impact,
        min_change=min,
        with_names=with_names,
    )


@app.command()
def compare_activity(
    activity_name: Annotated[
        str,
        typer.Argument(help="Name of the activity (process) to look for in databases."),
    ],
    first_db: Annotated[
        str,
        typer.Argument(
            callback=bw_database_validation,
            help=f"First Brightway database name you want to search for the activity name.\n\nAvailable databases are: {available_bw_databases}.",
        ),
    ],
    second_db: Annotated[
        str,
        typer.Argument(
            callback=bw_database_validation,
            help=f"Second Brightway database name you want to search for the activity name.\n\nAvailable databases are: {available_bw_databases}.",
        ),
    ],
    impact: Annotated[
        str,
        typer.Argument(
            callback=method_impact_validation,
            help="The trigram name from the method ('acd', 'cch', …) of the impact you want to get information for.",
        ),
    ],
    # TODO
    simapro: Annotated[
        bool,
        typer.Option(help="Get activities from simapro."),
    ] = False,
    recursive_calculation: Annotated[
        bool,
        typer.Option(help="If using BW and not simapro, print recursive calculations."),
    ] = True,
):
    """
    Look for an activity in 2 different BW db and display the differences
    """

    factors = get_normalization_weighting_factors(IMPACTS_JSON)

    first_activity = search_one(first_db, activity_name)
    second_activity = search_one(second_db, activity_name)

    logger.info("")
    logger.info(f"### '{first_db}'")

    method = impacts_py[impact]

    if recursive_calculation:
        print_recursive_calculation(first_activity, method, max_level=5)

    first_simapro_process = compute_process_for_bw_activity(
        first_activity,
        main_method,
        impacts_py,
        IMPACTS_JSON,
        factors,
        simapro=simapro,
    ).model_dump()

    logger.info(first_simapro_process)

    logger.info("")

    logger.info(f"### '{second_db}'")
    logger.info(second_activity)

    if recursive_calculation:
        print_recursive_calculation(second_activity, method, max_level=5)

    second_simapro_process = compute_process_for_bw_activity(
        second_activity,
        main_method,
        impacts_py,
        IMPACTS_JSON,
        factors,
        simapro=simapro,
    ).model_dump()

    logger.info(second_simapro_process)

    changes = get_changes(
        first_simapro_process["impacts"],
        second_simapro_process["impacts"],
        first_activity["name"],
    )

    if len(changes) > 0:
        display_changes_table(changes)
    else:
        logger.info("No change to display")


if __name__ == "__main__":
    app()
