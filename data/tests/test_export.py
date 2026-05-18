import orjson

from bin import export
from common.export import export_json
from config import TESTS_FIXTURE_DIR, settings
from create_activities import create_activities


def test_export_processes(forwast, tmp_path, processes_impacts_json):
    settings.set("OUTPUT_DIR", str(tmp_path))
    create_activities("tests/activities_to_create.json")

    export.processes(
        scopes=None,
        simapro=False,
        plot=False,
        verbose=False,
        root_dir=TESTS_FIXTURE_DIR,
    )

    with open(tmp_path / "processes_impacts.json", "rb") as f:
        json_data = orjson.loads(f.read())
        export_json(
            json_data,
            TESTS_FIXTURE_DIR / "processes_impacts_output.json",
        )
        assert json_data == processes_impacts_json


def test_export_ingredients(forwast, tmp_path, ingredients_food_json):
    settings.set("OUTPUT_DIR", str(tmp_path))

    output_path = tmp_path / "food"
    output_path.mkdir()

    export.metadata(
        scopes=[export.MetadataScope.food],
        root_dir=TESTS_FIXTURE_DIR,
    )

    with open(output_path / "ingredients.json", "rb") as f:
        json_data = orjson.loads(f.read())
        assert json_data == ingredients_food_json


def test_export_materials(forwast, tmp_path, materials_textile_json):
    settings.set("OUTPUT_DIR", str(tmp_path))

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
    settings.set("OUTPUT_DIR", str(tmp_path))

    # Write the full (unfiltered) processes data that the generic export reads
    export_json(processes_impacts_full_json, tmp_path / "processes_impacts_full.json")
    # Also write the regular file (needed for the path resolution)
    export_json(
        processes_impacts_full_json,
        tmp_path / settings.processes_impacts_file,
    )

    export.metadata(
        scopes=[export.MetadataScope.generic],
        root_dir=TESTS_FIXTURE_DIR,
    )

    with open(tmp_path / "processes_generic_impacts.json", "rb") as f:
        json_data = orjson.loads(f.read())
        export_json(
            json_data,
            TESTS_FIXTURE_DIR / "processes_generic_impacts_output.json",
        )
        assert json_data == processes_generic_impacts_json
