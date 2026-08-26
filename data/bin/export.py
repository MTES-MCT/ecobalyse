#!/usr/bin/env python3

import json
import logging
import multiprocessing
from enum import Enum
from pathlib import Path
from typing import Annotated

import typer
from bw2data.project import projects
from ecobalyse.logging import logger

from bin.generate_taxonomy_with_aliases import write_taxonomy_with_aliases
from config import DATA_ROOT_DIR, settings
from ecobalyse_data.export import export_generic
from ecobalyse_data.export import food as export_food
from ecobalyse_data.export import process as export_process
from ecobalyse_data.export import textile as export_textile
from models.process import GENERIC_SCOPES, Scope

app = typer.Typer(pretty_exceptions_show_locals=False)


class MetadataScope(str, Enum):
    food = "food"
    textile = "textile"
    generic = "generic"


@app.command()
def metadata(
    scopes: Annotated[
        list[MetadataScope] | None,
        typer.Option(help="The scope to export. If not specified, exports all scopes."),
    ] = None,
    verbose: bool = typer.Option(False, "--verbose", "-v"),
    cpu_count: Annotated[
        int,
        typer.Option(
            help="The number of CPUs/cores to use for computation. Default to MAX/2."
        ),
    ] = max(multiprocessing.cpu_count() // 2, 1),
    root_dir: Path = DATA_ROOT_DIR,
    write_taxonomy: bool = True,
):
    """
    Export metadata files (materials.json, ingredients.json, …)
    """
    if scopes is None:
        scopes = [MetadataScope.textile, MetadataScope.food, MetadataScope.generic]
    if verbose:
        logger.setLevel(logging.DEBUG)

    # Metadata (materials/ingredients) is written both to the published dir and the local data dir

    activities = _get_lcis(root_dir)

    if write_taxonomy:
        write_taxonomy_with_aliases(
            taxonomy_with_aliases_path=root_dir
            / settings.scopes.food.dirname
            / settings.scopes.food.taxonomy_with_aliases_file
        )

    processes_impacts_path = (
        root_dir / settings.export_dir / settings.processes_legacy_impacts_full_file
    )

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
                materials_path=root_dir
                / settings.frontend_data_dir
                / scope_dirname
                / settings.scopes.textile.materials_file,
            )

        elif s == MetadataScope.food:
            # Export food ingredients
            activities_food_ingredients = [
                a
                for a in activities
                if scope_dirname in a.get("scopes", [])
                and "ingredient" in a.get("categories", [])
            ]
            ingredients_path = (
                root_dir
                / settings.frontend_data_dir
                / scope_dirname
                / settings.scopes.food.ingredients_file
            )

            export_food.activities_to_ingredients_json(
                activities_food_ingredients,
                processes_impacts_path=processes_impacts_path,
                ingredients_path=ingredients_path,
                ecosystemic_factors_path=ecosystemic_factors_path,
                feed_file_path=feed_file_path,
                raw_to_transformed_file_path=raw_to_transformed_file_path,
            )

        elif s == MetadataScope.generic:
            # Export all generic processes (object + veli + food2) to processes_generic.json
            generic_activities = [
                activity
                for activity in activities
                if GENERIC_SCOPES & set(activity["scopes"])
            ]

            export_dir = root_dir / settings.export_dir

            export_generic.activities_to_processes_generic_json(
                generic_activities,
                processes_impacts_path=processes_impacts_path,
                ecs_output_paths=[export_dir / settings.processes_generic_ecs_file],
                impacts_output_paths=[
                    export_dir / settings.processes_generic_impacts_file
                ],
                cpu_count=cpu_count,
                ecosystemic_factors_path=ecosystemic_factors_path,
                feed_file_path=feed_file_path,
                raw_to_transformed_file_path=raw_to_transformed_file_path,
            )


@app.command()
def processes_legacy(
    scopes: Annotated[
        list[Scope] | None,
        typer.Option(help="The scope to export. If not specified, exports all scopes."),
    ] = None,
    display_changes: Annotated[
        bool,
        typer.Option(help="Display changes with old processes."),
    ] = True,
    merge: bool = typer.Option(False, "--merge", "-m"),
    verbose: bool = typer.Option(False, "--verbose", "-v"),
    root_dir: Path = DATA_ROOT_DIR,
):
    """
    Export processes. If scope is specified, only exports processes for that scope.
    """
    if verbose:
        logger.setLevel(logging.DEBUG)

    activities = _get_lcis(root_dir)

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
        ecs_relative_file_path=settings.processes_legacy_ecs_file,
        impacts_relative_file_path=settings.processes_legacy_impacts_file,
        full_impacts_relative_file_path=settings.processes_legacy_impacts_full_file,
        dir_to_export_to=root_dir / settings.export_dir,
        display_changes=display_changes,
        merge=merge,
        scopes=scopes,
    )


@app.command()
def merge_processes(
    root_dir: Path = DATA_ROOT_DIR,
):
    """take legacy and generic processes from export_dir and merge them, put the merged file in public_dir"""
    from ecobalyse.json import export_json

    from common import remove_detailed_impacts
    from common.export import load_json

    export_dir = root_dir / settings.export_dir
    impacts = load_json(export_dir / settings.processes_legacy_impacts_file)
    generic_impacts = load_json(export_dir / settings.processes_generic_impacts_file)
    merged = impacts + generic_impacts
    merged_ecs = remove_detailed_impacts(merged)

    public_dir = root_dir / settings.frontend_data_dir

    export_json(merged, public_dir / settings.processes_merged_impacts_file)
    export_json(merged_ecs, public_dir / settings.processes_merged_ecs_file)


def _get_lcis(root_dir):
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
