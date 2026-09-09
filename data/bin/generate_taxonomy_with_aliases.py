#!/usr/bin/env -S uv run --script
"""
Generate `food/taxonomy_with_aliases.json` the taxonomy with
the ingredient aliases inside each class.

This file is useful to audit and validate the taxonomy from a method perspective
"""

import json
from collections import defaultdict
from pathlib import Path

from ecobalyse.json import export_json

from common.infer_metadata import infer_base_ingredient, load_taxonomy
from config import DATA_ROOT_DIR, settings

TAXONOMY_WITH_ALIASES_PATH = (
    DATA_ROOT_DIR
    / settings.scopes.food.dirname
    / settings.scopes.food.taxonomy_with_aliases_file
)


def build_taxonomy_with_aliases(
    lci_catalog_dir: Path = DATA_ROOT_DIR / "lci_catalog",
) -> dict:
    material_type_by_base = load_taxonomy()

    aliases_by_base = defaultdict(set)
    for lci_path in lci_catalog_dir.glob("*/*.json"):
        with open(lci_path, encoding="utf-8") as f:
            activity = json.load(f)
        if "ingredient" not in activity["categories"]:
            continue
        for metadata in activity["metadata"]:
            alias = metadata["alias"]
            aliases_by_base[infer_base_ingredient(alias)].add(alias)

    taxonomy_with_aliases = defaultdict(dict)
    for base, material_type in material_type_by_base.items():
        taxonomy_with_aliases[material_type][base] = sorted(aliases_by_base[base])
    return {"food": dict(taxonomy_with_aliases)}


def write_taxonomy_with_aliases(
    taxonomy_with_aliases_path: Path = TAXONOMY_WITH_ALIASES_PATH,
):
    export_json(build_taxonomy_with_aliases(), taxonomy_with_aliases_path)


if __name__ == "__main__":
    write_taxonomy_with_aliases()
    print(f"Wrote {TAXONOMY_WITH_ALIASES_PATH}")
