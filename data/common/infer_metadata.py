"""Inference of metadata from input data"""

import functools
import json
from pathlib import Path

from config import DATA_ROOT_DIR

_TAXONOMY_PATH = DATA_ROOT_DIR / "food" / "taxonomy.json"


_LEGACY_ZONE_TO_COUNTRY = {
    "France": "FR",
    "FranceOutreMer": "ROF",
    "EuropeAndMaghreb": "REM",
    "OutOfEuropeAndMaghreb": None,
    "OutOfEuropeAndMaghrebByPlane": None,
}

# Reference values from
# https://fabrique-numerique.gitbook.io/ecobalyse/alimentaire/impacts-consideres/rapport-cru-cuit
# `material_type:other_food_items` is absent cause it
# heterogenous rawToCookedRatio values
_MATERIAL_TYPE_TO_RAW_TO_COOKED_RATIO = {
    "cereals": 2.259,
    "eggs": 0.974,
    "fish_and_shellfish": 0.819,
    "fruits_and_vegetables": 0.856,
    "legumes": 2.33,
    "offal": 0.730,
    "poultry": 0.755,
    "red_meats": 0.792,
}


TRANSPORTED_COOLED_MATERIAL_TYPES = frozenset(
    {
        "fruits_and_vegetables",
        "fish_and_shellfish",
        "legumes",
        "red_meats",
        "poultry",
        "offal",
    }
)

TRANSPORTED_COOLED_CATEGORY = "transported_cooled"
_MATERIAL_TYPE_PREFIX = "material_type:"


def infer_default_origin(origin_zone: str | None, categories: list[str]) -> str | None:
    """generic default origin is infered from legacy default_origin with the _LEGACY_ZONE_TO_COUNTRY mapping"""
    if origin_zone is not None:
        if origin_zone not in _LEGACY_ZONE_TO_COUNTRY:
            raise ValueError(
                f"Unknown default origin zone {origin_zone!r}. "
                f"Known zones: {sorted(_LEGACY_ZONE_TO_COUNTRY)}."
            )
        return _LEGACY_ZONE_TO_COUNTRY[origin_zone]

    if "packaging" in (categories or []):
        return "FR"

    return None


def infer_raw_to_cooked_ratio(explicit_ratio: float | None, alias: str) -> float:
    """If explicit_ratio is None, infer the rawToCookedRatio from the
    material_type of the alias."""
    if explicit_ratio is not None:
        return explicit_ratio

    material_type = infer_material_type_for_alias(alias)
    # other_food_items has no reference value (heterogenous products):
    # in this case we set the rawToCookedRatio to 1
    # food2 doesn't use this field so it will be deleted when food1 is decommissioned
    return _MATERIAL_TYPE_TO_RAW_TO_COOKED_RATIO.get(material_type, 1.0)


KNOWN_MATERIAL_TYPES = frozenset(_MATERIAL_TYPE_TO_RAW_TO_COOKED_RATIO) | {
    "other_food_items"
}


def parse_taxonomy(
    taxonomy: dict, known_material_types: frozenset[str] = KNOWN_MATERIAL_TYPES
) -> dict[str, str]:
    """Turn a taxonomy document into the baseIngredient -> material_type
    mapping, rejecting unknown material_types and duplicated baseIngredients.
    """
    material_type_by_base = {}
    for material_type, base_ingredients in taxonomy["food"].items():
        if material_type not in known_material_types:
            raise ValueError(
                f"Unknown material_type {material_type!r}. "
                f"Known material_types: {sorted(known_material_types)}."
            )
        for base_ingredient in base_ingredients:
            if base_ingredient in material_type_by_base:
                raise ValueError(
                    f"baseIngredient {base_ingredient!r} appears under several "
                    "material_types."
                )
            material_type_by_base[base_ingredient] = material_type
    return material_type_by_base


@functools.cache
def load_taxonomy(taxonomy_path: Path = _TAXONOMY_PATH) -> dict[str, str]:
    """Return the validated baseIngredient -> material_type mapping from
    taxonomy.json."""
    with open(taxonomy_path, "r", encoding="utf-8") as f:
        return parse_taxonomy(json.load(f))


@functools.cache
def load_base_ingredients() -> tuple[str, ...]:
    # sort by descending length so that `apple-juice-fr` matches baseIngredient `apple-juice` and not `apple`
    return tuple(sorted(load_taxonomy(), key=len, reverse=True))


def infer_base_ingredient(alias: str) -> str:
    """Return the longest known baseIngredient that prefix-matches `alias`.

    Raises ValueError if no canonical baseIngredient prefix-matches the alias.
    """
    for base_ingredient in load_base_ingredients():
        if alias == base_ingredient or alias.startswith(base_ingredient + "-"):
            return base_ingredient
    raise ValueError(
        f"Cannot infer baseIngredient for alias {alias!r}. "
        f"Add the canonical baseIngredient to food/taxonomy.json."
    )


def infer_material_type(base_ingredient: str) -> str:
    """Return the material_type of a baseIngredient from the taxonomy."""
    return load_taxonomy()[base_ingredient]


def infer_material_type_for_alias(alias: str) -> str:
    return infer_material_type(infer_base_ingredient(alias))


def infer_variant_material_type(categories: list[str], alias: str) -> list[str]:
    """Return an ingredient variant's categories, extended with the
    material_type of its alias and, the transported_cooled tag if needed"""
    if "ingredient" not in categories:
        return categories
    material_type = infer_material_type_for_alias(alias)
    variant_categories = set(categories) | {_MATERIAL_TYPE_PREFIX + material_type}
    if material_type in TRANSPORTED_COOLED_MATERIAL_TYPES:
        variant_categories.add(TRANSPORTED_COOLED_CATEGORY)
    return sorted(variant_categories)


def validate_ingredient_activity(activity: dict) -> None:
    """check that ingredients don't contain manual material_types tag
    (material_type are infered from the taxonomy)
    also check that ingredients have an alias"""
    categories = activity["categories"]
    if "ingredient" not in categories:
        return
    manual_tags = [
        category
        for category in categories
        if category.startswith(_MATERIAL_TYPE_PREFIX)
    ]
    if manual_tags:
        raise ValueError(
            f"manual {manual_tags[0]} tag on an ingredient activity. "
            "material_type is infered from food/taxonomy.json"
        )
    for metadata in activity["metadata"]:
        if not metadata.get("alias"):
            raise ValueError(
                f"ingredient variant {metadata.get('displayName')} has no "
                "alias. material_type inference is per-alias"
            )
