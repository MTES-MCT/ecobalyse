import json
import math
import os
from pathlib import Path

from ecobalyse.json import activities_processes_sort_key, export_json
from frozendict import deepfreeze
from rich.console import Console
from rich.table import Table

from config import DATA_ROOT_DIR, settings
from ecobalyse_data.logging import logger

from . import remove_detailed_impacts


def export_json_with_sort_and_precision(data, path):
    export_json(
        data,
        path,
        sort_fn=activities_processes_sort_key,
        number_precision=settings.number_precision,
    )


def export_json_with_precision(data, path):
    export_json(data, path, number_precision=settings.number_precision)


with open(DATA_ROOT_DIR / settings.impacts_file) as f:
    IMPACTS_JSON = deepfreeze(json.load(f))


def validate_id(id: str) -> str:
    # Check the id is lowercase and does not contain space
    if id.lower() != id or id.replace(" ", "") != id:
        raise ValueError(f"This identifier is not lowercase or contains spaces: {id}")
    return id


def show_change(old: str, new: str) -> str:
    return (old + "\n-> " + new) if old != new else "(unchanged) " + old


def get_changes(old, new, name, only_impacts=None, min_change=0.1, with_names=False):
    if only_impacts is None:
        only_impacts = []
    changes = []
    for trigram in new["impacts"]:
        if only_impacts and trigram not in only_impacts:
            continue

        if old["impacts"].get(trigram, {}):
            # Convert values to float before calculation
            old_value = float(old["impacts"][trigram])
            new_value = float(new["impacts"][trigram])

            if old_value == 0 and new_value == 0:
                percent_change = 0
            elif old_value == 0:
                percent_change = math.inf
            else:
                percent_change = 100 * (new_value - old_value) / old_value

            percent_change = round(percent_change, 1)

            if abs(percent_change) > min_change:
                changes.append(
                    {
                        "trg": trigram,
                        "name": name,
                        "%diff": percent_change,
                        "from": old_value,
                        "to": new_value,
                        "DB change": show_change(old["source"], new["source"]),
                        **(
                            {
                                "Process change": show_change(
                                    old["sourceId"], new["sourceId"]
                                )
                            }
                            if with_names
                            else {}
                        ),
                    }
                )

    return changes


def display_changes_table(changes, sort_by_key="%diff", with_names=False):
    changes.sort(key=lambda c: c[sort_by_key])
    table = Table(title="Review changes", show_header=True, show_footer=True)

    table.add_column("trg", "trg", style="cyan", no_wrap=True)
    table.add_column("displayName", "displayName", style="magenta")
    table.add_column("diff (%)", "diff (%)")
    table.add_column("from", "from", style="green")
    table.add_column("to", "to", style="red")
    table.add_column("DB change", "DB change")
    if with_names:
        table.add_column("Process change", "Process change")

    for change in changes:
        table.add_row(*[str(value) for value in change.values()])

    console = Console()
    console.print(table)


def display_changes(
    key,
    oldprocesses,
    processes,
    only_impacts=None,
    min_change=0.1,
    with_names=False,
):
    """Display a nice sorted table of impact changes to review
    key is the field to display (id for food, uuid for textile)"""
    if only_impacts is None:
        only_impacts = []
    old = {str(p[key]): p for p in oldprocesses if key in p}

    if type(processes) is list:
        # Be sure to convert to str if we have an UUID for the key
        processes = {str(p[key]): p for p in processes if key in p}

    review = False
    changes = []
    for id_, p in processes.items():
        # Skip if the id doesn't exist in old processes
        if id_ not in old:
            continue
        impact_changes = get_changes(
            old=old[id_],
            new=p,
            name=p["displayName"],
            only_impacts=only_impacts,
            min_change=min_change,
            with_names=with_names,
        )

        if len(impact_changes) > 0:
            changes = changes + impact_changes
            review = True

    changes.sort(key=lambda c: abs(c["%diff"]))

    if review:
        display_changes_table(changes, with_names=with_names)


def display_changes_from_json(
    processes_impacts_path,
    processes_corrected_impacts,
    dir,
):
    processes_impacts = os.path.join(dir, processes_impacts_path)

    if os.path.isfile(processes_impacts):
        # Load old processes for comparison
        oldprocesses = load_json(processes_impacts)

        # Display changes
        display_changes("id", oldprocesses, processes_corrected_impacts)


def export_processes_to_dir(
    processes_ecs_path,
    processes_impacts_path,
    processes_ecs_impacts,
    dir_to_export_to: Path,
    full_impacts_relative_file_path,
    extra_data=None,
    extra_path=None,
    merge=False,
    scopes=None,
):
    exported_files = []

    logger.info("")
    logger.info(f"-> Exporting to {dir}")
    processes_impacts_absolute_path = dir_to_export_to / processes_impacts_path
    processes_ecs_absolute_path = dir_to_export_to / processes_ecs_path

    if extra_data is not None and extra_path is not None:
        extra_file = dir_to_export_to / extra_path
        export_json_with_sort_and_precision(
            extra_data,
            extra_file,
        )
        exported_files.append(extra_file)

    # Export results
    if type(processes_ecs_impacts) is not list:
        to_export = list(processes_ecs_impacts.values())
    else:
        to_export = processes_ecs_impacts

    # If merge is true, we don't overwrite the existing file but merge the new processes with the existing ones
    if merge and scopes and os.path.exists(processes_impacts_absolute_path):
        logger.info(
            f"-> Merging with existing processes file {processes_impacts_absolute_path}"
        )
        with open(processes_impacts_absolute_path, "r") as f:
            existing_processes = json.load(f)

        # delete all existing processes with a scope in scopes
        existing_processes = [
            p
            for p in existing_processes
            if not any(s.value in p["scopes"] for s in scopes)
        ]

        # add the new processes to the existing processes
        to_export = existing_processes + to_export

    # Sort processes
    to_export.sort(key=activities_processes_sort_key)

    # Filter out generic-scope-only processes and trim scopes for mixed ones
    from models.process import (
        GENERIC_SCOPES,  # local import to avoid circular dependency
    )

    filtered = []
    for p in to_export:
        proc_scopes = set(p.get("scopes", []))
        if proc_scopes <= GENERIC_SCOPES:
            continue
        if proc_scopes & GENERIC_SCOPES:
            p = {
                **p,
                "scopes": [s for s in p["scopes"] if s not in GENERIC_SCOPES],
            }
        filtered.append(p)

    export_json_with_precision(
        filtered,
        processes_impacts_absolute_path,
    )
    exported_files.append(processes_impacts_absolute_path)

    # Also update the aggregated file
    export_json_with_precision(
        remove_detailed_impacts(filtered),
        processes_ecs_absolute_path,
    )
    exported_files.append(processes_ecs_absolute_path)

    # Write unfiltered data to last dir (local) for generic export to read later

    full_impacts_path = (
        DATA_ROOT_DIR / settings.export_dir / full_impacts_relative_file_path
    )
    export_json_with_precision(to_export, full_impacts_path)

    return exported_files


def load_json(filename):
    """
    Load JSON data from a file.
    """
    with open(filename, "r") as file:
        return json.load(file)
