import json
import math
import os

import matplotlib.pyplot
import numpy
from frozendict import deepfreeze
from rich.console import Console
from rich.table import Table

from config import PROJECT_ROOT_DIR, settings
from ecobalyse_data.logging import logger

from . import (
    FormatNumberJsonEncoder,
    activities_processes_sort_key,
    get_normalization_weighting_factors,
    remove_detailed_impacts,
)

with open(PROJECT_ROOT_DIR / settings.impacts_file) as f:
    IMPACTS_JSON = deepfreeze(json.load(f))


def validate_id(id: str) -> str:
    # Check the id is lowercase and does not contain space
    if id.lower() != id or id.replace(" ", "") != id:
        raise ValueError(f"This identifier is not lowercase or contains spaces: {id}")
    return id


def show_change(old: str, new: str) -> str:
    return (old + "\n-> " + new) if old != new else "(unchanged) " + old


def get_changes(old, new, name, only_impacts=[], min_change=0.1, with_names=False):
    changes = []
    for trigram in new["impacts"]:
        if trigram not in only_impacts:
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

            if abs(percent_change) > min_change:
                changes.append(
                    {
                        "trg": trigram,
                        "name": name,
                        "%diff": round(percent_change, 1),
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
    only_impacts=[],
    min_change=0,
    with_names=False,
):
    """Display a nice sorted table of impact changes to review
    key is the field to display (id for food, uuid for textile)"""
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
            new=processes[id_],
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


def plot_impacts(process_name, impacts_smp, impacts_bw, folder, impacts_py):
    trigrams = [
        t
        for t in impacts_py.keys()
        if t in impacts_smp.keys() and t in impacts_bw.keys()
    ]
    factors = get_normalization_weighting_factors(impacts_py)

    simapro_values = [
        impacts_smp.get(t, 0) / factors["ecs_normalizations"][t] for t in trigrams
    ]
    brightway_values = [
        impacts_bw.get(t, 0) / factors["ecs_normalizations"][t] for t in trigrams
    ]

    x = numpy.arange(len(trigrams))
    width = 0.35

    fig, ax = matplotlib.pyplot.subplots(figsize=(12, 8))

    ax.bar(x - width / 2, simapro_values, width, label="SimaPro")
    ax.bar(x + width / 2, brightway_values, width, label="Brightway")

    ax.set_xlabel("Impact Categories")
    ax.set_ylabel("Impact Values (normalized, non weighted)")
    ax.set_title(f"Environmental Impacts for {process_name}")
    ax.set_xticks(x)
    ax.set_xticklabels(trigrams, rotation=90)
    ax.legend()

    matplotlib.pyplot.tight_layout()
    filepath = f"{folder}/{process_name.replace('/', '_')}.png"
    matplotlib.pyplot.savefig(filepath)
    logger.info(f"Saved impact comparison plot to {filepath}")
    matplotlib.pyplot.close()


def export_json(json_data, filename):
    logger.info(f"Exporting {filename}")
    json_string = json.dumps(
        json_data,
        indent=2,
        ensure_ascii=False,
        cls=FormatNumberJsonEncoder,
        sort_keys=True,
    )
    with open(filename, "w", encoding="utf-8") as file:
        file.write(json_string)
        file.write("\n")  # Add a newline at the end of the file

    logger.info(f"Exported {len(json_data)} elements to {filename}")


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


def export_processes_to_dirs(
    processes_aggregated_path,
    processes_impacts_path,
    processes_aggregated_impacts,
    dirs,
    extra_data=None,
    extra_path=None,
    merge=False,
    scopes=None,
):
    exported_files = []

    for dir in dirs:
        logger.info("")
        logger.info(f"-> Exporting to {dir}")
        processes_impacts_absolute_path = os.path.join(dir, processes_impacts_path)
        processes_aggregated_absolute_path = os.path.join(
            dir, processes_aggregated_path
        )

        if extra_data is not None and extra_path is not None:
            extra_file = os.path.join(dir, extra_path)
            export_json(extra_data, extra_file)
            exported_files.append(extra_file)

        # Export results
        if type(processes_aggregated_impacts) is not list:
            to_export = list(processes_aggregated_impacts.values())
        else:
            to_export = processes_aggregated_impacts

        # If merge is true, we don't overwrite the existing file but merge the new processes with the existing ones
        if merge and scopes:
            if os.path.exists(processes_impacts_absolute_path):
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

        export_json(filtered, processes_impacts_absolute_path)
        exported_files.append(processes_impacts_absolute_path)

        # Also update the aggregated file
        export_json(
            remove_detailed_impacts(filtered), processes_aggregated_absolute_path
        )
        exported_files.append(processes_aggregated_absolute_path)

    # Write unfiltered data to last dir (local) for generic export to read later
    full_impacts_path = os.path.join(dirs[-1], "processes_impacts_full.json")
    export_json(to_export, full_impacts_path)

    return exported_files


def load_json(filename):
    """
    Load JSON data from a file.
    """
    with open(filename, "r") as file:
        return json.load(file)
