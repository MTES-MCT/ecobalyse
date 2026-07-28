import orjson

from bin import export
from common.export import export_json
from config import DATA_ROOT_DIR, TESTS_FIXTURE_DIR, settings
from create_activities import create_activities


def test_export_processes(forwast, tmp_path, processes_impacts_json):
    settings.set("FRONTEND_DATA_DIR", str(tmp_path))
    settings.set("EXPORT_DIR", str(tmp_path))
    create_activities(DATA_ROOT_DIR / "tests" / "custom_lci.json")

    export.processes_legacy(
        scopes=None,
        verbose=False,
        root_dir=TESTS_FIXTURE_DIR,
    )

    with open(tmp_path / settings.PROCESSES_LEGACY_IMPACTS_DIR, "rb") as f:
        json_data = orjson.loads(f.read())
        # TODO
        export_json(
            json_data,
            TESTS_FIXTURE_DIR / "processes_legacy_impacts_output.json",
        )
        assert json_data == processes_impacts_json


def test_export_ingredients(
    forwast, tmp_path, ingredients_food_json, processes_impacts_full_json
):
    settings.set("FRONTEND_DATA_DIR", str(tmp_path))
    settings.set("EXPORT_DIR", str(tmp_path))

    output_path = tmp_path / "food"
    output_path.mkdir()

    # TODO
    export_json(
        processes_impacts_full_json,
        tmp_path / settings.PROCESSES_LEGACY_IMPACTS_FULL_DIR,
    )

    export.metadata(
        scopes=[export.MetadataScope.food],
        root_dir=TESTS_FIXTURE_DIR,
    )

    with open(output_path / "ingredients.json", "rb") as f:
        json_data = orjson.loads(f.read())
        assert json_data == ingredients_food_json


def test_export_materials(forwast, tmp_path, materials_textile_json):
    settings.set("FRONTEND_DATA_DIR", str(tmp_path))
    settings.set("EXPORT_DIR", str(tmp_path))

    output_path = tmp_path / "textile"
    output_path.mkdir()

    export.metadata(
        scopes=[export.MetadataScope.textile],
        root_dir=TESTS_FIXTURE_DIR,
    )

    with open(output_path / "materials.json", "rb") as f:
        json_data = orjson.loads(f.read())
        assert json_data == materials_textile_json


def test_export_processes_generic(
    forwast, tmp_path, processes_impacts_full_json, processes_generic_impacts_json
):
    settings.set("FRONTEND_DATA_DIR", str(tmp_path))
    settings.set("EXPORT_DIR", str(tmp_path))

    # Write the full (unfiltered) processes data that the generic export reads.
    # TODO
    export_json(
        processes_impacts_full_json,
        tmp_path / settings.PROCESSES_LEGACY_IMPACTS_FULL_DIR,
    )

    export.metadata(
        scopes=[export.MetadataScope.generic],
        root_dir=TESTS_FIXTURE_DIR,
    )

    with open(tmp_path / settings.PROCESSES_GENERIC_IMPACTS_DIR, "rb") as f:
        json_data = orjson.loads(f.read())
        # TODO
        export_json(
            json_data,
            TESTS_FIXTURE_DIR / "processes_generic_impacts_output.json",
        )
        assert json_data == processes_generic_impacts_json
