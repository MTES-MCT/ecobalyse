from typing import Tuple

import bw2calc
from bw2data import get_multilca_data_objs

from ecobalyse_data.logging import logger

LAND_OCCUPATION_METHOD: Tuple[str, str, str] = (
    "selected LCI results",
    "resource",
    "land occupation",
)


def compute_land_occupation_batch(
    bw_activities, chunk_size: int = 200
) -> dict[int, float]:
    """Return {bw_activity.id: land_occupation_score} via a chunked MultiLCA."""
    unique = list({a.id: a for a in bw_activities}.values())
    if not unique:
        return {}

    method_config = {"impact_categories": [LAND_OCCUPATION_METHOD]}
    out: dict[int, float] = {}
    total = len(unique)
    for i in range(0, total, chunk_size):
        chunk = unique[i : i + chunk_size]
        logger.info(
            f"-> land occupation: chunk {i // chunk_size + 1}/"
            f"{(total + chunk_size - 1) // chunk_size} ({len(chunk)} activities)"
        )
        demands = {str(a.id): {a.id: 1} for a in chunk}
        data_objs = get_multilca_data_objs(
            functional_units=demands, method_config=method_config
        )
        mlca = bw2calc.MultiLCA(
            demands=demands, method_config=method_config, data_objs=data_objs
        )
        mlca.lci()
        mlca.lcia()
        for (_method_t, fu_name), ci in mlca.characterized_inventories.items():
            out[int(fu_name)] = float(ci.sum())
    return out
