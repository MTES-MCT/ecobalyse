#!/usr/bin/env python3

import json
import urllib.parse
from typing import List, Optional

import bw2calc
import bw2data
import requests
from bw2data import get_multilca_data_objs
from bw2data.project import projects

from common import (
    bytrigram,
    calculate_aggregate,
    correct_process_impacts,
    fix_unit,
    spproject,
    with_subimpacts,
)
from config import settings
from ecobalyse_data.bw.search import cached_search_one
from ecobalyse_data.logging import logger
from models.process import ComputedBy, Impacts, Process

# Init BW project
projects.set_current(settings.bw.project)
available_bw_databases = ", ".join(bw2data.databases)


def check_duplicate_activities(activities: List[dict]) -> None:
    """
    Check for duplicate activities based on source + activityName + location.
    Raises ValueError if duplicates are found.
    """
    keys = []
    for activity in activities:
        # Skip activities with hardcoded impacts (source = "Custom") as they don't reference a BW activity
        if activity.get("impacts"):
            continue
        key = (
            activity.get("source"),
            activity.get("activityName"),
            activity.get("location"),
        )
        keys.append((key, activity.get("displayName")))

    key_counts = {}
    for key, _ in keys:
        key_counts[key] = key_counts.get(key, 0) + 1

    duplicates = [(key, count) for key, count in key_counts.items() if count > 1]

    if duplicates:
        error_messages = []
        for key, count in duplicates:
            source, activity_name, location = key
            # Find displayNames for this duplicate key
            display_names = [dn for k, dn in keys if k == key]
            error_messages.append(
                f"  - source='{source}', activityName='{activity_name}', location='{location}' "
                f"appears {count} times with displayNames: {display_names}"
            )
        raise ValueError(
            "Duplicate activities found in the lci files:\n" + "\n".join(error_messages)
        )


def compute_process_for_bw_activity(
    bw_activity,
    main_method,
    impacts_py,
    impacts_json,
    factors,
    simapro=False,
) -> Optional[Process]:
    """Compute a process when we have only have a brightway activity (bw_activity),
    no eco_activity (an activity in lci_activity/*)"""
    computed_by = None
    impacts = {}

    (computed_by, impacts) = compute_impacts(
        bw_activity,
        main_method,
        impacts_py,
        impacts_json,
        factors,
        simapro=simapro,
    )

    process = activity_to_process_with_impacts(
        # Create a minimal eco_activity dict since we only have a bw_activity
        # the id here is a placeholder
        eco_activity={
            "source": bw_activity.get("database"),
            "displayName": bw_activity.get("name", "Unknown activity"),
            "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        },
        impacts=impacts,
        computed_by=computed_by,
        bw_activity=bw_activity,
    )

    return process


def compute_process_for_activity(
    eco_activity,
    bw_activity,
    main_method,
    impacts_py,
    impacts_json,
    factors,
    simapro=False,
) -> Process:
    """Compute a process when we have an ecobalyse activity (eco_activity in lci_activity/*) and a brightway activity (bw_activity)"""
    computed_by = None
    impacts = eco_activity.get("impacts")

    # For packaging activities with unit="item", use production amount as demand.
    # This ensures we compute impacts for 1 item (e.g., 1 packaging system (pot+lid+cardboard tray)).
    # Example: "Rillettes, 220g | Packaging System, N0, All, PP pot {FR} U" has production_amount=0.22 kg, the amount of rillettes it contains.
    # We want impacts for 1 packaging system (pot+lid+cardboard tray) packaging 220g of rillettes, not for packaging 1 kg of rillettes.
    # "massPerUnit": 0.044 kg = 44g is the mass of the packaging system (pot+lid+cardboard tray), it's irrelevant here.
    demand_amount = None
    is_packaging = "packaging" in eco_activity.get("categories", [])
    if is_packaging and eco_activity.get("unit") == "item":
        demand_amount = bw_activity["production amount"]

    # Impacts are not hardcoded, we should compute them
    if not impacts:
        (computed_by, impacts) = compute_impacts(
            bw_activity,
            main_method,
            impacts_py,
            impacts_json,
            factors,
            simapro=simapro,
            demand_amount=demand_amount,
        )
    else:
        # Impacts are harcoded, we just need to compute the agregated impacts
        impacts["ecs"] = calculate_aggregate("ecs", impacts, factors)
        computed_by = ComputedBy.hardcoded

    process = activity_to_process_with_impacts(
        eco_activity=eco_activity,
        impacts=impacts,
        computed_by=computed_by,
        bw_activity=bw_activity,
    )

    return process


def _demand_amount_for(eco_activity, bw_activity):
    is_packaging = "packaging" in eco_activity.get("categories", [])
    if is_packaging and eco_activity.get("unit") == "item":
        return bw_activity["production amount"]
    pa = bw_activity["production amount"]
    return (pa > 0) - (pa < 0)


def compute_brightway_impacts_batch(
    bw_activities,
    demand_amounts,
    main_method,
    impacts_py,
    chunk_size: int = 50,
) -> dict:
    """Compute raw (uncorrected, no subimpacts, no aggregate) brightway impacts for many
    activities at once via MultiLCA. Returns {bw_activity.id: {impact_key: float}}.

    Matches compute_brightway_impacts numerically: each demand is {act.id: demand_amount}.
    Chunked because MultiLCA's spsolve degrades past ~200 demands."""
    method_config = {"impact_categories": [tuple(m) for m in impacts_py.values()]}
    method_to_key = {tuple(m): k for k, m in impacts_py.items()}

    out = {}
    total = len(bw_activities)
    for i in range(0, len(bw_activities), chunk_size):
        chunk_acts = bw_activities[i : i + chunk_size]
        chunk_amts = demand_amounts[i : i + chunk_size]
        logger.info(
            f"-> compute brightway impacts: chunk {i // chunk_size + 1}/"
            f"{(total + chunk_size - 1) // chunk_size} ({len(chunk_acts)} activities)"
        )
        # Use the bw_activity id as the demand key (string).
        demands = {str(a.id): {a.id: amt} for a, amt in zip(chunk_acts, chunk_amts)}
        data_objs = get_multilca_data_objs(
            functional_units=demands, method_config=method_config
        )
        mlca = bw2calc.MultiLCA(
            demands=demands, method_config=method_config, data_objs=data_objs
        )
        mlca.lci()
        mlca.lcia()
        per_demand: dict = {a.id: {} for a in chunk_acts}
        for (method_t, fu_name), ci in mlca.characterized_inventories.items():
            act_id = int(fu_name)
            per_demand[act_id][method_to_key[tuple(method_t)]] = float(
                "{:.10g}".format(ci.sum())
            )
        out.update(per_demand)
    return out


def compute_processes_for_activities(
    activities: List[dict],
    main_method,
    impacts_py,
    impacts_json,
    factors,
    simapro=False,
) -> List[Process]:
    # Check for duplicate activities before processing
    check_duplicate_activities(activities)

    processes: List[Process] = []

    index = 1
    total = len(activities)

    computation_parameters = []
    logger.info("Preparing processes from activities")
    for eco_activity in activities:
        logger.debug(
            f"-> [{index}/{total}] Preparing parameters for '{eco_activity.get('displayName')}'"
        )
        index += 1

        bw_activity = {}

        if not eco_activity.get(
            "impacts"
        ):  # Only need to search if impacts aren't hardcoded
            bw_activity = cached_search_one(
                eco_activity["source"],
                eco_activity["activityName"],
                location=eco_activity.get("location"),
            )

        computation_parameters.append(
            # Parameters of the `get_process_with_impacts` function
            (
                eco_activity,
                bw_activity,
                main_method,
                impacts_py,
                impacts_json,
                factors,
                False if eco_activity["source"] == "Ecobalyse" else simapro,
            )
        )

    # Batch all non-simapro, non-hardcoded BW computations through MultiLCA.
    # This is dramatically faster than per-activity LCA (~10x in benchmarks) because
    # the technosphere matrix is built once per chunk and the linear system is solved
    # for many demands and impact categories at once.
    batch_indices = []
    batch_acts = []
    batch_amts = []
    for idx, params in enumerate(computation_parameters):
        eco_activity, bw_activity, _, _, _, _, eff_simapro = params
        if eco_activity.get("impacts"):
            continue  # hardcoded
        if eff_simapro:
            continue  # leave simapro path to per-activity flow
        if not bw_activity:
            continue
        batch_indices.append(idx)
        batch_acts.append(bw_activity)
        batch_amts.append(_demand_amount_for(eco_activity, bw_activity))

    batched_raw = {}
    if batch_acts:
        logger.info(
            f"Computing brightway impacts in batch via MultiLCA ({len(batch_acts)} activities)"
        )
        batched_raw = compute_brightway_impacts_batch(
            batch_acts, batch_amts, main_method, impacts_py
        )

    batched_set = set(batch_indices)
    corrections = {
        k: v["correction"] for (k, v) in impacts_json.items() if "correction" in v
    }

    for idx, parameters in enumerate(computation_parameters):
        if idx in batched_set:
            eco_activity, bw_activity, _, _, _, _, _ = parameters
            raw = batched_raw.get(bw_activity.id)
            if raw is None:
                # Fallback to per-activity if batch lost it for any reason.
                processes.append(compute_process_for_activity(*parameters))
                continue
            impacts = with_subimpacts(dict(raw))
            correct_process_impacts(impacts, corrections)
            impacts["ecs"] = calculate_aggregate("ecs", impacts, factors)
            process = activity_to_process_with_impacts(
                eco_activity=eco_activity,
                impacts=Impacts(**impacts),
                computed_by=ComputedBy.brightway,
                bw_activity=bw_activity,
            )
            processes.append(process)
        else:
            processes.append(compute_process_for_activity(*parameters))

    return processes


def compute_impacts(
    bw_activity,
    main_method,
    impacts_py,
    impacts_json,
    normalization_factors,
    simapro=False,
    with_aggregated=True,
    demand_amount=None,
) -> tuple[Optional[ComputedBy], Optional[Impacts]]:
    computed_by = None
    try:
        impacts = {}

        # Try to compute impacts using Simapro
        if simapro:
            logger.debug(f"-> Getting impacts from Simapro for {bw_activity}")
            impacts = compute_simapro_impacts(bw_activity, main_method, impacts_py)

            if not impacts:
                raise ValueError(
                    f"-> Impacts retrieval from Simapro failed for {bw_activity}"
                )

            unit = fix_unit(bw_activity.get("unit"))

            # WARNING assume remote is in m3 or kWh (couldn't find unit from COM intf)
            if unit == "kWh":
                impacts = {k: v * 3.6 for k, v in impacts.items()}
            elif unit == "L":
                impacts = {k: v / 1000 for k, v in impacts.items()}

            computed_by = ComputedBy.simapro
        else:
            logger.debug(f"-> Getting impacts from BW for {bw_activity}")
            impacts = compute_brightway_impacts(
                bw_activity, main_method, impacts_py, demand_amount
            )

            computed_by = ComputedBy.brightway

        impacts = with_subimpacts(impacts)

        corrections = {
            k: v["correction"] for (k, v) in impacts_json.items() if "correction" in v
        }
        # This function directly mutate the impacts dicts…
        correct_process_impacts(impacts, corrections)

        if with_aggregated:
            impacts["ecs"] = calculate_aggregate("ecs", impacts, normalization_factors)

        return (computed_by, Impacts(**impacts))

    except bw2calc.errors.BW2CalcError as e:
        logger.error(f"-> Impossible to compute impacts in Brightway for {bw_activity}")
        logger.exception(e)
        return (None, None)


def compute_brightway_impacts(activity, method, impacts_py, demand_amount=None):
    results = dict()
    # Some processes have negative production amounts (e.g., waste treatment processes that
    # consume 1 kg of waste rather than produce it). We need to get the sign of the production
    # amount to properly normalize impacts to 1 unit of the process.
    # Using sign function: (x > 0) - (x < 0) returns 1 for positive, -1 for negative, 0 for zero
    if demand_amount is None:
        demand_amount = (activity["production amount"] > 0) - (
            activity["production amount"] < 0
        )
    lca = bw2calc.LCA({activity: demand_amount})
    lca.lci()
    for key, method in impacts_py.items():
        lca.switch_method(method)
        lca.lcia()
        results[key] = float("{:.10g}".format(lca.score))
        logger.debug(f"{activity}  {key}: {lca.score}")

    return results


def compute_simapro_impacts(activity, method, impacts_py):
    project, library = spproject(activity)
    name = (
        activity["name"]
        if project != "WFLDB"
        # TODO this should probably done through disabling a strategy
        else f"{activity['name']}/{activity['location']} U"
    )
    strprocess = urllib.parse.quote(name, encoding=None, errors=None)
    project = urllib.parse.quote(project, encoding=None, errors=None)
    library = urllib.parse.quote(library, encoding=None, errors=None)
    method = urllib.parse.quote(method, encoding=None, errors=None)
    api_request = f"http://simapro.ecobalyse.fr:8000/impact?process={strprocess}&project={project}&library={library}&method={method}"
    logger.debug(f"SimaPro API request: {api_request}")

    try:
        response = requests.get(api_request)
    except requests.exceptions.ConnectTimeout:
        logger.warning("SimaPro did not answer! Is it started?")
        return dict()

    try:
        json_content = json.loads(response.content)

        # If Simapro doesn't return a dict, it's most likely an error
        # (project not found) Don't do anything and return None,
        # BW will be used as a replacement
        if isinstance(json_content, dict):
            return bytrigram(impacts_py, json_content)
    except ValueError:
        pass

    return dict()


def get_mass_per_unit(eco_activity: dict, bw_activity) -> Optional[float]:
    """
    Get the mass per unit for an activity.

    For packaging activities with unit "item", extract the mass from the
    PACKAGING_SYSTEM_G parameter in the Brightway activity.
    Otherwise, use the massPerUnit from eco_activity.
    """
    # First check if eco_activity has a massPerUnit value
    if eco_activity.get("massPerUnit"):
        return eco_activity["massPerUnit"]

    # For packaging activities, try to get mass from PACKAGING_SYSTEM_G parameter
    # Only applies when unit is "item" (mass per item)
    is_packaging = "packaging" in eco_activity.get("categories", [])
    unit = eco_activity.get("unit")

    if is_packaging and bw_activity and unit == "item":
        parameters = bw_activity._data.get("parameters", {})

        if "PACKAGING_SYSTEM_G" in parameters:
            return parameters["PACKAGING_SYSTEM_G"].get("amount") / 1000
        elif "PACKAGING_SYSTEM_KG" in parameters:
            return parameters["PACKAGING_SYSTEM_KG"].get("amount")
        else:
            raise ValueError(
                f"Packaging activity with unit 'item' missing PACKAGING_SYSTEM_G or PACKAGING_SYSTEM_KG: {bw_activity}"
            )
    return None


def activity_to_process_with_impacts(
    eco_activity, impacts, computed_by: ComputedBy | None, bw_activity={}
) -> Process:
    unit = fix_unit(bw_activity.get("unit"))

    bw_activity["unit"] = unit

    # Some hardcoded activities (when source = Custom) don't have a bw_activity, in that case take the ecobalyse displayName

    # Get comment with consistent fallback logic:
    # 1. First try eco_activity
    # 2. Then try bw_activity (if it's a dict or has get method)
    # 3. Finally try Brightway production exchange (only if bw_activity is a Brightway object)
    comment = eco_activity.get("comment") or bw_activity.get("Comment", "")

    return Process(
        activity_name=bw_activity.get(
            "name", "This process is not linked to a Brightway activity"
        ),
        bw_activity=bw_activity,
        categories=eco_activity.get("categories", bw_activity.get("categories", [])),
        comment=comment,
        computed_by=computed_by,
        # Default to bw_activity name if no display name is given
        display_name=eco_activity.get("displayName", bw_activity.get("name")),
        elec_kwh=eco_activity.get("elecKwh", 0),
        heat_mj=eco_activity.get("heatMJ", 0),
        id=eco_activity["id"],
        impacts=impacts,
        location=bw_activity.get("location") or eco_activity.get("location") or None,
        mass_per_unit=get_mass_per_unit(eco_activity, bw_activity),
        scopes=eco_activity.get("scopes", []),
        source=eco_activity.get("source"),
        unit=eco_activity.get("unit", bw_activity.get("unit")),
        qty_variation_ratio=eco_activity.get(
            "qtyVariationRatio", bw_activity.get("qtyVariationRatio", 1)
        ),
    )
