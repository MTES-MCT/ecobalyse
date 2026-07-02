import json
from collections import Counter

from bin.export import _get_lcias
from common.infer_metadata import infer_base_ingredient
from config import PROJECT_ROOT_DIR


def _ingredient_aliases():
    """Yield every alias on an ingredient-category activity in lci_catalog/."""
    for activity in _get_lcias(PROJECT_ROOT_DIR):
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


def test_base_ingredients_unique():
    """Every baseIngredient must be unique"""
    with open(PROJECT_ROOT_DIR / "food" / "base_ingredients.json") as f:
        entries = json.load(f)

    duplicates = []
    for bi, count in Counter(entries).items():
        if count > 1:
            duplicates.append(bi)

    assert not duplicates, f"duplicate baseIngredient entries : {duplicates}"
