#!/usr/bin/env python3

import json
import logging
import multiprocessing
from enum import Enum
from pathlib import Path
from typing import List, Optional

import typer
from bw2data.project import projects
from typing_extensions import Annotated

from config import PROJECT_ROOT_DIR, settings
from ecobalyse_data.export import export_generic
from ecobalyse_data.export import food as export_food
from ecobalyse_data.export import process as export_process
from ecobalyse_data.export import textile as export_textile
from ecobalyse_data.logging import logger
from models.process import GENERIC_SCOPES, Scope

app = typer.Typer(pretty_exceptions_show_locals=False)


class MetadataScope(str, Enum):
    food = "food"
    textile = "textile"
    generic = "generic"


@app.command()
def metadata(
    scopes: Annotated[
        Optional[List[MetadataScope]],
        typer.Option(help="The scope to export. If not specified, exports all scopes."),
    ] = [MetadataScope.textile, MetadataScope.food, MetadataScope.generic],
    verbose: bool = typer.Option(False, "--verbose", "-v"),
    cpu_count: Annotated[
        Optional[int],
        typer.Option(
            help="The number of CPUs/cores to use for computation. Default to MAX/2."
        ),
    ] = max(multiprocessing.cpu_count() // 2, 1),
    root_dir: Path = PROJECT_ROOT_DIR,
):
    """
    Export metadata files (materials.json, ingredients.json, …)
    """
    if verbose:
        logger.setLevel(logging.DEBUG)

    dirs_to_export_to = [settings.output_dir]

    if settings.LOCAL_EXPORT:
        dirs_to_export_to.append(root_dir / "public" / "data")

    activities = _get_lcias(root_dir)

    for s in scopes:
        scope_dirname = settings.scopes.get(s.value).dirname
        es_files_path = root_dir / scope_dirname

        feed_file_path = es_files_path / settings.scopes.food.feed_file

        ecosystemic_factors_path = (
            es_files_path / settings.scopes.food.ecosystemic_factors_file
        )
        raw_to_transformed_file_path = (
            es_files_path / settings.scopes.food.raw_to_transformed_ratios_file
        )

        if s == MetadataScope.textile:
            # Export textile materials
            activities_textile_materials = [
                a
                for a in activities
                if scope_dirname in a.get("scopes", [])
                and "textile_material" in a.get("categories", [])
            ]

            export_textile.activities_to_materials_json(
                activities_textile_materials,
                materials_paths=[
                    root_dir / dir / scope_dirname / "materials.json"
                    for dir in dirs_to_export_to
                ],
            )

        elif s == MetadataScope.food:
            # Export food ingredients
            activities_food_ingredients = [
                a
                for a in activities
                if scope_dirname in a.get("scopes", [])
                and "ingredient" in a.get("categories", [])
            ]
            ingredients_paths = [
                root_dir / dir / scope_dirname / "ingredients.json"
                for dir in dirs_to_export_to
            ]

            export_food.activities_to_ingredients_json(
                activities_food_ingredients,
                ingredients_paths=ingredients_paths,
                ecosystemic_factors_path=ecosystemic_factors_path,
                feed_file_path=feed_file_path,
                raw_to_transformed_file_path=raw_to_transformed_file_path,
                cpu_count=cpu_count,
            )

        elif s == MetadataScope.generic:
            # Export all generic processes (object + veli + food2) to processes_generic.json
            generic_activities = [
                activity
                for activity in activities
                if GENERIC_SCOPES & set(activity["scopes"])
            ]

            export_generic.activities_to_processes_generic_json(
                generic_activities,
                processes_impacts_path=root_dir
                / dirs_to_export_to[-1]  # last dir is local dir
                / settings.processes_impacts_full_file,
                aggregated_output_paths=[
                    root_dir / dir / "processes_generic.json"
                    for dir in dirs_to_export_to
                ],
                impacts_output_paths=[
                    root_dir / dir / "processes_generic_impacts.json"
                    for dir in dirs_to_export_to
                ],
                cpu_count=cpu_count,
                ecosystemic_factors_path=ecosystemic_factors_path,
                feed_file_path=feed_file_path,
                raw_to_transformed_file_path=raw_to_transformed_file_path,
            )


@app.command()
def processes(
    scopes: Annotated[
        Optional[List[Scope]],
        typer.Option(help="The scope to export. If not specified, exports all scopes."),
    ] = None,
    graph_folder: Annotated[
        Optional[Path],
        typer.Option(help="The graph output path."),
    ] = PROJECT_ROOT_DIR / "graphs",
    display_changes: Annotated[
        bool,
        typer.Option(help="Display changes with old processes."),
    ] = True,
    simapro: Annotated[
        bool,
        typer.Option(help="Use simapro"),
    ] = False,
    plot: bool = typer.Option(False, "--plot", "-p"),
    merge: bool = typer.Option(False, "--merge", "-m"),
    verbose: bool = typer.Option(False, "--verbose", "-v"),
    root_dir: Path = PROJECT_ROOT_DIR,
):
    """
    Export processes. If scope is specified, only exports processes for that scope.
    """
    if verbose:
        logger.setLevel(logging.DEBUG)

    dirs_to_export_to = [settings.output_dir]
    should_plot = settings.plot_export

    # Override config if cli parameter is present
    if plot:
        should_plot = True

    if settings.local_export:
        dirs_to_export_to.append(root_dir / "public" / "data")

    activities = _get_lcias(root_dir)

    # Filter activities by scope if specified
    if scopes:
        activities = [
            a for a in activities if any(s.value in a.get("scopes", []) for s in scopes)
        ]
        logger.info(
            f"-> Filtered activities to scopes: {scopes}, activities remaining: {len(activities)}"
        )

    export_process.activities_to_processes(
        activities=activities,
        aggregated_relative_file_path=settings.processes_aggregated_file,
        impacts_relative_file_path=settings.processes_impacts_file,
        dirs_to_export_to=dirs_to_export_to,
        plot=should_plot,
        graph_folder=graph_folder,
        display_changes=display_changes,
        simapro=simapro,
        merge=merge,
        scopes=scopes,
    )


def _get_lcias(root_dir):
    lci_catalog = root_dir / "lci_catalog"
    logger.debug(f"-> Loading lci_catalog {lci_catalog}")

    activities = []
    for lci_path in lci_catalog.glob("*/*.json"):
        if lci_path.is_file():
            with open(lci_path, "r") as file:
                activities.append(json.load(file))
    return activities


if __name__ == "__main__":
    projects.set_current(settings.bw.project)
    app()
