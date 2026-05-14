#!/usr/bin/env python3

import multiprocessing
from multiprocessing import Pool
from typing import List, Optional

import bw2data
import orjson
import typer
from bw2data.project import projects
from typing_extensions import Annotated

from common import (
    get_normalization_weighting_factors,
)
from common.export import IMPACTS_JSON
from common.impacts import impacts as impacts_py
from common.impacts import main_method
from config import settings
from ecobalyse_data.computation import compute_process_for_bw_activity
from ecobalyse_data.logging import logger

# Init BW project
projects.set_current(settings.bw.project)
available_bw_databases = ", ".join(bw2data.databases)


def main(
    output_file: Annotated[
        typer.FileBinaryWrite,
        typer.Argument(help="The output json file."),
    ],
    # Use half the cores to avoid locking the system. Also look at the the .env.sample file
    # where environment variables are used to change the behaviour of some computing libs
    cpu_count: Annotated[
        Optional[int],
        typer.Option(
            help="The number of CPUs/cores to use for computation. Default to MAX/2."
        ),
    ] = max(multiprocessing.cpu_count() // 2, 1),
    max: Annotated[
        int,
        typer.Option(
            help="Number of max activity to compute the impacts for (per DB). Useful for testing purpose. Negative value means all activities."
        ),
    ] = -1,
    db: Annotated[
        Optional[List[str]],
        typer.Option(
            help="Brightway databases you want to computate impacts for. Default to all. You can specify multiple `--db`.",
        ),
    ] = [],
    project: Annotated[
        Optional[str],
        typer.Option(
            help=f"Brightway project name. Default to {settings.bw.project}.",
        ),
    ] = settings.bw.project,
    activity_name: Annotated[
        Optional[str],
        typer.Option(
            help="Brightway activity name",
        ),
    ] = None,
    location: Annotated[
        Optional[str],
        typer.Option(
            help="Location of the LCI (Country code like FR, BE, DE, or region like GLO, RoW, RER, etc.).",
        ),
    ] = None,
    multiprocessing: Annotated[
        bool,
        typer.Option(help="Use multiprocessing for faster computation."),
    ] = True,
):
    """
    Compute the detailed impacts for all the databases in the default Brightway project.

    You can specify the number of CPUs to be used for computation by specifying CPU_COUNT argument.
    """

    # Init BW project
    projects.set_current(project)

    all_impacts = {}

    # Get specified dbs or default to all BW databases
    databases = db if db else bw2data.databases

    nb_processes = 0

    factors = get_normalization_weighting_factors(IMPACTS_JSON)

    for database_name in databases:
        logger.info(f"-> Exploring DB '{database_name}'")

        db = bw2data.Database(database_name)

        with Pool(cpu_count) as pool:
            activities_parameters = []
            nb_activity = 0

            logger.info(
                f"-> Computing impacts for {len(db)} activities, using {cpu_count} cores, hold on, it will take a while…"
            )
            for activity in db:
                if "process" in activity.get("type") and (max < 0 or nb_activity < max):
                    if activity_name is None or (
                        activity_name is not None
                        and activity_name == activity.get("name")
                    ):
                        activities_parameters.append(
                            # Parameters of the `get_process_with_impacts` function
                            (
                                activity,
                                main_method,
                                impacts_py,
                                IMPACTS_JSON,
                                factors,
                                False,
                            )
                        )
                        nb_activity += 1

            processes_with_impacts = []
            if multiprocessing:
                processes_with_impacts = pool.starmap(
                    compute_process_for_bw_activity, activities_parameters
                )
                processes_with_impacts = [
                    p.model_dump(by_alias=True, exclude={"bw_activity"})
                    for p in processes_with_impacts
                ]
            else:
                for activity_parameters in activities_parameters:
                    processes_with_impacts.append(
                        compute_process_for_bw_activity(
                            *activity_parameters
                        ).model_dump(by_alias=True, exclude={"bw_activity"})
                    )

            logger.info(
                f"-> Computed impacts for {len(processes_with_impacts)} processes in '{database_name}'"
            )

            all_impacts[database_name] = processes_with_impacts
            nb_processes += len(processes_with_impacts)

    db_names = ", ".join([f"'{db}'" for db in databases])

    logger.info(
        f"-> Finished computing impacts for {nb_processes} processes in {len(databases)} databases: {db_names}"
    )

    output_file.write(
        orjson.dumps(all_impacts, option=orjson.OPT_INDENT_2 | orjson.OPT_SORT_KEYS)
    )


if __name__ == "__main__":
    typer.run(main)
