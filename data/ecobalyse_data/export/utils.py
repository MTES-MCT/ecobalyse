def get_metadata_for_scope(activity: dict, scope: str) -> list:
    """Return metadata items that include the given scope."""
    metadata = activity.get("metadata") or []
    return [m for m in metadata if scope in (m.get("scopes") or [])]
