import pytest

from common.infer_metadata import infer_transported_cooled


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
