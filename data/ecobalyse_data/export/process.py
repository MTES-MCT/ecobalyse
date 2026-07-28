from pathlib import Path
from typing import List

from common import (
    get_normalization_weighting_factors,
)
from common.export import (
    IMPACTS_JSON,
    display_changes_from_json,
    export_processes_to_dir,
)
from common.impacts import impacts as impacts_py
from common.impacts import main_method
from ecobalyse_data.computation import compute_processes_for_activities
from ecobalyse_data.logging import logger
from models.process import Process, Scope


def activities_to_processes(
    activities: list[dict],
    ecs_relative_file_path: str,
    impacts_relative_file_path: str,
    full_impacts_relative_file_path: str,
    dir_to_export_to: Path,
    display_changes: bool = True,
    merge: bool = False,
    scopes: list[Scope] | None = None,
):

    factors = get_normalization_weighting_factors(IMPACTS_JSON)

    processes: List[Process] = compute_processes_for_activities(
        activities,
        main_method,
        impacts_py,
        IMPACTS_JSON,
        factors,
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
            dir=dir_to_export_to,
        )

    export_processes_to_dir(
        ecs_relative_file_path,
        impacts_relative_file_path,
        dumped_processes,
        dir_to_export_to,
        full_impacts_relative_file_path,
        merge=merge,
        scopes=scopes,
    )

    logger.info("Export completed successfully.")
