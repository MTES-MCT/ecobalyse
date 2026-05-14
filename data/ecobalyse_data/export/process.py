import os
from typing import List

from common import (
    get_normalization_weighting_factors,
)
from common.export import (
    IMPACTS_JSON,
    display_changes_from_json,
    export_processes_to_dirs,
    plot_impacts,
)
from common.impacts import impacts as impacts_py
from common.impacts import main_method
from ecobalyse_data.computation import compute_impacts, compute_processes_for_activities
from ecobalyse_data.logging import logger
from models.process import ComputedBy, Process, Scope


def activities_to_processes(
    activities: list[dict],
    aggregated_relative_file_path: str,
    impacts_relative_file_path: str,
    dirs_to_export_to: List[str],
    graph_folder: str,
    plot: bool = False,
    display_changes: bool = True,
    simapro: bool = False,
    merge: bool = False,
    scopes: list[Scope] = None,
):
    factors = get_normalization_weighting_factors(IMPACTS_JSON)

    processes: List[Process] = compute_processes_for_activities(
        activities,
        main_method,
        impacts_py,
        IMPACTS_JSON,
        factors,
        simapro=simapro,
    )

    index = 1
    total = len(processes)
    if plot:
        for process in processes:
            logger.info(
                f"-> [{index}/{total}] Plotting impacts for '{process.activity_name}'"
            )
            index += 1
            os.makedirs(graph_folder, exist_ok=True)
            if process.computed_by == ComputedBy.hardcoded:
                logger.warning(
                    f"-> The process '{process.activity_name}' has harcoded impacts, it can’t be plot, skipping."
                )
                continue
            elif process.source == "Ecobalyse":
                logger.warning(
                    f"-> The process '{process.activity_name}' has been constructed by 'Ecobalyse' and is not present in simapro, skipping."
                )
                continue
            elif process.computed_by == ComputedBy.simapro:
                impacts_simapro = process.impacts.model_dump(exclude={"ecs"})

                (computed_by, impacts_bw) = compute_impacts(
                    process.bw_activity,
                    main_method,
                    impacts_py,
                    IMPACTS_JSON,
                    factors,
                    simapro=False,
                )
                impacts_bw = impacts_bw.model_dump(exclude={"ecs"})
            else:
                impacts_bw = process.impacts.model_dump(exclude={"ecs"})

                (computed_by, impacts_simapro) = compute_impacts(
                    process.bw_activity,
                    main_method,
                    impacts_py,
                    IMPACTS_JSON,
                    factors,
                    simapro=True,
                )
                if not impacts_simapro:
                    raise ValueError(
                        f"-> Unable to get Simapro impacts for '{process.activity_name}', skipping."
                    )

                impacts_simapro = impacts_simapro.model_dump(exclude={"ecs"})

            plot_impacts(
                process_name=process.activity_name,
                impacts_smp=impacts_simapro,
                impacts_bw=impacts_bw,
                folder=graph_folder,
                impacts_py=IMPACTS_JSON,
            )

    # Convert objects to dicts
    dumped_processes = [
        process.model_dump(by_alias=True, exclude={"bw_activity", "computed_by"})
        for process in processes
    ]

    if display_changes:
        display_changes_from_json(
            processes_impacts_path=impacts_relative_file_path,
            processes_corrected_impacts=dumped_processes,
            # Compare by default with the first output dir
            dir=dirs_to_export_to[0],
        )

    export_processes_to_dirs(
        aggregated_relative_file_path,
        impacts_relative_file_path,
        dumped_processes,
        dirs_to_export_to,
        merge=merge,
        scopes=scopes,
    )

    logger.info("Export completed successfully.")
