#!/usr/bin/env -S uv run --script
"""
Generate `food/taxonomy.json` from the material_type tags of lci_catalog,
every baseIngredient of `food/base_ingredients.json` is
classified under the majority material_type of its aliases (ties broken by
alphabetical order of the class name)

Mixed-class bases are logged and will be corrected in next
PRs as edits of taxonomy.json

In this first step the taxonomy replaces base_ingredients.json as the list
of baseIngredients. In the next steps taxonomy.json will be used to infer
the material_type of processes.
"""

import json
from collections import Counter, defaultdict

from config import DATA_ROOT_DIR
from ecobalyse_data.logging import logger

MATERIAL_TYPE_PREFIX = "material_type:"


def main():
    with open(DATA_ROOT_DIR / "food" / "base_ingredients.json", encoding="utf-8") as f:
        bases = set(json.load(f))
    bases_longest_first = sorted(bases, key=len, reverse=True)

    def base_of(alias):
        for base in bases_longest_first:
            if alias == base or alias.startswith(base + "-"):
                return base
        raise ValueError(f"no baseIngredient prefix-matches alias {alias!r}")

    class_votes = defaultdict(Counter)
    for lci_path in sorted((DATA_ROOT_DIR / "lci_catalog").glob("*/*.json")):
        with open(lci_path, encoding="utf-8") as f:
            activity = json.load(f)
        categories = activity.get("categories", [])
        if "ingredient" not in categories:
            continue
        material_type = next(
            category[len(MATERIAL_TYPE_PREFIX) :]
            for category in categories
            if category.startswith(MATERIAL_TYPE_PREFIX)
        )
        for metadata in activity.get("metadata", []):
            class_votes[base_of(metadata["alias"])][material_type] += 1

    taxonomy = defaultdict(list)
    for base, votes in class_votes.items():
        top_count = max(votes.values())
        # If 2 classes have the same top_count, select the first in alphabetical order (arbitrary but deterministic)
        top_material_type = min(
            material_type
            for material_type, count in votes.items()
            if count == top_count
        )
        if len(votes) > 1:
            logger.info(
                f"{base}: mixed classes {dict(votes)}, keeping {top_material_type}"
            )
        taxonomy[top_material_type].append(base)

    output = {
        "food": {
            material_type: sorted(b) for material_type, b in sorted(taxonomy.items())
        }
    }
    dest = DATA_ROOT_DIR / "food" / "taxonomy.json"
    with open(dest, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
        f.write("\n")
    logger.info(f"Wrote {sum(len(b) for b in output['food'].values())} bases to {dest}")


if __name__ == "__main__":
    main()
