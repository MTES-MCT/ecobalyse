# Please only pure functions here
import json
from typing import Any
from uuid import UUID

from data.config import settings

from .logging import logger


class FormatNumberJsonEncoder(json.JSONEncoder):
    def encode(self, o) -> str:
        def recursive_format_number(obj):
            # in python, bools are a subclass of int, so we should check explicitly
            # if obj is not a bool, otherwise it will be converted to a float…
            if isinstance(obj, (int, float)) and not isinstance(obj, bool):
                if obj == 0:
                    return 0
                else:
                    return float(f"{obj:.{settings.number_precision}g}")
            elif isinstance(obj, dict):
                return {k: recursive_format_number(v) for k, v in obj.items()}
            # it looks like we are using tuples as lists, so treat them the same way
            elif isinstance(obj, (list, tuple)):
                return [recursive_format_number(v) for v in obj]
            elif isinstance(obj, UUID):
                return str(obj)
            else:
                return obj

        return super().encode(recursive_format_number(o))


def activities_processes_sort_key(entry: dict[str, Any]) -> tuple:
    return (
        entry.get("source", ""),
        entry.get("activityName", ""),
        entry.get("location"),
        entry.get("alias") or "",
        entry.get("displayName", ""),
    )


def dict_to_json_string(
    json_data: dict[str, Any] | list[dict[str, Any]], sort_fn=None
) -> str:
    if sort_fn is not None and isinstance(json_data, list):
        json_data.sort(key=sort_fn)

    return json.dumps(
        json_data,
        indent=2,
        ensure_ascii=False,
        cls=FormatNumberJsonEncoder,
        sort_keys=True,
    )


def export_json(
    json_data: dict[str, Any] | list[dict[str, Any]], filename, sort_fn=None
):
    logger.info(f"Exporting {filename}")
    json_string = dict_to_json_string(json_data, sort_fn)

    with open(filename, "w", encoding="utf-8") as file:
        file.write(json_string)
        file.write("\n")  # Add a newline at the end of the file

    logger.info(f"Exported {len(json_data)} elements to {filename}")
