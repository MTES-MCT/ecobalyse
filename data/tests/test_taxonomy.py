import json

import pytest

from bin.export import _get_lcis
from bin.generate_taxonomy_with_aliases import (
    TAXONOMY_WITH_ALIASES_PATH,
    build_taxonomy_with_aliases,
)
from common.infer_metadata import (
    infer_base_ingredient,
    load_base_ingredients,
    load_taxonomy,
    parse_taxonomy,
    validate_ingredient_activity,
)
from config import DATA_ROOT_DIR


def _ingredient_aliases():
    """Yield every alias on an ingredient-category activity in lci_catalog/."""
    for activity in _get_lcis(DATA_ROOT_DIR):
        if "ingredient" not in activity["categories"]:
            continue
        for variant in activity["metadata"]:
            yield variant["alias"]


def test_infer_base_ingredient_covers_every_ingredient_alias():
    """Every ingredient alias must resolve to a known baseIngredient."""
    alias_no_matching_bi = []
    for alias in _ingredient_aliases():
        try:
            _ = infer_base_ingredient(alias)
        except ValueError:
            alias_no_matching_bi.append(alias)
            continue
    assert not alias_no_matching_bi, (
        f"{len(alias_no_matching_bi)} aliases with no matching baseIngredient: "
        f"{sorted(set(alias_no_matching_bi))}"
    )


def test_no_useless_base_ingredient():
    """Every baseIngredient must refer to at least 1 ingredient alias"""
    used = set()
    for alias in _ingredient_aliases():
        used.add(infer_base_ingredient(alias))

    unused = sorted(set(load_base_ingredients()) - used)
    assert not unused, (
        f"{len(unused)} baseIngredients is useless as it refers to 0 ingredient alias "
        f" remove them from food/taxonomy.json: {unused}"
    )


def test_taxonomy_is_valid():
    """Loading validates the taxonomy: known material_types only,
    every base_ingredient must appear under 1 and only 1 material_type
    """
    assert load_taxonomy()


@pytest.mark.parametrize(
    "taxonomy",
    [
        {"food": {"not_a_material_type": ["apple"]}},
        {"food": {"cereals": ["apple"], "legumes": ["apple"]}},
    ],
)
def test_parse_taxonomy_rejects_invalid_content(taxonomy):
    with pytest.raises(ValueError):
        parse_taxonomy(taxonomy)


def test_taxonomy_with_aliases_is_up_to_date():
    with open(TAXONOMY_WITH_ALIASES_PATH, encoding="utf-8") as f:
        assert json.load(f) == build_taxonomy_with_aliases(), (
            "food/taxonomy_with_aliases.json is out of date, regenerate it"
            " with: `uv run python bin/generate_taxonomy_with_aliases.py`"
        )


def test_catalog_respects_ingredient_invariants():
    """Every ingredient activity of the catalog must satisfy the taxonomy
    invariants: no manual material_type tag, one alias per variant."""
    lci_catalog = DATA_ROOT_DIR / "lci_catalog"
    for lci_path in lci_catalog.glob("*/*.json"):
        with open(lci_path, encoding="utf-8") as f:
            activity = json.load(f)
        try:
            validate_ingredient_activity(activity)
        except ValueError as e:
            raise AssertionError(f"{lci_path.name}: {e}") from e


def test_validate_ingredient_activity_rejects_manual_tag():
    with pytest.raises(ValueError, match="manual"):
        validate_ingredient_activity(
            {
                "categories": ["ingredient", "material_type:fruits_and_vegetables"],
                "metadata": [{"alias": "carrot-fr"}],
            }
        )


def test_validate_ingredient_activity_rejects_variant_without_alias():
    with pytest.raises(ValueError, match="has no alias"):
        validate_ingredient_activity(
            {
                "categories": ["ingredient"],
                "metadata": [{"alias": "carrot-fr"}, {"displayName": "no alias"}],
            }
        )


def test_validate_ingredient_activity_ignores_non_ingredient():
    validate_ingredient_activity(
        {
            "categories": ["transformation", "material_type:cereals"],
            "metadata": [{"displayName": "no alias"}],
        }
    )
