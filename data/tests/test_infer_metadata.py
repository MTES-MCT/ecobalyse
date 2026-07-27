import pytest

from common.infer_metadata import infer_raw_to_cooked_ratio, infer_transported_cooled


@pytest.mark.parametrize(
    ("categories_input", "categories_output"),
    [
        (
            ["ingredient", "material", "material_type:other_food_items"],
            ["ingredient", "material", "material_type:other_food_items"],
        ),
        (
            ["ingredient", "material", "material_type:fruits_and_vegetables"],
            [
                "ingredient",
                "material",
                "material_type:fruits_and_vegetables",
                "transported_cooled",
            ],
        ),
        (
            ["material", "material_type:fruits_and_vegetables"],
            ["material", "material_type:fruits_and_vegetables"],
        ),
        (
            ["ingredient", "material", "material_type:offal", "transported_cooled"],
            ["ingredient", "material", "material_type:offal", "transported_cooled"],
        ),
    ],
)
def test_infer_transport_cooled(categories_input, categories_output):
    assert infer_transported_cooled(categories_input) == categories_output


@pytest.mark.parametrize(
    ("explicit_ratio", "categories", "infered_ratio"),
    [
        (
            None,
            ["ingredient", "material", "material_type:fruits_and_vegetables"],
            0.856,
        ),
        (
            None,
            ["ingredient", "material", "material_type:cereals"],
            2.259,
        ),
        (
            1.67,
            ["ingredient", "material", "material_type:cereals"],
            1.67,
        ),
    ],
)
def test_infer_raw_to_cooked_ratio(explicit_ratio, categories, infered_ratio):
    assert infer_raw_to_cooked_ratio(explicit_ratio, categories) == infered_ratio
