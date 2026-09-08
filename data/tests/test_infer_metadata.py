import pytest

from common.infer_metadata import (
    infer_raw_to_cooked_ratio,
    infer_variant_material_type,
)


@pytest.mark.parametrize(
    ("categories", "alias", "variant_categories"),
    [
        (
            ["ingredient", "material"],
            "carrot-fr",
            [
                "ingredient",
                "material",
                "material_type:fruits_and_vegetables",
                "transported_cooled",
            ],
        ),
        (
            ["ingredient", "material"],
            "milk",
            ["ingredient", "material", "material_type:other_food_items"],
        ),
        # non-ingredient processes are untouched
        (
            ["material", "transformation"],
            "unused-alias",
            ["material", "transformation"],
        ),
    ],
)
def test_infer_variant_material_type(categories, alias, variant_categories):
    assert infer_variant_material_type(categories, alias) == variant_categories


@pytest.mark.parametrize(
    ("explicit_ratio", "alias", "infered_ratio"),
    [
        (None, "carrot-fr", 0.856),
        (None, "barley-fr", 2.259),
        (1.67, "barley-fr", 1.67),
        # other_food_items has no reference value: neutral 1.0
        (None, "milk", 1.0),
    ],
)
def test_infer_raw_to_cooked_ratio(explicit_ratio, alias, infered_ratio):
    assert infer_raw_to_cooked_ratio(explicit_ratio, alias) == infered_ratio
