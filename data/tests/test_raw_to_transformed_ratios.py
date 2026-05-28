import json

import pytest

from config import PROJECT_ROOT_DIR


@pytest.fixture(scope="module")
def raw_to_transformed():
    path = (
        PROJECT_ROOT_DIR
        / "food"
        / "ecosystemic_services"
        / "raw_to_transformed_ratios.json"
    )
    with open(path) as f:
        return json.load(f)


@pytest.fixture(scope="module")
def from_scratch_by_alias():
    path = PROJECT_ROOT_DIR / "activities_to_create.json"
    with open(path) as f:
        activities = json.load(f)
    return {
        a["alias"]: a
        for a in activities
        if a.get("activityCreationType") == "from_scratch"
    }


def test_entry_shape(raw_to_transformed):
    """Every leaf has the expected shape: {ratio, source, source_ref}."""
    allowed_sources = {
        "brightway_manual",
        "brightway",
        "cmaps_activities_to_create",
        "cmaps",
        "manual",
    }
    for raw_alias, products in raw_to_transformed.items():
        for transformed_alias, entry in products.items():
            location = f"{raw_alias} -> {transformed_alias}"
            assert set(entry.keys()) == {"ratio", "source", "source_ref"}, (
                f"{location}: unexpected keys {set(entry.keys())}"
            )
            assert isinstance(entry["ratio"], (int, float)), (
                f"{location}: ratio must be a number"
            )
            assert entry["ratio"] > 0, f"{location}: ratio must be positive"
            assert entry["source"] in allowed_sources, (
                f"{location}: source {entry['source']!r} not in {allowed_sources}"
            )
            assert isinstance(entry["source_ref"], str), (
                f"{location}: source_ref must be a string"
            )


def test_cmaps_rows_match_activities_to_create(
    raw_to_transformed, from_scratch_by_alias
):
    """For every source=cmaps row: source_ref must be a from_scratch alias, and
    the ratio must equal that activity's first exchange amount."""
    for raw_alias, products in raw_to_transformed.items():
        for transformed_alias, entry in products.items():
            if entry["source"] != "cmaps":
                continue
            location = f"{raw_alias} -> {transformed_alias}"
            ref = entry["source_ref"]
            assert ref, f"{location}: cmaps row must have a non-empty source_ref"
            assert ref in from_scratch_by_alias, (
                f"{location}: source_ref '{ref}' not found as a from_scratch alias "
                f"in activities_to_create.json"
            )
            exchanges = from_scratch_by_alias[ref].get("exchanges", [])
            assert exchanges, f"{location}: from_scratch '{ref}' has no exchanges"
            first_amount = exchanges[0].get("amount")
            assert first_amount == entry["ratio"], (
                f"{location}: ratio {entry['ratio']} does not match first exchange "
                f"amount {first_amount} of '{ref}' in activities_to_create.json"
            )
