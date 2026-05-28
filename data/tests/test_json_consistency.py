#!/usr/bin/env python3
"""
Consistency checks on json files.
To add a new check define a new function and set it in the CHECKS dict
"""

import json
import re
import tempfile
import uuid
from collections import Counter
from pathlib import Path

from config import PROJECT_ROOT_DIR, TESTS_FIXTURE_DIR
from ecobalyse_data.export.food import Scenario, scenario
from ecobalyse_data.export.utils import get_metadata_for_scope


def duplicate(filename, content, key):
    "Duplicate check"
    values = [act[key] for act in content if key in act]
    counter = Counter(values)
    duplicates = [name for name, count in counter.items() if count > 1 and name]
    if duplicates:
        raise AssertionError(f"Duplicate {key} in {filename}: " + ", ".join(duplicates))


def duplicate_alias_in_metadata(filename, content):
    "Duplicate alias check in metadata"
    all_aliases = []

    for activity in content:
        # Collect aliases from metadata only (not top-level)
        metadata = activity.get("metadata") or []
        for meta in metadata:
            if meta.get("alias"):
                scopes_str = ",".join(meta.get("scopes", []))
                all_aliases.append(
                    (
                        meta["alias"],
                        meta.get(
                            "displayName",
                            activity.get("displayName", "unknown"),
                        ),
                        f"metadata[{scopes_str}]",
                    )
                )

    # Check for duplicates
    alias_values = [alias for alias, _, _ in all_aliases]
    counter = Counter(alias_values)
    duplicates = [alias for alias, count in counter.items() if count > 1 and alias]

    if duplicates:
        # Build detailed error message
        error_lines = []
        for dup_alias in duplicates:
            occurrences = [
                f"{display_name} ({location})"
                for alias, display_name, location in all_aliases
                if alias == dup_alias
            ]
            error_lines.append(f"  '{dup_alias}': {', '.join(occurrences)}")

        raise AssertionError(
            f"Duplicate aliases in metadata in {filename}:\n" + "\n".join(error_lines)
        )


def metadata_consistency(filename, activities):
    """
    Check that metadata and scope are consistent in the lci_activity/* files.
    A metadata item can't reference a scope not in activity["scopes"]
    """
    for activity in activities:
        metadata = activity.get("metadata") or []
        activity_scopes = set(activity["scopes"])
        for item in metadata:
            metadata_scopes = set(item.get("scopes", []))
            if not metadata_scopes <= activity_scopes:
                extra = metadata_scopes - activity_scopes
                raise AssertionError(
                    f"Inconsistent metadata-scopes for object {activity['displayName']} in {filename}: metadata item scopes {extra} not in activity scopes {activity_scopes}"
                )


def custom_source_consistency(filename, activities):
    """
    Check that source = "Custom" if and only if impacts are present
    """
    for activity in activities:
        source = activity["source"]
        display_name = activity["displayName"]
        if "impacts" in activity and source != "Custom":
            raise AssertionError(
                f"Custom source inconsistency : activity {display_name} has hardcoded impacts but source is not 'Custom' (source = {source})"
            )
        elif "impacts" not in activity and source == "Custom":
            raise AssertionError(
                f"Custom source inconsistency : activity {display_name} has source = 'Custom' but no hardcoded impacts"
            )


def invalid_uuid(filename, content, key):
    "Invalid UUID check"
    invalid_uuids = []
    for obj in content:
        try:
            uuid.UUID(obj.get(key))
        except ValueError:
            invalid_uuids.append(f"Invalid UUID: '{obj[key]}' in {filename}\n")
            continue
        except TypeError:
            invalid_uuids.append(f"Missing UUID in {filename}: {obj}\n")
            continue

    if invalid_uuids:
        raise AssertionError("".join(invalid_uuids))


def missing(filename, content, key):
    "Missing check"
    missing_items = []
    for obj in content:
        if key not in obj or not obj[key]:
            missing_items.append(f"Missing '{key}' in {filename}:")
            missing_items.append(f"    {obj}")

    if missing_items:
        raise AssertionError("\n".join(missing_items))


def alias_syntax(filename, content, key):
    "Alias syntax check (lowercase, digits and hyphens only)"
    alias_pattern = re.compile(r"^[a-z0-9-]+$")
    invalid_aliases = []
    for obj in content:
        alias = obj.get(key)
        if alias and not alias_pattern.match(alias):
            invalid_aliases.append(
                f"Invalid alias syntax '{alias}' for '{obj.get('displayName', obj.get('newName', 'unknown'))}' in {filename}"
            )

    if invalid_aliases:
        raise AssertionError("\n".join(invalid_aliases))


def check_ingredient_densities(filename, content, key):
    """check the ingredientDensity is strictly positive"""
    wrong = []
    for obj in content:
        if "ingredient" in obj.get("categories"):
            for metadata in get_metadata_for_scope(obj, "food"):
                if metadata.get("ingredientDensity", 0) <= 0:
                    wrong.append(
                        f"Wrong or missing '{key}' for `{obj['displayName']}` in {filename}"
                    )

    if wrong:
        raise AssertionError("\n".join(wrong))


def check_scenario(filename, content, key):
    """Check scenario consistency"""
    errors = []
    for obj in content:
        if "ingredient" not in obj["categories"]:
            continue
        if not obj.get("ingredientCategories"):
            continue
        # scenario must be there and
        # computed scenario must be the same as stored scenario
        # (at least for now)
        if "scenario" not in obj:
            errors.append(f"No scenario found for `{obj['displayName']}` in {filename}")
        else:
            if obj["scenario"] not in list(Scenario):
                errors.append(
                    f"Wrong scenario: `{obj['scenario']}` for `{obj['displayName']}`"
                )
            if obj.get("scenario") != scenario(obj):
                errors.append(
                    f"Wrong scenario for `{obj['displayName']}` in {filename}"
                )
        # organic scenario is kind of redundant with organic category
        # but check it anyway
        if (
            scenario(obj) == Scenario.ORGANIC
            and "organic" not in obj["ingredientCategories"]
        ):
            errors.append(
                f"The 'ingredientCategories' should contain 'organic' for `{obj['displayName']}` in {filename}"
            )

    if errors:
        raise AssertionError("\n".join(errors))


def check_all(checks_by_file, content_checks_by_file=None):
    for filename, checks_by_key in checks_by_file.items():
        print(f"Checking {filename}")
        with open(filename) as f:
            content = json.load(f)

            # Run content-level checks (no specific key)
            if content_checks_by_file and filename in content_checks_by_file:
                for function in content_checks_by_file[filename]:
                    function(filename, content)
                    print("  OK: " + function.__doc__)

            # Run key-specific checks
            for key, checks in checks_by_key.items():
                for function in checks:
                    function(filename, content, key)
                    print("  OK: " + function.__doc__ + f" for key '{key}'")
    print("== All checks passed ==")


def creation_alias_matches_export_alias(activities_fp):
    """Check that creation aliases in activities_to_create.json match export aliases in lci_catalog/__alias__.json.

    For each activity in lci_catalog/* whose activityName contains {{alias}},
    the alias inside {{...}} must match the activity.alias,
    and must correspond to an entry in activities_to_create.json.
    """
    with open("activities_to_create.json") as f:
        atc = json.load(f)
    activities = json.load(activities_fp)

    atc_aliases = {entry["alias"] for entry in atc}
    errors = []

    # Live animal activities intentionally reuse a created process (with its
    # {{creation_alias}}) but are exported under their own alias.
    alias_mismatch_exceptions = {
        "broiler-br-max-live",
        "broiler-fr-feed-live",
        "broiler-fr-organic-live",
        "broiler-default",
        "beef-organic",
        "broiler-organic",
        "lamb-organic",
        "pork-organic",
        "pork-default",
    }

    for activity in activities:
        activity_name = activity.get("activityName", "")
        match = re.search(r"\{\{(.+?)\}\}", activity_name)
        if not match:
            continue

        creation_alias = match.group(1)
        export_alias = activity["alias"]

        if (
            creation_alias != export_alias
            and export_alias not in alias_mismatch_exceptions
        ):
            errors.append(
                f"Alias mismatch for '{activity.get('displayName', 'unknown')}': "
                f"creation alias '{{{{{creation_alias}}}}}' != export alias '{export_alias}'"
            )

        if creation_alias not in atc_aliases:
            errors.append(
                f"Creation alias '{creation_alias}' in activityName of "
                f"'{activity.get('displayName', 'unknown')}' not found in activities_to_create.json"
            )

    if errors:
        raise AssertionError(
            "Creation/export alias inconsistencies:\n" + "\n".join(errors)
        )
    print("  OK: Creation alias matches export alias")


def _concat_lci(activities_file_path: Path):
    activities = []
    for lci_path in activities_file_path.glob("*/*.json"):
        if lci_path.is_file():
            with open(lci_path, "r") as file:
                activity = json.load(file)
                activity["alias"] = lci_path.stem
                activities.append(activity)
    return activities


def test():
    with tempfile.NamedTemporaryFile(
        mode="w+", prefix="activities-"
    ) as activities_temp:
        json.dump(_concat_lci(PROJECT_ROOT_DIR / "lci_catalog"), activities_temp)
        activities_temp.seek(0)

        with tempfile.NamedTemporaryFile(
            mode="w+", prefix="test-activities-"
        ) as test_activities_temp:
            json.dump(
                _concat_lci(TESTS_FIXTURE_DIR / "lci_catalog"), test_activities_temp
            )
            test_activities_temp.seek(0)

            # Key-specific checks: validate specific fields
            CHECKS = {
                "activities_to_create.json": {
                    "alias": (duplicate, missing, alias_syntax),
                    "newName": (duplicate, missing),
                },
                activities_temp.name: {
                    "id": (duplicate, invalid_uuid, missing),
                    "displayName": (duplicate,),
                    "alias": (duplicate, alias_syntax),  # TODO
                    "scenario": (check_scenario,),
                    "ingredientDensity": (check_ingredient_densities,),
                },
                "tests/activities_to_create.json": {
                    "alias": (duplicate, alias_syntax),
                    "newName": (duplicate, missing),
                },
                test_activities_temp.name: {
                    # "displayName": (duplicate,),
                    "alias": (duplicate, alias_syntax),  # TODO
                },
                "public/data/food/ingredients.json": {
                    "id": (duplicate, invalid_uuid, missing),
                    "alias": (missing, duplicate, alias_syntax),
                    "name": (missing, duplicate),
                },
                "public/data/processes.json": {
                    "id": (duplicate, invalid_uuid, missing),
                    "displayName": (duplicate,),
                },
                "public/data/textile/materials.json": {
                    "id": (duplicate, missing),
                    "name": (missing,),
                    "processId": (missing, duplicate, invalid_uuid),
                },
            }

            # Content-level checks: validate relationships across the entire content
            CONTENT_CHECKS = {
                activities_temp.name: (
                    metadata_consistency,
                    custom_source_consistency,
                    duplicate_alias_in_metadata,
                ),
            }

            check_all(CHECKS, CONTENT_CHECKS)
            creation_alias_matches_export_alias(activities_temp)


if __name__ == "__main__":
    print("Running consistency tests on json files...")
    try:
        test()
        print("\n🎉 All checks have passed!")
    except AssertionError as e:
        print(f"\n❌ Test failed: {e}")
        exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        exit(1)
