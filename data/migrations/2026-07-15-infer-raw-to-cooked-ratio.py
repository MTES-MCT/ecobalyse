#!/usr/bin/env -S uv run --script
"""
Remove rawToCookedRatio from lci_catalog/*.json if it can be infered from
_MATERIAL_TYPE_TO_RAW_TO_COOKED_RATIO

If not (eg. poppy-seed-eu or material_type:other_food_items) keep the
explicit ratio.
"""

import json

from common.infer_metadata import (
    _MATERIAL_TYPE_TO_RAW_TO_COOKED_RATIO,
    get_material_types,
)
from config import DATA_ROOT_DIR
from ecobalyse_data.logging import logger


def main():
    lci_catalog = DATA_ROOT_DIR / "lci_catalog"

    cleaned_entries = 0
    kept_entries = 0

    for lci_path in sorted(lci_catalog.glob("*/*.json")):
        with open(lci_path, "r", encoding="utf-8") as fd:
            activity = json.load(fd)

        material_type_tags = get_material_types(activity.get("categories", []))
        inferred_ratio = (
            _MATERIAL_TYPE_TO_RAW_TO_COOKED_RATIO.get(next(iter(material_type_tags)))
            if len(material_type_tags) == 1
            else None
        )

        modified = False
        for metadata in activity.get("metadata", []):
            if "rawToCookedRatio" not in metadata:
                continue
            if metadata["rawToCookedRatio"] == inferred_ratio:
                del metadata["rawToCookedRatio"]
                metadata.pop("rawToCookedRatioMatch", None)
                cleaned_entries += 1
                modified = True
            else:
                kept_entries += 1
                if inferred_ratio is not None:
                    logger.warning(
                        f"{metadata.get('alias', lci_path.name)}: explicit ratio "
                        f"{metadata['rawToCookedRatio']} kept, differs from inferred "
                        f"{inferred_ratio} ({next(iter(material_type_tags))})"
                    )

        if modified:
            with open(lci_path, "w", encoding="utf-8") as fd:
                json.dump(activity, fd, ensure_ascii=False, sort_keys=True, indent=2)
                fd.write("\n")

    logger.info(f"Removed rawToCookedRatio from {cleaned_entries} metadata entries")
    logger.info(f"Kept explicit rawToCookedRatio on {kept_entries} metadata entries")


if __name__ == "__main__":
    main()
