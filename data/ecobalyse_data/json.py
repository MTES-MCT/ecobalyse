from typing import Any


def activities_processes_sort_key(entry: dict[str, Any]) -> tuple:
    return (
        entry.get("source", ""),
        entry.get("activityName", ""),
        entry.get("location"),
        entry.get("alias") or "",
        entry.get("displayName", ""),
    )
