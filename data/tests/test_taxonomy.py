import pytest

from bin.export import _get_lcias
from common.infer_metadata import (
    infer_base_ingredient,
    load_base_ingredients,
    load_taxonomy,
    parse_taxonomy,
)
from config import DATA_ROOT_DIR


def _ingredient_aliases():
    """Yield every alias on an ingredient-category activity in lci_catalog/."""
    for activity in _get_lcias(DATA_ROOT_DIR):
        if "ingredient" not in activity.get("categories", []):
            continue
        for variant in activity.get("metadata", []):
            alias = variant.get("alias")
            if alias:
                yield alias


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
        {},
        {"food": {"not_a_material_type": ["apple"]}},
        {"food": {"cereals": ["apple"], "legumes": ["apple"]}},
    ],
)
def test_parse_taxonomy_rejects_invalid_content(taxonomy):
    with pytest.raises(ValueError):
        parse_taxonomy(taxonomy)
