"""Inference of baseIngredient from an alias."""

import functools
import json
from typing import Tuple

from config import PROJECT_ROOT_DIR

_BASE_INGREDIENTS_PATH = PROJECT_ROOT_DIR / "food" / "base_ingredients.json"


@functools.cache
def load_base_ingredients() -> Tuple[str, ...]:
    with open(_BASE_INGREDIENTS_PATH, "r", encoding="utf-8") as f:
        base_ingredients = json.load(f)

    # sort by descending length so that `apple-juice-fr` matches baseIngredient `apple-juice` and not `apple`
    return tuple(sorted(set(base_ingredients), key=len, reverse=True))


def infer_base_ingredient(alias: str) -> str:
    """Return the longest known baseIngredient that prefix-matches `alias`.

    Raises ValueError if no canonical baseIngredient prefix-matches the alias.
    """
    for base_ingredient in load_base_ingredients():
        if alias == base_ingredient or alias.startswith(base_ingredient + "-"):
            return base_ingredient
    raise ValueError(
        f"Cannot infer baseIngredient for alias {alias!r}. "
        f"Add the canonical baseIngredient to food/base_ingredients.json."
    )
